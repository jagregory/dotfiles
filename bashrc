export PATH=$PATH:./node_modules/.bin:/usr/local/opt/go/libexec/bin:~/OSS/golang/bin

envchain-sh() {
  export ENVCHAIN="$1"
  envchain $ENVCHAIN env $SHELL --rcfile ~/.bash_envchain_rc -i
}
