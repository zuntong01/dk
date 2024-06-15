 __`Jenkinsfile.md`__

#### <b><span style="color:cyan">[스크립트 설명]</span></b>  
```bash
Jenkins의 CICD 파이프라인 (grovvy 기반 작성방식을 따름)
(Jenkins의 Job으로 빌드배포 가능하나, 
각 stage별 TASK를 정의하여 빌드/배포 스크립트를 작성하여 파이프라인 구성/실행하면 각 단계별 시각화도 가능) 

 - jenkins 파이프라인 코드 : 1. 스크립트 파이프라인 / 2. 선언형 파이프라인 
        : 이 스크립트는 선언형 파이프라인으로 작성되어 있음 (비교적쉽게 작성 가능)
 - jenkins 파이프라인 적용방식 
        : 프로젝트 소스내 Jenkinsfile 포함시켜,적용하거나 // jenkins 각 파이프라인 설정화면에서 직접작성가능
```

#### <b><span style="color:cyan">[jenkinsfile 파이프라인 스크립트 BD-TAMS-SA-PROD]</span></b>
```xml

<!-- pipeline : 선언형 파이프라인의 시작은 pipeline으로 시작해야함 
	agent any :  jenkins에서 파이프라인을 실행할 agent 노드를 어디로 할지 지정 (single 구성시 built-in node 1개 존재)
        environment { name = 'GAAI.war' } : 파이프라인 전역 환경변수 지정
	    tools : 파이프라인에 빌드할 도구에 대해 설정 (Jenkins관리/Tools에 지정한 이름 또는 PATH를 지정함
                ※ 지원하는 Tools : maven, jdk, gradle, git 등
-->
pipeline {
    agent any
    environment {
        name = 'GAAI-SA.war'
    }
    tools {
        maven 'LGE_MAVEN'
        jdk 'LGE_JAVA'
        ant 'LGE_ANT'
    }

<!-- stages : 파이프라인의 중심 로직을 정의하는 각각의 stage를 묶는 섹션
	stage('Ready') : Ready 라는 파이프라인 stage를 정의 (jenkins는 stage를 인터페이스에 표시함)
		steps { } : 원하는 작업을 기술함
-->         
    stages {
        
         stage('Ready') {
             steps {
             echo 'kill process!'
             }
         }

<!--	stage('Checkout') : 빌드를 위한 사전소스 체크아웃 (사전정의된 스크립트언어가 있으나, 여기서는, svn co 명령을 직접 실행함) 
                            ※ snippet generator에서 생성가능 : 예) steps { checkout([$class: 'SubversionSCM', locations: [[credentialsId: '크리덴셜ID', depthOption: 'infinity', local: '.', remote: 'svn://10.185.246.78/NTAMS/trunk/GAAI_ServiceAccess']]]) }
-->          
        stage ('Checkout') {
            steps {
                echo 'Checkout'
                sh "rm -rf GAAI_ServiceAccess"
                sh "yes | /sorc001/appadm/ciserv/svn/bin/svn co --username admin --password admin svn://10.185.246.78/NTAMS/trunk/GAAI_ServiceAccess"
            }
        }
        
<!--	stage('Deploy') : ant를 통해 운영서버 배포를 수행
                          ※ build_prod.xml에 정의된 deploy TASK를 수행
-->               
        stage('Deploy') {
            steps {
                echo 'Deploy'
                sh "ant -buildfile GAAI_ServiceAccess/build_prod.xml all"
            }
        }
    }
}



```