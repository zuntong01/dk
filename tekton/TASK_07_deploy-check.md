## __`TASK_07_deploy-check.md`__

#### <b><span style="color:cyan">[TASK 설명]</span></b>  
```bash
TASK06에서 update-repository에서 gitops repo가 새로운 deployment.yaml push하면, ArgoCD는 이를 감지하고 배포를 시도하고, 이를 5분동안 모니터링하는 TASK (5분동안 TASK가 break되지 못하면 배포 실패로 간주)
```

#### <b><span style="color:cyan">[TASK yaml 구문]</span></b> 
```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deploy-check
  namespace: cma-p-ocn-ocr
spec:
  params:
     - description: name of the application to sync
       name: application-name
       type: string
  steps:
    - args:
      - |
         echo “#######################################”
         echo “# Check Application Deployment Status #” 
         echo “#######################################”

        while :
          do
          # Set Variable
          SYNC_STATUS=`oc get application —no-headers -n openshift-gitops “$(params.application-name)” | awk ‘{print $2}’`
          HEALTH_STATUS=`oc get application —no-headers -n openshift-gitops “$(params.application-name)” | awk ‘{print $3}’`
          CURRENT_TIME=$(date -u —date=“9 hour” +%Y/%m/%d-%H:%M:%S)

          # ArgoCD application 에서 Healty, Synced 상태가 되면, break 하고 TASK가 종료됨
          # TASK06에서 gitops repo가 새로운 deployment.yaml push하면, ArgoCD는 이를 감지하고 배포를 시도함
              if [ $HEALTH_STATUS = “Healthy” ] && [  $SYNC_STATUS = “Synced” ]
              then
                echo “*** Application Deployment Complete. ***”
                oc get application “$(params.application-name)” -n openshift-gitops
                echo -n “Current Time : “
                echo $CURRENT_TIME
                echo “”
                break
              else
                echo “*** Application Deployment progress…. ***”
                oc get application “$(params.application-name)” -n openshift-gitops
                echo -n “Current Time : “
                echo $CURRENT_TIME
                echo “”
                sleep 10
              fi
            done
      command:
        - /bin/bash
        - ‘-c’
      image: ‘hubp-quay-registry.apps.hubp.infra.io/cicd-images/tekton-task-oc:latest’
      name: deploy-check
      # TASK의 지속시간은 5분이며, 5분이내 배포가 완료되어 break되야 TASK 성공함
      timeot: 5m0s



```