## __`TASK_03_build-image.md`__

#### <b><span style="color:cyan">[TASK 설명]</span></b>  
```bash
소스빌드한 파일을 포함하여, 컨테이너 이미지로 빌드함
```

#### <b><span style="color:cyan">[TASK yaml 구문]</span></b> 
```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: buildah
  labels:
    app.kubernetes.io/version: "0.1"
    operator.tekton.dev/operand-name: openshift-pipelines-addons
    operator.tekton.dev/provider-type: redhat
  annotations:
    tekton.dev/categories: Image Build
    tekton.dev/pipelines.minVersion: "0.12.1"
    tekton.dev/tags: image-build
    tekton.dev/platforms: "linux/amd64"

spec:
  description: >-
    Buildah task builds source into a container image and
    then pushes it to a container registry.

    Buildah Task builds source into a container image using Project Atomic's
    Buildah build tool.It uses Buildah's support for building from Dockerfiles,
    using its buildah bud command.This command executes the directives in the
    Dockerfile to assemble a container image, then pushes that image to a
    container registry.

# TASK의 파라메터 선언
# name : 파라메터명 / type : string(문자열), array(배열) 등 / default : 파라메터에 값이 없을 경우, Default 파라메타값
# 앞선 파이프라인의 params: 와 파이프라인의 대상 TASK의 task.params에 선언된 파라메터가 있을경우, 해당 값을 가져옴
# buildah 명령으로 컨테이너 빌드 옵션과 빌드대상의 이미지명, Dockerfile명 등이 파라메터로 설정되어있음
  params:
  - name: IMAGE
    description: Reference of the image buildah will produce.
    type: string
  - name: BUILDER_IMAGE
    description: The location of the buildah builder image.
    default: >-
      hubp-quay-registry.apps.hubp.infra.io/cicd-images/tekton-task-buildah:latest
    type: string
  - name: STORAGE_DRIVER
    description: Set buildah storage driver
    default: vfs
    type: string  
- name: DOCKERFILE
    description: Path to the Dockerfile to build.
    default: ./Dockerfile.prd
    type: string  
- name: CONTEXT
    description: Path to the directory to use as context.
    default: .
    type: string
  - name: TLSVERIFY
    description: Verify the TLS on the registry endpoint (for push/pull to a non-TLS registry)
    default: "false"
    type: string
  - name: FORMAT
    description: The format of the built container, oci or docker
    default: "oci"
    type: string
  - name: BUILD_EXTRA_ARGS
    description: Extra parameters passed for the build command when building images.
    default: ‘’ 
    type: string
  - name: PUSH_EXTRA_ARGS
    description: Extra parameters passed for the push command when pushing images.  
    default: ‘’
    type: string
  - name: SKIP_PUSH
     description: Skip pushing the buildt iamge
     default: ‘false’
      type: string
 
 # result 파라메터 값을 선언 
# TASK 수행 중, 발생한 특정 값(사용자가원하는)을 저장하여, 파이프라인의 다른 TASK 에 불러와 활용가능하고, History 차원에서 Tekton 콘솔에서 파이프라인run에 함께 기록됨.
# 컨테이너 배포, 업데이트관리, 무결성검증등을 위해 image 생성 고유한식별자를 SHA-256 해시 값인 digest값 저장 / 빌드해서 push한 이미지 주소값 저장
 results:
  - name: IMAGE_DIGEST
    description: Digest of the image just built.
    type: string
  - name: IMAGE_URL
    desscription: Image repository where the buult image would be pushed to 
    type: string

  steps:
  - name: build-and-push
    ## TASK의 컨테이너 이미지명을 정의 (tekton-task-buildah:latest)
    image: $(params.BUILDER_IMAGE)
    ## TASK가 실행될때, 시작되는 현재 경로를 /workspace/source-output 에서 시작함(.dockerfile 위치가 ./MSE-CNT/Dockerfile.prd 에 위치했기때문)
    workingDir: $(workspaces.source.path)

    ## TASK에서 실행할 JOB을 script로 정의 / yaml 문법에  |, -> 등을 사용하는데, 어떤 개행필요여부등 조금씩 차이가 있음
    script: |

    ## dockerconfig(secret) 이름의 workspace가 bound(연결) 되어 있을 경우, Docker registry 인증파일인 config.json 또는 .dockerconfig 파일 유무에 따라 대상 path를 DOCKER_CONFIG, DOCKER_CONFIG_AUTH 변수로 설정하여 Quay(Docker registry) 인증에 사용함
    ## dockerconfig secret을 workspace에 bound시켜서, 아래 스크립트를 통해, buildah 명령으로 argument를 통해 인증에 사용할 수 있고,
    ## Service account의 secret(annotation과함께)을 등록하여, 해당 secret을 통해, TASK 내 홈디렉토리에 자동으로 ~/.docker/dockcerconfig.json 파일을 생성하여,
    ## 별도, buildah 옵션에는 명시하지 않고, 기본 인증 위치를 참조하게 함으로 진행 할 수 있을것이다.
    ## 현재는 dockerconfig를 workspace로 지정하여, buildah의 환경변수로 사용하고 있음


      if [[ “$(workspaces.dockerconfig.bound)” == “true” ]]; then
    
          # if config.json exists at workspce root, we use that
          if test -f “$(workspaces.dockerconfig.path)/config.json”; then
            export DOCKER_CONFIG=“$workspaces.dockerconfig.path)”
            export DOCKER_CONFIG_AUTH=“—authfile $(workspaces.dockerconfig.path)/config.json”

          # else we look for .dockerconfigjson at the root
          elif test -f “$(workspaces.dockerconfig.path)/.dockerconfigjson”; then
            #cp “$(workspaces.dockerconfig.path)/.dockerconfigjson” “$HOME/.docker/config.json”
            export DOCKER_CONFIG=“$HOME/.docker”
            export DOCKER_CONFIG_AUTH=“—authfile $(workspaces.dockerconfig.path)/.dockerconfigjson”

          # need to error out if neither files are present
          else
            echo “neither ‘config.json’ nor ‘.dockerconfigjson’ found at workspace root”
            exit 1
          fi
        fi
    
    ## buildah 명령으로 컨테이너 이미지 빌드 (./Dockerfile.prd, 현재경로 . 에서 빌드함 )
      buildah --storage-driver=$(params.STORAGE_DRIVER) bud \
        $(params.BUILD_EXTRA_ARGS) --format=$(params.FORMAT) \
        $DOCKER_CONFIG_AUTH
        -tls-verify=$(params.TLSVERIFY) --no-cache \
        -f $(params.DOCKERFILE) -t $(params.IMAGE) $(params.CONTEXT)
     
      echo “———————————————————————————————————————————————————————————————————————————————————————————————————————“

        # download twistcli
        ## 취약점점검은 k8s내부에있는것으로 보임 —> router노드로 도메인이 resovling 됨
        curl -k -u ciuser:Kebhana1! -X GET -o twistcli
        ‘https://twistlock-console.cmap.bizcloudhana.com/api/v1/util/twsitcli’

        chmod a+x twistcli;

        # scanning image with twistcli

        ./twistcli images scan —address
        https://twistlock-console-cmap-bizcloudhana.com -u ciuser -p Kebhana1!
        —details —containerized $(params.IMAGE)
       
      echo “———————————————————————————————————————————————————————————————————————————————————————————————————————“

    ## SKIP_PUSH 값이 true라면, 빌드 후 push 하지않고 exit 0 함 (컨테이너 이미지 빌드만 확인하고자...할때, 활용하는 부분)
       [[ “$(params.SKIP_PUSH)“ == “true” ]]   && echo “Push skipped” && exit 0

    ## 빌드한 컨테이너 이미지를 내부 quay registry로 push 함
       buildah —storage-driver=$(params.STORAGE_DRIVER) push \
          $(params.PUSH_EXTRA_ARGS) —tls-verify=$(params.TLSVERIFY) \
          DOCKER_CONFIG_AUTH \
          —digestfile /tmp/image-digest $(params.IMAGE) \
          docker://$(prams.IMAGE)
    
    ## buldah push 할때, 이미지 digest 정보를 파일로 남긴 내용을 result.IMAGE_DIGEST 변수로 저장함
    ## buldah push 한 이미지 주소, result.IMAGE_URL 변수에 저장
        cat /tmp/image-digest | tee $(results.IMAGE_DIGEST.path)
        echo “$(params.IMAGE)” | tee $(results.IMAGE_URL.path)

    ## buildah 로 이미지 빌드하기 위해 특정 파일에 대한 권한과 특정 기능이 필요함으로 파일CAP 권한을 부여
    securityContext:
      capabilities:
        add:
            - SETFCAP

    ## /var/lib/containers 공간이 임시로 필요함 (buildah 이미지 빌드시, 이미지, 레이어가 저장되는 위치라고함)ㅣ
    volumeMounts:
    - name: varlibcontainers
      mountPath: /var/lib/containers

## 위에서 마운트한 volume은 workspace 아니고, emptyDir로 여기서만 바로 사용하기위해 volumes:를 사용함
  volumes:
  - name: varlibcontainers
    emptyDir: {}

  workspaces:
   - name: source-output
     name: dockerconfig
     optional: true




```