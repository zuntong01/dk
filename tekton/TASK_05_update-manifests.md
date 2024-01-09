## __`TASK_05_update-manifests.md`__

#### <b><span style="color:cyan">[TASK 설명]</span></b>  
```bash
gitops repo에서 가져온 manifest 파일을 context_dir(prd,test,dev) 디렉토리에 따라 deployment.yaml 파일에 이미지명을 신규빌드한 컨테이너이미지로 업데이트(수정)
```

#### <b><span style="color:cyan">[TASK yaml 구문]</span></b> 
```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: update-manifests
  namespace: cma-p-ocn-ocr
spec:
# TASK의 파라메터 선언
# name : 파라메터명 / type : string(문자열), array(배열) 등 / default : 파라메터에 값이 없을 경우, Default 파라메타값
# 앞선 파이프라인의 params: 와 파이프라인의 대상 TASK의 task.params에 선언된 파라메터가 있을경우, 해당 값을 가져옴
# deployment.yaml 의 이미지명 업데이트를 위한, gitops 디렉토리(예: prd, test, dev, dr 등), 신규이미지명을 파라메터로 정의
  params:
    - description: Location of image to be patched with
      name: IMAGESTREAM
      type: string
    - default: k8s
      description: The directory in source that contains yaml manifests
      name: manifest_dir
      type: string

  steps:
    # TASK의 컨테이너 이미지명을 정의 (date명령만 수행가능하면 됨으로 기본 ubi이미지 사용)
    - image: >-
      hubp-quay-registry.apps.hubp.infra.io/cicd-images/tekton-task-ubi-minimal:8.3
    name: update-deploy-yaml

    # TASK에서 실행할 JOB을 script로 정의 / yaml 문법에  |, -> 등을 사용하는데, 어떤 개행필요여부등 조금씩 차이가 있음
    script: >
      #!/usr/bin/env bash
    
    ## TASK에서는 $(inputs.params.manifest_dir) 를 사용함
    ## $(inputs.params.manifest_dir): 앞선 TASK에서는 $(params.manifest_dir)로, 파이프라인의 task.params에 할당한 값을 사용했음
    ## $(inputs.params.manifest_dir): 어떻게 쓰이는지 관련 문법을 찾기 힘듬.. 몇몇 웹페이지에 사용예는 보이나, 공식문서와 같은 가이드를 확인하지 못했음 / 추측하건데, 파이프라인의 task.params에 할당한 값을, task의 param에 정의하지 않고, task의 step에서 바로 파라메터를 사용할때, $(inputs.params.manifest_dir)를 사용하지 않을까 짐작하며 / 물론 해당TASK는 task의 param에 정의되어 있었고, 그런데도 $(inputs.params.manifest_dir)를 사용해서, 해당 TASK만 이렇게 사용한 이유 짐작 어려움

    ## gitops repo에서 clone한 prd(환경별다름)/deployment.yaml 파일에서 이미지명 부분을 grep함
      ASIS_IMG=`cat $(inputs.params.manifest_dir)/deployment.yaml | grep hubp-quay-registry.apps.hubp.infra.io | awk ‘{print $1}’`
      echo “ASIS_IMG : $ASIS_IMG”

    ## 신규빌드한 이미지명으로 -->> gitops repo에서 clone한 prd(환경별다름)/deployment.yaml 의 이미지명을 치환함
      TOBE_IMG=$(inputs.params.IMAGESTREAM)
      echo “TOBE_IMG : $TOBE_IMG”
      ## gitops repo에서 가져온 prd디렉토리의 deployment.yaml 파일에 이미지명을 파이프라인에서 만든 이미지로 변경함
      set -x
      sed -i “s|$ASIS_IMG|$TOBE_IMG|” $(inputs.params.manifest_dir)/deployment.yaml

    ## TASK가 실행될때, 시작되는 현재 경로를 /workspace/gitops-output 에서 시작함
    workingDir: /workspace/gitops-output

workspaces:
  - name: gitops-output



```