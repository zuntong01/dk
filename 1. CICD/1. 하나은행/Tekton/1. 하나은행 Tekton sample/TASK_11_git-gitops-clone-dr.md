## __`TASK_11_gitops-clone-dr.md`__

#### <b><span style="color:cyan">[TASK 설명]</span></b>  
```bash
Gitlab repo(project:MSE_GOS)에서 --> Tekton TASK 내부의 Workspace 로 git-init 명령으로 배포관련 yaml (예: deploytment.yaml, route.yaml, hpa.yaml, secret 등) 파일을 다시 가져옴 (지난TASK에 가져온 workspace에 dr디렉토리 사용할 수 있으나, 지난 TASK에서 한번 push를 했기 때문에, git 충돌 방지위해 다시 git clone하여 / 신규빌드한 정보로 dr 디렉토리에 업데이트 하기위한 사전준비)
```

#### <b><span style="color:cyan">[TASK yaml 구문]</span></b> 
```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: git-source-clone
  labels:
    app.kubernetes.io/version: "0.8"
  annotations:
    tekton.dev/pipelines.minVersion: "0.29.0"
    tekton.dev/categories: Git
    tekton.dev/tags: git
    tekton.dev/displayName: "git clone"
    tekton.dev/platforms: "linux/amd64,linux/s390x,linux/ppc64le,linux/arm64"

spec:
  description: >-
    These Tasks are Git tasks to work with repositories used by other tasks
    in your Pipeline.

    The git-clone Task will clone a repo from the provided url into the
    output Workspace. By default the repo will be cloned into the root of
    your Workspace. You can clone into a subdirectory by setting this Task's
    subdirectory param. This Task also supports sparse checkouts. To perform
    a sparse checkout, pass a list of comma separated directory patterns to
    this Task's sparseCheckoutDirectories param.

# TASK의 파라메터 선언
# name : 파라메터명 / type : string(문자열), array(배열) 등 / default : 파라메터에 값이 없을 경우, Default 파라메타값
# 앞선 파이프라인의 params: 와 파이프라인의 대상 TASK의 task.params에 선언된 파라메터가 있을경우, 해당 값을 가져옴
# Git 소스가져오는 방식(sftp, http, https)에 따라 필요한 인증정보 / git-init 명령 수행시 필요한 옵션등을 정의한다.
  params:
    - name: url
      description: Repository URL to clone from.
      type: string
    - name: revision
      description: Revision to checkout. (branch, tag, sha, ref, etc...)
      type: string
      default: ""
    - name: refspec
      description: Refspec to fetch before checking out revision.
      default: ""
    - name: submodules
      description: Initialize and fetch git submodules.
      type: string
      default: "true"
    - name: depth
      description: Perform a shallow clone, fetching only the most recent N commits.
      type: string
      default: "1"
    - name: sslVerify
      description: Set the `http.sslVerify` global git config. Setting this to `false` is not advised unless you are sure that you trust your git remote.
      type: string
      default: "true"
    - name: crtFileName
      description: file name of mounted crt using ssl-ca-directory workspace. default value is ca-bundle.crt.
      type: string
      default: "ca-bundle.crt"
    - name: subdirectory
      description: Subdirectory inside the `output` Workspace to clone the repo into.
      type: string
      default: ""
    - name: sparseCheckoutDirectories
      description: Define the directory patterns to match or exclude when performing a sparse checkout.
      type: string
      default: ""
    - name: deleteExisting
      description: Clean out the contents of the destination directory if it already exists before cloning.
      type: string
      default: "true"
    - name: httpProxy
      description: HTTP proxy server for non-SSL requests.
      type: string
      default: ""
    - name: httpsProxy
      description: HTTPS proxy server for SSL requests.
      type: string
      default: ""
    - name: noProxy
      description: Opt out of proxying HTTP/HTTPS requests.
      type: string
      default: ""
    - name: verbose
      description: Log the commands that are executed during `git-clone`'s operation.
      type: string
      default: "true"
    - name: gitInitImage
      description: The image providing the git-init binary that this Task runs.
      type: string
      default: "hubp-quay-registry.apps.hubp.infra.io/cicd-images/tekton-task-git-clone:lastest
    - name: userHome
      description: |
        Absolute path to the user's home directory.
      type: string
      default: "/tekton/home"

# result 파라메터 값을 선언 
# TASK 수행 중, 발생한 특정 값(사용자가원하는)을 저장하여, 파이프라인의 다른 TASK 에 불러와 활용가능하고, History 차원에서 Tekton 콘솔에서 파이프라인run에 함께 기록됨.
# Git commit ID를 식별하기 위해 저장 / Git clone한 repo 주소 저장
  results:
    - name: commit
      description: The precise commit SHA that was fetched by this Task.
    - name: url
      description: The precise URL that was fetched by this Task.

  steps:
  # params 세션에서 파라메터를 정의했지만, 실제 TASK 수행시 사용할 변수를 steps,env에 새로 변수선언/값을 정의함 (params:의 파라메터값일 수도 있고, 사용자정의값 등 하기 나름)
  # 이렇게 TASK 수행시 변수 (예: HOME)로 정의하기도 하고, 바로 params의 파라메터 (예 : $(params.파라메터명))를 사용할 수 있음
  # 이부분은 추측인데, TASK params:에도 정의되어 있지 않아도, 앞선 파이프라인의 대상 TASK의 task.params가 정의되어 있다면, $(inputs.params.파라메터명) 으로 그 값을 바로 사용 할 수 있을 것으로 예상
    -  env:
         - name: HOME
            value: "$(params.userHome)"
         - name: PARAM_URL
            value: $(params.url)
          - name: PARAM_REVISION
            value: $(params.revision)
          - name: PARAM_REFSPEC
            value: $(params.refspec)
          - name: PARAM_SUBMODULES
            value: $(params.submodules)
          - name: PARAM_DEPTH
            value: $(params.depth)
          - name: PARAM_SSL_VERIFY
            value: $(params.sslVerify)
          - name: PARAM_CRT_FILENAME
            value: $(params.crtFileName)
          - name: PARAM_SUBDIRECTORY
            value: $(params.subdirectory)
          - name: PARAM_DELETE_EXISTING
            value: $(params.deleteExisting)
          - name: PARAM_HTTP_PROXY
            value: $(params.httpProxy)
          - name: PARAM_HTTPS_PROXY
             value: $(params.httpsProxy)
          - name: PARAM_NO_PROXY
            value: $(params.noProxy)
          - name: PARAM_VERBOSE
            value: $(params.verbose)
          - name: PARAM_SPARSE_CHECKOUT_DIRECTORIES
            value: $(params.sparseCheckoutDirectories)
          - name: PARAM_USER_HOME
            value: $(params.userHome)
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
          -  name: WORKSPACE_SSL_CA_DIRECTORY_BOUND
            value: $(workspaces.ssl-ca-directory.bound)
          - name: WORKSPACE_SSL_CA_DIRECTORY_PATH
            value: $(workspaces.ssl-ca-directory.path)

  # TASK의 컨테이너 이미지명을 정의 (git-clone 하기위한 git 관련 패키지가 설치된 이미지가 필요 : tekton-task-git-clone:lastest)            
      image: $(params.gitInitImage)
      name: clone
      resources: {}
 
  # TASK에서 실행할 JOB을 script로 정의 / yaml 문법에  |, -> 등을 사용하는데, 어떤 개행필요여부등 조금씩 차이가 있음
      script: |
        #!/usr/bin/env sh
       ## -e : 실행 중 에러 발생시, 즉시 스크립트 종료 / -u : 정의되지 않은 변수를 사용할때 에러 발생시켜 , 종료함 
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
      ## 따라서, tekton 파이프라인을 실행하는 Service Account에 Secret 설정으로 Git 설정이 됨.
        if [ "${WORKSPACE_BASIC_AUTH_DIRECTORY_BOUND}" = "true" ] ; then
          cp "${WORKSPACE_BASIC_AUTH_DIRECTORY_PATH}/.git-credentials" "${PARAM_USER_HOME}/.git-credentials"
          cp "${WORKSPACE_BASIC_AUTH_DIRECTORY_PATH}/.gitconfig" "${PARAM_USER_HOME}/.gitconfig"
          chmod 400 "${PARAM_USER_HOME}/.git-credentials"
          chmod 400 "${PARAM_USER_HOME}/.gitconfig"
        fi

      ## SSH_DIRECTORY 라는 workspace가 존재(bound) 한 경우, 사전 작성된 key 파일을 workspace에서 복사함 (ssh방식 사용안함 X)
        if [ "${WORKSPACE_SSH_DIRECTORY_BOUND}" = "true" ] ; then
          cp -R "${WORKSPACE_SSH_DIRECTORY_PATH}" "${PARAM_USER_HOME}"/.ssh
          chmod 700 "${PARAM_USER_HOME}"/.ssh
          chmod -R 400 "${PARAM_USER_HOME}"/.ssh/*
        fi

      ## 기업 내에서 자체 CA를 사용하는 경우나 특정 CA에 대한 사용자 지정 요구사항이 있을 때 활용
      ## SSL_CA_DIRECTORY 라는 workspace가 존재(bound) 한 경우, GIT_SSL_PATH를 GIT이 https연결할 인증서가 존재하는  SSL_CA_DIRECTORY workspace의 path로 지정함
      ## 그리고 해당 디렉토리에 사용할 인증서명까지 정의함.
        if [ "${WORKSPACE_SSL_CA_DIRECTORY_BOUND}" = "true" ] ; then
           export GIT_SSL_CAPATH="${WORKSPACE_SSL_CA_DIRECTORY_PATH}"
           if [ "${PARAM_CRT_FILENAME}" != "" ] ; then
              export GIT_SSL_CAINFO="${WORKSPACE_SSL_CA_DIRECTORY_PATH}/${PARAM_CRT_FILENAME}"
           fi
        fi

## ----------------------------------------------------------------------------------------------------------------------------------------------

        ## git clone 전에 checkout 디렉토리에 데이터가 있다면 삭제 
        ## 3번을 삭제함 : 하위디렉토리 파일 삭제 / .파일삭제 / ..파일삭제

        CHECKOUT_DIR="${WORKSPACE_OUTPUT_PATH}/${PARAM_SUBDIRECTORY}"

        cleandir() {
          # Delete any existing contents of the repo directory if it exists.
          #
          # We don't just "rm -rf ${CHECKOUT_DIR}" because ${CHECKOUT_DIR} might be "/"
          # or the root of a mounted volume.
          if [ -d "${CHECKOUT_DIR}" ] ; then
            # Delete non-hidden files and directories
            rm -rf "${CHECKOUT_DIR:?}"/*
            # Delete files and directories starting with . but excluding ..
            rm -rf "${CHECKOUT_DIR}"/.[!.]*
            # Delete files and directories starting with .. plus any other character
            rm -rf "${CHECKOUT_DIR}"/..?*
          fi
        }

        if [ "${PARAM_DELETE_EXISTING}" = "true" ] ; then
          cleandir
        fi

        ## PROXY 서버를 통해 ---> GIT repo 서버와 통신해야 한다면, HTTP(S) proxy 변수 설정 필요 (사용안함X, 내부GITLAB서버사용))
        test -z "${PARAM_HTTP_PROXY}" || export HTTP_PROXY="${PARAM_HTTP_PROXY}"
        test -z "${PARAM_HTTPS_PROXY}" || export HTTPS_PROXY="${PARAM_HTTPS_PROXY}"
        test -z "${PARAM_NO_PROXY}" || export NO_PROXY="${PARAM_NO_PROXY}"

        ## git-init 수행 (tekton task에 있는 명령어로 bg로, git subcommand 가 실행되는듯..)
        /ko-app/git-init \
          -url="${PARAM_URL}" \                                  ## git repo 주소
          -revision="${PARAM_REVISION}" \                        ## 체크아웃할 revision (브랜치, 태그, 커밋등)
          -refspec="${PARAM_REFSPEC}" \                          ## 로컬브랜치 <—> 리모트브랜치간의 매핑 및 복제 규칙정의에 사용(없음)
          -path="${CHECKOUT_DIR}" \                              ## 다운로드 할 디렉토리
          -sslVerify="${PARAM_SSL_VERIFY}" \                     ## ssl인증서 검증여부 (http url 일 경우 자동 무시됨) / 사설인증서를 통한 https일 경우는, false 설정필요
          -submodules="${PARAM_SUBMODULES}" \    ## 서브모듈 초기화, 업데이트 여부 (git 저장소 디렉토리 안에 또다른 git 저장소가 있을때, 같이 다운로드 하기 위해)   
          -depth="${PARAM_DEPTH}" \                              ## 0이면, 모든 history commit 복제, 1이면 최신 commit 까지만 복제
          -sparseCheckoutDirectories="${PARAM_SPARSE_CHECKOUT_DIRECTORIES         ##  특정디렉토리만 checkout 할경우 사용(값없음)

        ## 현재 작업중인 디렉토리의 HEAD 커밋의 해시값을 저장 (현재 작업한 커밋등을 확인할때 활용할 수 있음)    
        cd "${CHECKOUT_DIR}"
        RESULT_SHA="$(git rev-parse HEAD)"
        ## 만약 git clone 이 정상 수행되지 않았다면, EXIT 함
        EXIT_CODE="$?"
        if [ "${EXIT_CODE}" != 0 ] ; then
          exit "${EXIT_CODE}"
        fi

        ## result 에 commit hash, clone git url 값 저장
        printf "%s" "${RESULT_SHA}" > "$(results.commit.path)"
        printf "%s" "${PARAM_URL}" > "$(results.url.path)"

  ## 실행되는 TASK(컨테이너) 권한을 제어하고자 655321 UID로 설정
  ## 655321, 655324 같은 UID는 nobody같은 계정권한으로 최소권한을 할당하는 의미와 유사한듯
      securityContext:
         runAsNonRoot: true
         runAsUser: 655321

workspaces:        ## TASK 가 사용할 영구스토리지 (trigger-tempate 에 pvc가 설정되어 있음) 앞선 source git clone과 gitops 파일을 clone하는 pvc는 서로 분리되어 있음
    - name: gitops-output
      description: The git repo will be cloned onto the volume backing this Workspace.

    ## git clone 시 ssh 방식으로가져올때, 관련 key 저장용도의 workspace 설정인데, 만약 해당 workspace가 없더라도에러 발생시키지 않고, TASK 수행을 진행시키기 위해, optional:true 설정함
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
    - name: ssl-ca-directory
      optional: true
      description: |
        A workspace containing CA certificates, this will be used by Git to
        verify the peer with when fetching or pushing over HTTPS.



```