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

tfz() {
  local subcommand="$1"
  local target="$2"

  case "$subcommand" in
    i|init)
      terraform plan -target="$target"
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
      terraform plan -target="$target"
      ;;
    tg)
      TARGET=$(egrep -h "(^module\s|^resource\s)" *tf | awk '{print $1"."$2}' | sed 's/"//g' | fzf)
      CTL=$(echo "plan\napply" | fzf)
      printf "Run terraform ${CTL} -target=${TARGET}\n"
      terraform ${CTL} -target=${TARGET}
    ;;
    a|apply)
      terraform apply -target="$target"
      ;;
    *|help)
      cat << EOF
Usage: tfz [subcommand] <target>
i   - init
f   - fmt
v   - validate
ifv - init & fmt & validate
p   - plan -target
tg  - plan or apply to target
a   - apply

EOF
    ;;
  esac
}
