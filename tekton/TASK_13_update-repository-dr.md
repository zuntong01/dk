## __`TASK_13_update-repository-dr.md`__

#### <b><span style="color:cyan">[TASK 설명]</span></b>  
```bash
TASK12_update-manifest TASK에서 수정한 deployment.yaml 파일을 --> git push 함 
컨테이너 이미지는 빌드후, DR quay로 copy하지만, Gitlab repo는 실시간으로 DR에 copy됨으로, 운영 gitops repo의 dr디렉토리에 업로드하여 자동 sync되도록 함
```

#### <b><span style="color:cyan">[TASK yaml 구문]</span></b> 
```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: git-cli
  namespace: cma-p-ocn-ocr
  labels:
    app.kubernetes.io/version: "0.2"
  annotations:
    tekton.dev/pipelines.minVersion: "0.21.0"
    tekton.dev/categories: Git
    tekton.dev/tags: git
    tekton.dev/displayName: "git cli"
    tekton.dev/platforms: "linux/amd64,linux/s390x,linux/ppc64le"
spec:
  description: >-
    This task can be used to perform git operations.

    Git command that needs to be run can be passed as a script to
    the task. This task needs authentication to git in order to push
    after the git operation.

# TASK의 파라메터 선언
# name : 파라메터명 / type : string(문자열), array(배열) 등 / default : 파라메터에 값이 없을 경우, Default 파라메타값
# 앞선 파이프라인의 params: 와 파이프라인의 대상 TASK의 task.params에 선언된 파라메터가 있을경우, 해당 값을 가져옴
# Gitops yaml 파일 업데이트 후, --> git push 하기위한 GIT_USER_NAME, EMAIL, GIT script 관련된 파라메터를 설정함 
  params:
    - name: BASE_IMAGE
      description: |
        The base image for the task.
      type: string
      default: ‘hubp-quay-registry.apps.hubp.infra.io/cicd-images/tekton-task-git:lastet’

    - name: GIT_USER_NAME
      type: string
      description: |
        Git user name for performing git operation.
      default: ""

    - name: GIT_USER_EMAIL
      type: string
      description: |
        Git user email for performing git operation.
      default: ""

    - name: GIT_SCRIPT
      description: The git script to run.
      type: string
      default: |
        git help

    - name: USER_HOME
      description: |
        Absolute path to the user's home directory. Set this explicitly if you are running the image as a non-root user or have overridden
        the gitInitImage param with an image containing custom user configuration.
      type: string
      default: "/tekton/home"

    - name: VERBOSE
      description: Log the commands that are executed during `git-clone`'s operation.
      type: string
      default: "true"

  results:
    - name: commit
      description: The precise commit SHA after the git operation.
      type: string

  steps:
    - name: git
      image: $(params.BASE_IMAGE)
      workingDir: $(workspaces.gitops-output.path)

      env:
      - name: HOME
        value: $(params.USER_HOME)
      - name: PARAM_VERBOSE
        value: $(params.VERBOSE)
      - name: PARAM_USER_HOME
        value: $(params.USER_HOME)
      - name: WORKSPACE_OUTPUT_PATH
        value: $(workspaces.output.path)
      - name: WORKSPACE_SSH_DIRECTORY_BOUND
        value: $(workspaces.ssh-directory.bound)
      - name: WORKSPACE_SSH_DIRECTORY_PATH
        value: $(workspaces.ssh-directory.path)
      - name: WORKSPACE_BASIC_AUTH_DIRECTORY_BOUND
        value: $(workspaces.basic-auth.bound)
      - name: WORKSPACE_BASIC_AUTH_DIRECTORY_PATH
        value: $(workspaces.basic-auth.path)

    script: |
      #!/usr/bin/env sh
      set -eu

      if [ "${PARAM_VERBOSE}" = "true" ] ; then
        set -x
      fi

    ## git clone 시에 ssh, https 방식으로 가져올때 key, 인증서등의 정보가 필요할때,  해당 정보를 worksapce 에 저장해놓고, TASK실행시 마운트하여, cp 하는 설정 
    ## git 문서상에는, 
    ## basic-auth 타입 Secret(Secret.annotation 에 URL 명시 / Secret.stringData에 username, password를 명시) 생성하고, 
    ## ServiceAccount에 생성한 Secret을 정의하고, TaskRun에 ServiceAccount를 정의하면, TASK 실행시, Tekton이 .gitconfig, git-credential 파일을 생성할수 있음.
    ## TASK, PiPELINE에 ServiceAccount가 현재 정의되어 있지는 않는데,기본적으로 실행하는 TriggerTemplate에 정의되어 있기 때문에 run시 자동 동작 할것으로 예상함
      
    ## BASIC_AUTH_DIRECTORY 라는 workspace가 존재(bound) 한 경우,사전 작성된 git-credentials, .gitconfig을 workspace 에서 TASK tekton 홉디렉토리로 복사함
    ## .gitconfig 파일 : 사용자이름/이메일주소등이 등의 사전환경정보 / .git-credential 파일 : http(s) 방식으로 username, password, repo주소로 인증하려고 할때 사용
    ## 명시적으로 basic-auth workspace가 정의되어 있지 않아서, false로, 동작하지 않음
      if [ "${WORKSPACE_BASIC_AUTH_DIRECTORY_BOUND}" = "true" ] ; then
          cp "${WORKSPACE_BASIC_AUTH_DIRECTORY_PATH}/.git-credentials" "${PARAM_USER_HOME}/.git-credentials"
          cp "${WORKSPACE_BASIC_AUTH_DIRECTORY_PATH}/.gitconfig" "${PARAM_USER_HOME}/.gitconfig"
          chmod 400 "${PARAM_USER_HOME}/.git-credentials"
          chmod 400 "${PARAM_USER_HOME}/.gitconfig"
      fi

      if [ "${WORKSPACE_SSH_DIRECTORY_BOUND}" = "true" ] ; then
          cp -R "${WORKSPACE_SSH_DIRECTORY_PATH}" "${PARAM_USER_HOME}"/.ssh
          chmod 700 "${PARAM_USER_HOME}"/.ssh
          chmod -R 400 "${PARAM_USER_HOME}"/.ssh/*
      fi

    # Setting up the config for the git.
      git config --global user.email "$(params.GIT_USER_EMAIL)"
      git config --global user.name "$(params.GIT_USER_NAME)"

    ## git pull orgin main 후에 commit 하고, 다시 origin 에 다시 push
    ## 이미 아까 git clone (MSE_GOS.git) 한 디렉토리가 Workdirectory이기 때문에 remote origin 설정은 이미 되어 있음
      $(params.GIT_SCRIPT)
      ##    git pull origin $(params.GITOPS_GIT_REVISION)
      ##    git add . -A
      ##    git commit -m $(tasks.generate-tag.results.image-tag)
      ##    git checkout -b $(params.GITOPS_GIT_REVISION)
      ##    git push origin $(params.GITOPS_GIT_REVISION)

        RESULT_SHA="$(git rev-parse HEAD | tr -d '\n')"
        EXIT_CODE="$?"
        if [ "$EXIT_CODE" != 0 ]
        then
          exit $EXIT_CODE
        fi

    ## result 에 commit hash, clone git url 값 저장
        # Make sure we don't add a trailing newline to the result!
        echo -n "$RESULT_SHA" > $(results.commit.path)

workspaces:        ## TASK 가 사용할 영구스토리지 (trigger-tempate 에 pvc가 설정되어 있음)
    - name: gitops-output
      description: A workspace that contains the fetched git repository.

    - name: input  ## 
      description: A workspace that contains file that needs to be added to git.
      optional: true

    - name: ssh-directory
      optional: true
      description: |
        A .ssh directory with private key, known_hosts, config, etc. Copied to
        the user's home before git commands are executed. Used to authenticate
        with the git remote when performing the clone. Binding a Secret to this
        Workspace is strongly recommended over other volume types.

    - name: basic-auth
      optional: true
      description: |
        A Workspace containing a .gitconfig and .git-credentials file. These
        will be copied to the user's home before any git commands are run. Any
        other files in this Workspace are ignored. It is strongly recommended
        to use ssh-directory over basic-auth whenever possible and to bind a
        Secret to this Workspace over other volume types.



```