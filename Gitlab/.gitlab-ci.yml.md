 __`.gitlab-ci.yml.md`__

#### <b><span style="color:cyan">[스크립트 설명]</span></b>  
```bash
프로젝트 repository에 위치하여, 특정trigger조건(ex:dev브랜치 소스push)에 동작하는 CICD 파이프라인

```

#### <b><span style="color:cyan">[.gitlab-ci.yaml 스크립트]</span></b>
```yaml
## [stages: ]
## 실행의 단위인 job에 stage를 정의하며, job 실행순서는 stages: 에 stage의 정의하여 순서를 정함
## 동일 stage의 job은 병렬로 실행가능 (조건: job의 runner가 다르거나, 1개의 runner에 concurrent 설정이 2 이상일 경우)
## stages의 default 값 : .pre > build > test > deploy > .post
## 확인필요?? : stages에 명시되어 있지 않는 stage의 job 실행 유무 및 순서
## stages: 에 stage 가 명시되어있지만, stage를 사용하는 job이 없는 경우는 -> compliance 설정으로 hidden 상태임
## job은 존재하나, 명시된 stage가 없는경우, default로 test stage 로 들어감

## stages: 에 설정에 .gitlab-ci.yml 파일에 명시되지 않는 stage를 명시함 -> compliance pipeline 설정임.
## compliance pipeline 설정은 label된 프로젝트의 이 .gitlab-ci.yml 파일을 참조하여, 특정 job을 수행되도록 설정되어 있다.
## 해당 stage는 사용자에겐 보이지 않고, compliance 프로젝트에 설정과 관련된 다른 설정들이 있을것 같음, ※ 아래 참고
## 참고 : https://docs.gitlab.com/ee/tutorials/compliance_pipeline/index.html, https://docs.gitlab.com/ee/user/group/compliance_pipelines.html
stages:
  - feature-push
  - dev-merge

## [include: ] 
## 외부 프로젝트의 yaml 파일을 참조하도록 설정함 (위의 compliance pipeline 관련, 취약점 점검툴로 보임)
include:
  - project: 'CII/CFM/CFM'
    file: 'fortify.yml'

## 결론적으로 해석하면, CII/CFM/CFM 프로젝트의 fotify.yaml 에 feature-push, dev-merge stage에 대한 job과 실행되는 조건이 있을 것으로 예상됨


##########################################################
# 개발서버 빌드
##########################################################
## 확인필요? 전체적인 파이프라인 동작을 제어하는 workflow: 는 정의되어 있지 않음.. 각각의 job에 대한 조건만 명시되어 있음 

## build-dev JOB에 대한 내용을 정의함
## 해당 JOB은 build stage에 실행
## JOB 실행조건 : $CI_PIPELINE_SOURCE 파이프라인의 trigger컨디션 / $CI_COMMIT_BRANCH 커밋된 브랜치명
## 확인필요?? push이벤트에서는 실행안함 -(그러나)-> $CI_COMMIT_BRACH == dev 의미 : 어떤변경사항이 dev 브랜치에 push될때를 의미함
## dev로 merge 될때, 실행되는걸로 예상함.
build-dev:
  stage: build
  rules:
    - if: ($CI_PIPELINE_SOURCE == "push")
      when: never
    - if: ($CI_COMMIT_BRANCH == "dev")
      when: always

## Job별로 아티팩트 저장(4주) 가능 --> 용도 : 동일 stage의 Job 또는 다음 stage 에 사용하도록 저장 (중간빌드결과물 전달용도) 하거나, download 할수 있다.
  artifacts:
    paths:
      - build/libs/*.war
    expire_in: 4 week
## 의존성 관련 파일들 stage 또는 job별로 다운로드 하지 않고 사용할 수 있도록 정의 (성능개선)
  cache:
    paths:
      - build/
## 대상 JOB(빌드)를 실행하는 runner를 정의 / 이중화 되어 있다면, 빌드러너에는 tag를 정의하지 않고, yaml 파일에도 정의 하지 않으면, 알아서 이중화 되어 실행됨
  tags:
      - mse-hiscmcoid01
## gradle 빌드 수행
  script:
    - gradle —no-daemon -Pprofile=dev clean build

## GITLAB package registry에 빌드파일 버젼 관리를 위해 저장하는 curl 명령어
  # - 'curl —header "JOB-TOKEN: $CI_JOB_TOKEN" —upload-file ./build/libs/MSE.war ${CI_API_V4_URL}/projects/32/packages/generic/MSE/${CI_PIPELINE_ID}/MSE.war'

 ##########################################################
# 개발서버 배포
##########################################################

deploy-dev:
  stage: deploy
  rules:
    - if: ($CI_PIPELINE_SOURCE == "push")
      when: never
    - if: ($CI_COMMIT_BRANCH == "dev")
      when: always
  tags:
    - mse-himseapsd01

  scripts:
    # build stage 에서 만들어진 WAR 파일을 WAS 경로로 배포 (Exploded 방식)
    # 기존 소스코드 백업
    - rm -rf /cts/mseapp/backup/rev/mse
    - cp -R /cts/mseapp/webapp/mse /cts/mseapp/backup/prev/mse
    - chown -R gitlab-runner:mse /cts/mseapp/backup/prev/mse
    - echo "기존 소스코드 백업 완료 >> /cts/mseapp/bacup/prev"
  # 배포 준비
  - rm -rf /cts/mseapp/backup/current
  - mkdir -p /cts/mseapp/backup/currnet
 # 배포할 war 복사
  - cp ./build/libs/MSE.war /cts/mseapp/backup/current
  # war 압축해제
  - unzip /cts/mseapp/backup/current/MSE.war -d /cts/mseapp/backup/current/mse
  - chown -R gitlab-runner:mse /cts/mseapp/backup/current
  - chmod -R 770 /cts/mseapp/backup/current

  # 어플리케이션 배포
  - rm -rf /cts/mseapp/webapp/mse
  - cp -R /cts/mseapp/backup/current/mse /cts/mseapp/webapp/mse
  - chown -R gitlab-runner:mse /cts/mseapp/webapp/mse
  - chmod -R 770 /cts/mseapp/webapp/mse
 # DD 파일 복사 (weblogic설정에 맞게 어플리케이션 동작하도록 설정파일 복사)
  - cp -f /cts/mseapp/was/weblogic.xml /cts/mseapp/webapp/mse/WEB-INF/weblogic.xml
  - echo "배포완료 >> /cts/mse/webapp/mse"
  
# WAS 재기동 예약 (현재시간에서 5분후의 시간을 계산하여, mac_mse0.txt 파일에 기록 —> weblogic이  파일을 읽어 재기동하는것으로 예상)
  - remain=$(echo $(expr 5 - $(echo `date +%Y%m%d%H%M | cut -c 11-) % 5))
  - next=`date "-d %{remain} minute" +%Y%m%d%H%M`
  - hostname
  - echo "token,3,${next}" > /cts/mseapp/mac_mse0.txt
  - echo "WAS재기동예정시각 >> ${next}"


```

