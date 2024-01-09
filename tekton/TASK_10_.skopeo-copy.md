## __`TASK_10_skopeo-copy.md`__

#### <b><span style="color:cyan">[TASK 설명]</span></b>  
```bash

```

#### <b><span style="color:cyan">[TASK yaml 구문]</span></b> 
```yaml
apiVersion: tekton.dev/v1beta1
## 여러 프로젝트에서 일관된 작업이 가능하도록 clusterTASK로 생성함
kind: ClusterTask
metadata:
  name: skopeo-copy
  annotations: 
    operator.tekton.dev/last-applied-hash: e4b7cd1986860765df6e12e7b636258c298c191f784fc8e4b1d95630a42e551a
    tekton.dev/categories: CLI
    tekton.dev/displayName: skopeo copy
    tekton.dev/pipelines.minVersion: 0.12.1
    tekton.dev/platforms: ‘linux/amd64,linux/s390x,linux/ppc64le,linux/arm64’
    tekton.dev/tags: cli
  labels:
    app.kubernetes.io/version: ‘0.2’
    operator.tekton.dev/operand-name” openshift-pipeline-addons
    operator.tekton.dev/provider-type: redhat
spec:
  description: >-
    Skopeo is a command line tool for working with remote image registries.

    Skopeo doesn’t require a daemon to be running while performing its operations. In particular, the handy skopeo command called copy will ease the while image copy operation. The copy command will take care of copying the image from internal.registry to production.registry. If your production registry requires credentials to login in order to push the image, skopeo can handle that as well.

# TASK의 파라메터 선언
# name : 파라메터명 / type : string(문자열), array(배열) 등 / default : 파라메터에 값이 없을 경우, Default 파라메타값
# 앞선 파이프라인의 params: 와 파이프라인의 대상 TASK의 task.params에 선언된 파라메터가 있을경우, 해당 값을 가져옴
# skopeo copy를 위한 소스,타겟이미지명, 대상 registry를 https로 접근할 경우 인증서 verify 여부 flag등을 설정함
  params:
    - default: ‘’
       description: URL of the image to be copied to the destination registry
       name: srcImageURL
       type: string
    - default: ‘’
       description: URL of the image where the image from source should be copied to
       name: destImageURL
       type: string
    - default: ‘true’
       description: Verify the TLS on the src registry endpoint
       name: srcTLSverify
       type: string
    - default: ‘true’
       description: Verify the TLS on the dest registry endpoint
       name: destImageURL
       type: string


  steps:
  # params 세션에서 파라메터를 정의했지만, 실제 TASK 수행시 사용할 변수를 steps,env에 새로 변수선언/값을 정의함 (params:의 파라메터값일 수도 있고, 사용자정의값 등 하기 나름)
  # 이렇게 TASK 수행시 변수 (예: HOME)로 정의하기도 하고, 바로 params의 파라메터 (예 : $(params.파라메터명))를 사용할 수 있음
  # 이부분은 추측인데, TASK params:에도 정의되어 있지 않아도, 앞선 파이프라인의 대상 TASK의 task.params가 정의되어 있다면, $(inputs.params.파라메터명) 으로 그 값을 바로 사용 할 수 있을 것으로 예상
    - env:
        - name: HOME
          value: /tekton/home
    
  # TASK의 컨테이너 이미지명을 정의 (skopeo 명령이 설치된 전용 이미지 사용)   
      image: ‘hubp-quay-registry.apps.hubp.infra.io/cicd-images/skopeo:8.7-5’
      name: skopeo-copy

  
      script: >
          # Function to copy multiple images.

    ## copyimages()함수를 작성함
    ## image-url workspace 에 존재하는 url.txt 파일을 한줄(소스이미지url, 타겟이미지url)씩 읽어  cmd 1개로 받아 multiple images를 copy
    ## image-url 은 empty-dir 로 현재 파이프라인환경에는 별도의 파일을 가지고 있진않음(사용안됨)
          copyimages() {
            filename=“$(workspaces.image-url.path)/url.txt”
            ## $filename(url.txt)을 1줄씩 읽고, 해당 라인이 공백이 아닐때까지..while문 수행
            while IFS= read -r line || [ -n “$line” ]
            do
              cmd=“”
              for url in $line
              do
                cmd=“$cmd \
                      $url”
              done

            ## skopeo 명령을 통해 --> 방금 빌드한 컨테이너 이미지를 ---> DR quay 이미지로 복사 (동기화)
            ## 컨테이너 이미지를 DR quay에 복사 // GITLAB에서 사설인증서를 사용하여, https로 접근할 경우, verify는 false 설정이 필요함
              skopeo copy “$cmd” —src-tls-verify=“$(params.srcTLSverify)” —dest-tls-verify=“$(params.destTLSverify)”
              echo “$cmd”
            done < “$filename”
          }

    ## 변수가 선언되어 있으면 방금 빌드하여 push 한 컨테이너 이미지를 skopeo 명령으로 DR quay 에 복사하고,
    ## 변수가 선언되어 있으면 copyimages() 함수를 실행하여 multiple skopeo 이미지 copy를 수행함
          # If single image is to be copied then, it can be passwd through
          # params in the taskrun.
          if [ “$(params.srcImageURL)” != “” ] && [ “$(params.destImageURL)” != “” ] ; then
            
            ## skopeo 명령을 통해 --> 방금 빌드한 컨테이너 이미지를 ---> DR quay 이미지로 복사 (동기화)
            ## 컨테이너 이미지를 DR quay에 복사 // GITLAB에서 사설인증서를 사용하여, https로 접근할 경우, verify는 false 설정이 필요함
            skopeo copy “$(params.srcImageURL)” “$(params.destImageURL)” —src-tls-verify=“$(params.srcTLSverify)” —dest-tls-verify=“$(params.destTLSverify)”
          else
            #If file is provided as a configmap in the workspace then multiple images can be copied.
            copyimages
          fi

  ## 실행되는 TASK(컨테이너) 권한을 제어하고자 655321 UID로 설정
  ## 655321, 655324 같은 UID는 nobody같은 계정권한으로 최소권한을 할당하는 의미와 유사한듯
      securityContext:
        runAsNonRoot: true
        runAsUswer: 65532

## emtpydir{}로 만든 workspace를 사용하나, 현재 사용안함 
## 만약 사용하게 된다면, emptydir{} 볼륨이라서 url.txt 파일을 사전정의하지 않는데, 어떻게 사용될수 있는지.. logic은 모르겠음
workspaces:
  - name: image-url




```