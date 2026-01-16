
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

### Bastion on ECS
function set_bastion_id () {
  if login_check; then
    AWS_PROFILE=${1:-default}
    ENV_SERVICE=$(aws ecs list-services --cluster ${CLUSTER_NAME} --profile ${AWS_PROFILE} | jq -r '.serviceArns[]' | awk -F'/' '{print $(NF-0)}' | peco --prompt "踏み台コンテナを選択しようず🍣 ")
    TASK_ID=$(aws ecs list-tasks --cluster ${CLUSTER_NAME} --service-name ${ENV_SERVICE} --query "taskArns[0]" --output text --region ap-northeast-1 --profile ${AWS_PROFILE} | awk -F '/' '{print $3}')
    CONTAINER_ID=$(aws ecs describe-tasks --cluster ${CLUSTER_NAME} --task ${TASK_ID} --region ap-northeast-1 --profile ${AWS_PROFILE} | jq -r --arg CONTAINER_NAME bastion '.tasks[0].containers[].runtimeId')

  fi
}

function ssm_bastion () {
  set_bastion_id && aws ssm start-session --target ecs:${CLUSTER_NAME}_${TASK_ID}_${CONTAINER_ID}
}

### EC2
function ssm_ec2 () {
  if login_check; then
    AWS_PROFILE=${1:-default}
    EC2=$(aws ec2 describe-instances --output=text \
      --query 'Reservations[].Instances[].{id:InstanceId,ip:PrivateIpAddress,name:Tags[?Key==`Name`].Value|[0]}' \
      --profile ${AWS_PROFILE} \
      | peco --prompt "Select EC2:" | cut -f -1)
  fi

  if [ -n "${EC2}" ];then
    aws ssm start-session \
      --profile ${AWS_PROFILE} \
      --target ${EC2}
  fi

}


function ssm_redis () {
  if login_check; then
    AWS_PROFILE=${1:-default}
    REDIS_ENDPOINT=$(aws elasticache describe-replication-groups --output=text --query='ReplicationGroups[].NodeGroups[].[[`PrimaryEndpoint`,PrimaryEndpoint.Address],[`ReaderEndpoint`,ReaderEndpoint.Address]][]' \
      | peco --prompt "Select Redis Cluster Endpoint:" | cut -f 2)
    

    if set_bastion_id;then
      aws ssm start-session --target ecs:${CLUSTER_NAME}_${TASK_ID}_${CONTAINER_ID} \
        --document-name AWS-StartPortForwardingSessionToRemoteHost \
        --parameters "{\"host\":[\"${REDIS_ENDPOINT}\"],\"portNumber\":[\"6379\"], \"localPortNumber\":[\"6379\"]}"
    fi
  fi
}

### Aurora
function ssm_aurora () {
  if set_bastion_id;then
    AWS_PROFILE=${1:-default}
    AURORA_ENDPOINT=$(aws rds describe-db-cluster-endpoints --output=text \
      --query='DBClusterEndpoints[].[EndpointType,Endpoint]' \
      | peco --prompt "Select Aurora Endpoint:" | cut -f 2)

    SESSION_COUNT=$(ps aux | grep "aws ssm start-session" | grep -v grep | wc -l | sed 's/ //g')
    DB_LOCAL_PORT=$(expr 3306 + ${SESSION_COUNT})
    echo "\n---\nConnect to ${AURORA_ENDPOINT}.\nPlease run 'mysql -h 127.0.0.1 -p -P ${DB_LOCAL_PORT} -u'"
    aws ssm start-session --target ecs:${CLUSTER_NAME}_${TASK_ID}_${CONTAINER_ID} \
     --document-name AWS-StartPortForwardingSessionToRemoteHost \
     --parameters "{\"host\":[\"${AURORA_ENDPOINT}\"],\"portNumber\":[\"3306\"], \"localPortNumber\":[\"${DB_LOCAL_PORT}\"]}"
  fi
}

