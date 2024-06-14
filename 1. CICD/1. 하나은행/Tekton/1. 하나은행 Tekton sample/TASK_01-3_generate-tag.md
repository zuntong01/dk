### __`TASK_01-3_generate-tag.md`__

#### <b><span style="color:cyan">[TASK 설명]</span></b>  
```bash
새로 생성한 컨테이너 이미지에 사용할 TAG를 생성함 (TAG명은 시간(년월일-시분초))
```

#### <b><span style="color:cyan">[TASK yaml 구문]</span></b>  
```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  annotations:
    description: |
      Generate a new uniqe image tag based on format YYYY-MM-YY-HH-MM-SS.
  name: generate-tag
  namespace: cma-p-ocn-ocr
spec:
# result 파라메터 값을 선언 
# TASK 수행 중, 발생한 특정 값(사용자가원하는)을 저장하여, 파이프라인의 다른 TASK 에 불러와 활용가능하고, History 차원에서 Tekton 콘솔에서 파이프라인run에 함께 기록됨.
# 컨테이너이미지 Tag로 사용할 값을 TASK의 results.image-tag의 저장
  results:
    - description: The current date in human readale format
      name: image-tag
      type: string

  steps:
    # TASK의 컨테이너 이미지명을 정의 (date명령만 수행가능하면 됨으로 기본 ubi이미지 사용)
    - image: >-
        hubp-quay-registry.apps.hubp.infra.io/cicd-images/tekton-task-ubi-minimal:8.3
      name: generate-image-tag

    # TASK에서 실행할 JOB을 script로 정의 / yaml 문법에  |, -> 등을 사용하는데, 어떤 개행필요여부등 조금씩 차이가 있음
      script: |
        #!/usr/bin/env bash
        echo -n “Generate Tag Name : “

        GENERATE_TAG_NAME=$(date -u —date=“9 hour” +%Y-%m-%d-%H-%M-%S)
        echo -n $GENERATE_TAG_NAME
        echo -n $GENERATE_TAG_NAME > $(results.image-tag.path)

```
