
### Variables
CLUSTER_NAME=example

### saml2aws
# please set SAML2AWS_LOGIN_CHECK true or false to .zshrc.local
function login_check () {
 if "${SAML2AWS_LOGIN_CHECK}";then
   if which saml2aws; then
     saml2aws login
   fi
 fi
}

### Bastion on ECS / EC2
# Usage: set_bastion_id [ecs|ec2] [aws_profile]
function set_bastion_id () {
  BASTION_TYPE=${1:-ecs}
  AWS_PROFILE=${2:-default}

  if ! login_check; then
    return 1
  fi

  case "${BASTION_TYPE}" in
    ecs)
      ENV_SERVICE=$(aws ecs list-services --cluster ${CLUSTER_NAME} --profile ${AWS_PROFILE} | jq -r '.serviceArns[]' | awk -F'/' '{print $(NF-0)}' | fzf --reverse --prompt "踏み台コンテナを選択しようず🍣 ")
      TASK_ID=$(aws ecs list-tasks --cluster ${CLUSTER_NAME} --service-name ${ENV_SERVICE} --query "taskArns[0]" --output text --region ap-northeast-1 --profile ${AWS_PROFILE} | awk -F '/' '{print $3}')
      CONTAINER_ID=$(aws ecs describe-tasks --cluster ${CLUSTER_NAME} --task ${TASK_ID} --region ap-northeast-1 --profile ${AWS_PROFILE} | jq -r --arg CONTAINER_NAME bastion '.tasks[0].containers[].runtimeId')
      BASTION_TARGET="ecs:${CLUSTER_NAME}_${TASK_ID}_${CONTAINER_ID}"
      ;;
    ec2)
      BASTION_TARGET=$(aws ec2 describe-instances --output=text \
        --query 'Reservations[].Instances[].{id:InstanceId,ip:PrivateIpAddress,name:Tags[?Key==`Name`].Value|[0]}' \
        --profile ${AWS_PROFILE} \
        | fzf --reverse --prompt "踏み台EC2を選択しようず🍣 " | cut -f -1)
      ;;
    *)
      echo "Usage: set_bastion_id [ecs|ec2] [aws_profile]" >&2
      return 1
      ;;
  esac

  [ -n "${BASTION_TARGET}" ]
}

# Usage: ssm_bastion [ecs|ec2] [aws_profile]
function ssm_bastion () {
  set_bastion_id "${1:-ecs}" "${2:-default}" && \
    aws ssm start-session --profile ${AWS_PROFILE} --target ${BASTION_TARGET}
}

### EC2
function ssm_ec2 () {
  if login_check; then
    AWS_PROFILE=${1:-default}
    EC2=$(aws ec2 describe-instances --output=text \
      --query 'Reservations[].Instances[].{id:InstanceId,ip:PrivateIpAddress,name:Tags[?Key==`Name`].Value|[0]}' \
      --profile ${AWS_PROFILE} \
      | fzf --reverse --prompt "Select EC2:" | cut -f -1)
  fi

  if [ -n "${EC2}" ];then
    aws ssm start-session \
      --profile ${AWS_PROFILE} \
      --target ${EC2}
  fi

}


# Usage: ssm_redis [ecs|ec2] [aws_profile]
function ssm_redis () {
  if login_check; then
    AWS_PROFILE=${2:-default}
    REDIS_ENDPOINT=$(aws elasticache describe-replication-groups --output=text --query='ReplicationGroups[].NodeGroups[].[[`PrimaryEndpoint`,PrimaryEndpoint.Address],[`ReaderEndpoint`,ReaderEndpoint.Address]][]' \
      --profile ${AWS_PROFILE} \
      | fzf --reverse --prompt "Select Redis Cluster Endpoint:" | cut -f 2)


    if set_bastion_id "${1:-ecs}" "${AWS_PROFILE}";then
      aws ssm start-session --profile ${AWS_PROFILE} --target ${BASTION_TARGET} \
        --document-name AWS-StartPortForwardingSessionToRemoteHost \
        --parameters "{\"host\":[\"${REDIS_ENDPOINT}\"],\"portNumber\":[\"6379\"], \"localPortNumber\":[\"6379\"]}"
    fi
  fi
}

### Aurora
# Usage: ssm_aurora [ecs|ec2] [aws_profile]
function ssm_aurora () {
  AWS_PROFILE=${2:-default}
  if set_bastion_id "${1:-ecs}" "${AWS_PROFILE}";then
    AURORA_ENDPOINT=$(aws rds describe-db-cluster-endpoints --output=text \
      --query='DBClusterEndpoints[].[EndpointType,Endpoint]' \
      --profile ${AWS_PROFILE} \
      | fzf --reverse --prompt "Select Aurora Endpoint:" | cut -f 2)

    SESSION_COUNT=$(ps aux | grep "aws ssm start-session" | grep -v grep | wc -l | sed 's/ //g')
    DB_LOCAL_PORT=$(expr 3306 + ${SESSION_COUNT})
    echo "\n---\nConnect to ${AURORA_ENDPOINT}.\nPlease run 'mysql -h 127.0.0.1 -p -P ${DB_LOCAL_PORT} -u'"
    aws ssm start-session --profile ${AWS_PROFILE} --target ${BASTION_TARGET} \
     --document-name AWS-StartPortForwardingSessionToRemoteHost \
     --parameters "{\"host\":[\"${AURORA_ENDPOINT}\"],\"portNumber\":[\"3306\"], \"localPortNumber\":[\"${DB_LOCAL_PORT}\"]}"
  fi
}

