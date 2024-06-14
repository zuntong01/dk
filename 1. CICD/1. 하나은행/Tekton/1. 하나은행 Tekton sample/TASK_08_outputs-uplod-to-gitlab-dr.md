## __`TASK_08_outputs-uplod-to-gitlab-dr.md`__

#### <b><span style="color:cyan">[TASK 설명]</span></b>  
```bash
지난TASK에 생성한 MSE_CNT 프로젝트의 빌드파일을 --> GITLAB의 pakcage registry에 업로드
```

#### <b><span style="color:cyan">[TASK yaml 구문]</span></b> 
```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: outputs-upload-to-gitlab-dr
  namespace: cma-p-ocn-ocr
spec:
# TASK의 파라메터 선언
# name : 파라메터명 / type : string(문자열), array(배열) 등 / default : 파라메터에 값이 없을 경우, Default 파라메타값
# 앞선 파이프라인의 params: 와 파이프라인의 대상 TASK의 task.params에 선언된 파라메터가 있을경우, 해당 값을 가져옴
# Gitlab pakcage registry에 빌드파일 업로드를 위한 파라메터 설정 (gitlab project ID,gitalb pakcage registry ID, GILAB API URL 등)
  params:
     - default: .
        description: The directory containging build.gradle
        name: PROJECT_DIR
        type: string
      - default: token
        name: TOKEN
        type: string
      - name: BEFORE_APPNAME
        type: string
      - name: AFTER_APPNAME
        type: string
      - name: EXT
        type: string
      - name: PROJECT_URL
        type: string
      - name: PROJECT_ID
        type: string
      - name: PACKAGE_ID
        type: string

  steps:
    # TASK의 컨테이너 이미지명을 정의 (curl명령어만 가능하면 됨. 기본 ubi이미지 사용)
    - image: >-
        hubp-quay-registry.apps.hubp.infra.io/cicd-imags/tekton-task-ubi-minimal:8.3-jq
      name: outputs-upload-to-gitlab-dr-tasks


      script: >
        #!/usr/bin/env bash
    # Configure Gitlab Package TOKEN 
    ## 현디렉토리 위치 및 파일 확인 (workspace/source-output)
        pwd
        ls -l
    ## workspace/source-output/MSE_CNT/build/libs 하위에 빌드jar파일(app.jar) 있는지 확인
        ls -la $(params.PROJECT_DIR)/build/libs/

    ## cma-p-ocn-ocr-secret-tkn(secret-quay인증용)을 private-token workspace 로 마운트하여, cat passwd파일하여, GITLAB API에서 사용할 TOKEN을 변수로 설정
        if [[ “$(workspaces.private-token.bound)” == “true”]/]; then
          # if config.json exists at workspace root.we use that
          if test -f “$(workspaces.privatet-token.path)/password”; then
            export TOKEN=`cat $(workspaces.private-token.path)/password`
          fi
        fi

        echo “TOKEN : “ ${TOKEN}
    
    ## GITLAB MSE_CNT프로젝트(id:295)에 있는 MSE_CNT 이름의 package resgiry를 $SEARCH_PACKGE 변수에 넣음
    ## GITLAB이 사설인증서를 사용하여, https를 쓸 경우, -k 옵션으로 인증서 검증을 하지 않도록 설정 필요
        SEARCH_PACKAGE=$(curl -s --header “PRIVATE-TOKEN: ${TOKEN}”
        “$(params.PROJECT_URL)/projects/$(params.PROJECT_ID)/packages” | jq ‘.[] | select(.name == “$(params.AFTER_APPNAME)”)’)

        ## 사용예시 : curl -s --header "PRIVATE-TOKEN: glpat-xfGx5wctoSSTP2GPJaaz" http://10.77.247.120.9080/api/v4/projets/295/packages | jq ‘.[] | select(.name == MSE_CNT)')

        echo “[$SEARCH_PACKAGE]”

    ## $SEARCH_PACKAGE 에 MSE_CNT package_registry 정보가 있을 경우, 
    ## 이번 파이프라인에서 빌드한 파일을 MSE_CNT.jar 파일을 GITLAB MSE_CNT프로젝트(id:295), MSE_CNT pkg registry(id:2991, 0버젼)에 업로드 하고,
    ## 직전 빌드파일(id:5991)을 삭제함
        if [[ $SEARCH_PACKAGE == *”$(params.AFTER_APPNAME)”* ]/]; then
          echo -e “\n”
          echo “기존패키지파일이 존재(PACKAGE_ID) 하기에 신규파일 업로드 후, 기존 파일을 삭제합니다.”
    
        ## curl을 통해, GITLAB MSE_CNT프로젝트(id:295), MSE_CNT pkg registry(id:2991) 에서 업로드된 빌드파일들의 파일id 값을 변수에 넣음 (직전빌드파일삭제위해 정보저장 )
        ## GITLAB이 사설인증서를 사용하여, https를 쓸 경우, curl -k 옵션으로 인증서 검증을 하지 않도록 설정 필요
          PACKAGE_FILE=$(curl -s --header “PRIVATE-TOKEN: ${TOKEN}” "$(params.PROJECT_URL)/projects/$(params.PROJECT_ID)/packages/$(params.PACKAGE_ID)/package_files")
          PACKAGE_FILE_ID=$(echo “PACKAGE_FILE” | jq -r ‘.[0].id’)
          ## 사용예시 : curl -s --header "PRIVATE-TOKEN: glpat-xfGx5wctoSSTP2GPJaaz" http://10.77.247.120.9080/api/v4/projects/295/packages/2991/pacakge_files

        ## curl을 통해, GITLAB MSE_CNT프로젝트(id:295), MSE_CNT pkg registry(id:2991)에 /workspace/source-output/MSE_CNT//build/libs/app.jar 파일을 MSE_CNT.jar파일로 업로드
          curl -s —header “PRIVATE-TOKEN: ${TOKEN}” —upload-file $(params.PROJECT_DIR)/build/libs/$(params.BEFORE_APPNAME).$(params.EXT) “$(params.PROJECT_URL)/projects/$(params.PROJECT_ID)/packages/generic/$(params.AFTER_APPNAME)/0/$(params.AFTER_APPNAME).$(params.EXT)”
          
          ## 사용예시 : curl -s --header "PRIVATE-TOKEN: glpat-xfGx5wctoSSTP2GPJaaz" —upload-file ./MSE_CNT/build/libs/app.jar http://10.77.247.120.9080/api/v4/projects/295/pakcages/generic/MSE_CNT/0/MSE_CNT.jar

            ## 직전빌드파일이 있을경우, 해당 파일 삭제
              if [ -n $PACKAGE_FILE_ID ]; then
                curl -s --request DELETE --header “PRIVATE-TOKEN: ${TOKEN}” “$(params.PROJECT_URL)/projects/$(params.PROJECT_ID)/packages/$(params.PACKAGE_ID)/package_files/$PACKAGE_FILE_ID”
                
                ## 사용예시 : curl -s --request DELETE --header "PRIVATE-TOKEN: glpat-xfGx5wctoSSTP2GPJaaz"  http://10.77.247.120.9080/api/v4/projects/295/packages/2991/package_files/5991
                
                echo -e “\n”
                echo “이전 Packge File : $ PACKAGE_FILE_ID 이 삭제되었습니다.”
              else
                echo -e “\n”
                echo “패키지에 파일이 존재하지 않습니다.”
       fi
    
    ## 기존에 package registry(MSE_CNT, id:2991)가 없다면, 빌드파일만 업로드하고, 업로드하면서 생성된 package registry ID를 파이프라인의 paramater에 PACKAGE_ID 에 직접설정필요
       else
       curl -s —header “PRIVATE-TOKEN: ${TOKEN}” —upload-file “$(params.PROJECT_DIR)/projects/build/libs/$(params.BEFORE_APPNAME).$(params.EXT) “$(params.PROJECT_URL)/projects/$(params.PROJECT_ID)/packages/generic/$(params.AFTER_APPNAME)/0/$(params.AFTER_APPNAME).$(params.EXT)”

       ID=$(curl -s —header “PRIVATE-TOKEN: ${TOKEN}” “$(params.PROJECT_URL)/projects/$(params.PROJECT_ID)/packages” | jq ‘.[] | select(.name == “$(params.AFTER_APPNAME)”)’ | grep ‘id’ | grep -o ‘[0-9]*’ | sed ‘s/ //g’)
       echo -e “\n”
       echo “패키지를 생성(PACKAGE_ID) 합니다”
      fi
    
    ## TASK가 실행될때, 시작되는 현재 경로를 /workspace/source-output 에서 시작함
    workingDir: $(workpsaces.source-output.path)


workspaces:    ## TASK 가 사용할 영구스토리지 (trigger-tempate 에 pvc가 설정되어 있음)
  - description: The workspace consisting of the git source project.
    name: source-output

  ## cma-p-ocn-ocr-secret-tkn(secret-quay인증용)을 private-token workspace 로 사용
  - description: The workspace consisting of the private token.
    name: private-token
    optional: true


```