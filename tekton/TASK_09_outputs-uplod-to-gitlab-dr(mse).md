## __`TASK_09_outputs-uplod-to-gitlab-mse-dr.md`__

#### <b><span style="color:cyan">[TASK 설명]</span></b>  
```bash
지난TASK에 생성한 MSE 프로젝트의 빌드파일을 --> GITLAB의 pakcage registry에 업로드
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
      - name: BEFORE_APPNAME_MSE
        type: string
      - name: AFTER_APPNAME_MSE
        type: string
      - name: EXT
        type: string
      - name: PROJECT_URL_MSE
        type: string
      - name: PROJECT_ID_MSE
        type: string
      - name: PACKAGE_ID_MSE
        type: string
     - name: PROJECT_NAME_MSE
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
        echo “[$(params.PROJECT_NAME_MSE)]”  
    ## workspace/source-output/MSE/build/libs 하위에 빌드jar파일(app.jar) 있는지 확인
        ls -la $(params.PROJECT_DIR)/build/libs/        
        ls -l $(params.PROJECT_NAME_MSE)/build/libs/

      ## 참고 : MSE/build/libs/MSE-P0.0.1-SNAPSHOT.jar 빌드파일이 생성되어 있고
      ## 참고 : MSE_CNT/build/libs/app.jar 빌드파일이 생성되어 있는 상태임
      ## MSE-P0.0.1-SNAPSHOT.jar 빌드결과물을 Gitlab registry에 업로드전에 mse.jar로 rename 함
        if [ -f $(params.PROJECT_NAME_MSE)/build/libs/$(params.PROJECt_NAME_MSE)-P*-SNAPSHOT.jar]; then
           cp ./MSE/build/libs/MSE-P-*-SNAPSHOT.jar ./MSE/build/libs/mse.jar
        else
          echo “/MSE/build/libs/MSE-P*-SNAPSHOT.jar MSE/build/libs/mse.jar not found.”
        fi

        ## basic-auth 타입 secret 에 password(Gitlab인증토큰) 파일로 mount 되어있고 —> 해당값을 TOKEN 변수에저장
        if [[ “$(workspaces.private-token.bound)” == “true”]/]; then
          # if config.json exists at workspace root.we use that
          if test -f “$(workspaces.privatet-token.path)/password”; then
            export TOKEN=`cat $(workspaces.private-token.path)/password`
          fi
        fi
        echo “TOKEN : “ ${TOKEN}

        ##  ID 295(MSE) 프로젝트에서 MSE 이름의 pkgregistry 가 있는지 찾고, 출력되는 정보를 변수에 저장 
        SEARCH_PACKAGE=$(curl -s — header “PRIVATE-TOKEN: ${TOKEN}”
        “$(params.PROJECT_URL)/projects/$(params.PROJECT_ID_MSE)/packages” | jq ‘.[] | select(.name == “$(params.AFTER_APPNAME_MSE)”)’)
        echo “[$SEARCH_PACKAGE]”
        ## 사용예시 : curl -s --header "PRIVATE-TOKEN: glpat-xfGx5wctoSSTP2GPJaaz" http://10.77.247.120.9080/api/v4/projects/295/packages/2998/pacakge_files

        ## MSE 명의 pkg registry에 존재한다면, 신규빌드파일을 업로드하고, 기존빌드파일은 Packagefile ID로 검색하여 삭제함 (tekton 관련없지만 ecams CICD솔루션이 Gitlab에서 가져가기 위한 절차인듯함) 
        if [[ $SEARCH_PACKAGE == *”$(params.AFTER_APPNAME_MSE)”* ]/]; then
          echo -e “\n”
          echo “=================================================================================“
          echo “기존패키지파일이 존재(PACKAGE_ID) 하기에 신규파일 업로드 후, 기존 파일을 삭제합니다.”
          echo “=================================================================================“
          
          ## ID 295(MSE) 프로젝트에서 ID 2988(MSE) Registry내의 빌드파일들의 ID(packagefile ID)를 변수에 저장
          PACKAGE_FILE=$(curl -s —header “PRIVATE-TOKEN: ${TOKEN}” “$(params.PROJECT_URL_MSE)/projects/$(params.PROJECT_ID_MSE)/packages/$(params.PACKAGE_ID_MSE)/package_files”) 
          PACKAGE_FILE_ID=$(echo “PACKAGE_FILE” | jq -r ‘.[0].id’)

          ## GITLAB API 를 통해, rename한 mse.jar파일을 —-> 294[MSE] project, MSE pckage registry의 0버젼의 mse.jar로 업로드
          curl -s —header “PRIVATE-TOKEN: ${TOKEN}” —upload-file $(params.PROJECT_NAME_MSE)/build/libs/$(params.BEFORE_APPNAME_MSE).$(params.EXT) “$(params.PROJECT_URL_MSE)/projects/$(params.PROJECT_ID)/packages/generic/$(params.AFTER_APPNAME_MSE)/0/$(params.AFTER_APPNAME_MSE).$(params.EXT)”

          ## 사용예시 : curl -s --header "PRIVATE-TOKEN: glpat-xfGx5wctoSSTP2GPJaaz" —upload-file ./MSE/build/libs/mse.jar http://10.77.247.120.9080/api/v4/projects/295/pakcages/generic/MSE/0/mse.jar

              ## 업로드전에 업로드된 빌드파일(PACKAGE_FILE_ID)이있다면, 해당 버젼은 삭제
              if [ -n $PACKAGE_FILE_ID ]; then
                curl -s —request DELETE —header “PRIVATE-TOKEN: ${TOKEN}” “$(params.PROJECT_URL_MSE)/projects/$(params.PROJECT_ID_MSE)/packages/$(params.PACKAGE_ID_MSE)/package_files/$PACKAGE_FILE_ID”

                ## 사용예시 : curl -s --request DELETE --header "PRIVATE-TOKEN: glpat-xfGx5wctoSSTP2GPJaaz"  http://10.77.247.120.9080/api/v4/projects/295/packages/2998/package_files/5998

                echo -e “\n”
                echo “================================================“
                echo “이전 Packge File : $ PACKAGE_FILE_ID 이삭제되었습니다.”
                echo “================================================“
              else
                echo -e “\n”
                echo “패키지에 파일이 존재하지 않습니다.”
       fi
       else
       ## 기존에 업로드 빌드파일이 package registry가 없다면, 파일만 업로드함
       curl -s —header “PRIVATE-TOKEN: ${TOKEN}” —upload-file “$(params.PROJECT_NAME_MSE)/projects/build/libs/$(params.BEFORE_APPNAME_MSE).$(params.EXT) “$(params.PROJECT_URL_MSE)/projects/$(params.PROJECT_ID)/packages/generic/$(params.AFTER_APPNAME_MSE)/0/$(params.AFTER_APPNAME_MSE).$(params.EXT)”

       ID=$(curl -s —header “PRIVATE-TOKEN: ${TOKEN}” “$(params.PROJECT_URL_MSE)/projects/$(params.PROJECT_ID_MSE)/packages” | jq ‘.[] | select(.name == “$(params.AFTER_APPNAME)_MSE”)’ | grep ‘id’ | grep -o ‘[0-9]*’ | sed ‘s/ //g’)
       echo -e “\n”
       echo “========================“
       echo “패키지를 생성(PACKAGE_ID) 합니다”
       echo “========================“
       echo “생선한 PACKAGE ID는 $ID 입니다. 이후 파이프라인 전체 yaml에서 하드코딩된 값을 반드시 $ID로 수정하세요”
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