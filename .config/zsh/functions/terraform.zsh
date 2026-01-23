tfpt() {
  terraform plan -target="$1"
}

tfat() {
  terraform apply -target="$1"
}

tfptm() {
  local targets=()
  for arg in "$@"; do
    targets+=(-target="$arg")
  done
  terraform plan "${targets[@]}"
}

tfatm() {
  local targets=()
  for arg in "$@"; do
    targets+=(-target="$arg")
  done
  terraform apply "${targets[@]}"
}

terraform_target() {
  egrep -h "(^module\s|^resource\s)" *tf | awk '{print $1"."$2"."$3}' | sed -E 's/(\"|{)//g; s/\.$//' | fzf -m | xargs -I{} printf -- '-target=%s ' {}
}

tfz() {
  local subcommand="$1"

  case "$subcommand" in
    i|init)
      terraform init
      ;;
    f|fmt)
      terraform fmt
    ;;
    v|valiadte)
      terraform validate
    ;;
    ifv)
      terraform init && terraform fmt && terraform validate
    ;;
    p|plan)
      target=$(terraform_target)
      echo "terraform plan ${target}"
      echo "DEBUG: [${target}]"

      #NOTE:${=target}とすることで単語分割される
      terraform plan ${=target}
      ;;
    tg)
      target=$(terraform_target)
      ctl=$(echo "plan\napply" | fzf)
      printf "terraform ${ctl} ${target}\n"
      terraform ${ctl} ${=target}
    ;;
    a|apply)
      target=$(terraform_target)
      echo "terraform apply ${target}"
      terraform apply ${=target}
      ;;
    *|help)
      cat << eof
usage: tfz [subcommand] <target>
i   - init
f   - fmt
v   - validate
ifv - init & fmt & validate
p   - plan -target
tg  - plan or apply to target
a   - apply

eof
    ;;
  esac
}


### もうtfenv使ってないけど残しておく
function tfenv_latest_install () {
    latest_terraform=$(tfenv list-remote | egrep "^\d{1,2}\.\d{1,2}\.\d{1,2}$" | head -1)
    tfenv install ${latest_terraform}
    if [ -f ".terraform-version" ];then
        echo ${latest_terraform} >| .terraform-version
    fi
}

