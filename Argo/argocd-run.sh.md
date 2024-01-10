 __`argocd-run.sh.md`__

#### <b><span style="color:cyan">[스크립트 설명]</span></b>  
```bash
1. 스크립트 실행시 argument를 달리하여 PaaS 기동/중지를 진행함(시작/중지 구분 $1, 어플리케이션 구분 $2) 
2. DR Argo는 application 설정이 manual sync로 운영함 (gitops repo와 <---> 클러스터의 형상 동기화 유지를 안함!)
3. DR 전환시에만 argocd app sync 명령을 통해 클러스터에 배포하도록 구성
사용예시
# argocd-run.sh sync 어플리케이션명(argo)
# argocd-run.sh stop 어플리케이션명(argo)
```

#### <b><span style="color:cyan">[argo DR배포 스크립트]</span></b
```bash
#!/bin/bash
## argo 접속 토큰
ACCESS_TOKN=$(cat /DRWORK/paas/shl/argocd-secret.txt)
## openshift 클러스터에 접속 토큰
PAAS_TOKEN=$(cat /DRWORK/paas/shl/drsync-token.txt)
WORKDIR=/DRWORK/paas/shl/app
##LOGIN
## argo 로그인
/usr/local/bun/argocd login openshift-gitops-server-openshift-gitops.apps.hubr.infra.io --username="admin" --password=$ACCESS_TOKN --insecure
## case 구문 사용 / 스크립트 첫번째 argument가 sync일 경우 아래 명령 수행
case $1 in)
  sync)
    #Sync Application
    ## argocd app list 에 리스트되는 어플리케이션 목록에서, 스크립트 2번째 argument와 동일한 이름을 APP 변수에 설정
    APP=$(argocd app list | grep -v NAME | awk '{print $1}' | cut -d "/" -f 2 | grep $2)

      ## 동기화 수행하여 POD 배포
      /usr/local/bin/argocd app sync $APP
      /usr/local/bin/argocd app sync $APP
    exit 0
    ## ;;는 case 문 1개의 끝을 의미
    ;;

  stop)
    ## argocd app list 에 리스트되는 어플리케이션 목록에서, 스크립트 2번째 argument와 동일한 이름을 APP 변수에 설정
    APP=$(argocd app list | grep -v NAME | awk '{print $1}' | cut -d "/" -f 2 | grep $2)

      ## 배포된 어플리케이션 자체를 삭제하는 방식으로 조치하기 때문에, 삭제전 구성정보 yaml파일로 백업
      /usr/local/sbin/oc -n openshift-gitops-get application.argoproj.io $APP --token ${PAAS_TOKEN} -o yaml > $WORKDIR/$APP-application.yaml
      ## 배포된 application(argo) 삭제하여, 배포된 POD를 종료함
      /usr/local/bin/argocd app delete $APP -y
      sleep 2;

      ## POD만 배포된게 아니고, application(argo) 자체가 삭제되었으므로, 아까 백업한 yaml파일로 재배포함 (manual 동기화 설정으로 어플리케이션 생성되더라도 배포되지 않음)
      /usr/local/sbin/oc --token ${PAAS_TOKEN} create -f $WORKDIR/$APP-application.yaml
      /usr/local/bin/argocd app get --refresh $APP

    exit 0
    ;;
  *)
    echo "application명과 sync 또는 stop 을 입력하세요."
```
esac
