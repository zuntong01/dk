### __`TASK_02_gradle-build.md`__

#### <b><span style="color:cyan">[TASK 설명]</span></b>  
```bash
workspace로 git-clone한 소스를 gradle 빌드함 (build.gradle은 소스디렉토리에 포함되어 사전정의되어 있음)
```

#### <b><span style="color:cyan">[TASK yaml 구문]</span></b> 
```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: gradle
  labels:
    app.kubernetes.io/version: "0.2"
  annotations:
    tekton.dev/pipelines.minVersion: "0.12.1"
    tekton.dev/displayName: Gradle
    tekton.dev/categories: Build Tools
    tekton.dev/tags: build-tool
    tekton.dev/platforms: "linux/amd64,linux/s390x,linux/ppc64le"

spec:
  description: >-
    This Task can be used to run a Gradle build.

# TASK의 파라메터 선언
# name : 파라메터명 / type : string(문자열), array(배열) 등 / default : 파라메터에 값이 없을 경우, Default 파라메타값
# 앞선 파이프라인의 params: 와 파이프라인의 대상 TASK의 task.params에 선언된 파라메터가 있을경우, 해당 값을 가져옴
# GRADLE 빌드를 위한 TASK이미지, GRADLE 수행시 TASK 옵션이 정의되어 있음
  params:
    - name: GRADLE_IMAGE
      description: Gradle base image.
      type: string
      default: hubp.quay.registry.apps.hubp.infra.io/cicd-images/tekton-task-gradle:7.5-jdk11
    - name: PROJECT_DIR
      description: The directory containing build.gradle
      type: string
      default: "."
    - name: TASKS
      description: 'The gradle tasks to run (default: build)'
      type: array
      default: bootjar

  steps:
    - name: gradle-tasks
    ## TASK의 컨테이너 이미지명을 정의 (tekton-task-gradle:7.5-jdk11)
      image: $(params.GRADLE_IMAGE)

    ## TASK가 실행될때, 시작되는 현재 경로를 /workspace/source-output/MSE_CNT 에서 시작함(해당경로에 build.gradle이 있어서 그런듯)
      workingDir: $(workspaces.source.path)/$(params.PROJECT_DIR)
    ## script 대신, command, args 형식으로 빌드를 실행함
      command:
        - gradle
      args:
        - $(params.TASKS)
    ##
    ##      - ‘-Pprofile=prd’        # 프로퍼티설정
    ##      - ‘-PNEXUS_ID=cfw
    ##      - ‘-PNEXUS_PWD=cfw’
    ##      - clean                  # 빌드이전의 결과물 제거 (깨끗한 상태로 시작)
    ##      - bootjar                # SpringBoot 어플리케이션 실행가능한 JAR파일로 패키징


  workspaces:
    - name: source-output
      description: The workspace consisting of the gradle project.





```