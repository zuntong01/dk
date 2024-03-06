 __`gradle.properties.md`__

#### <b><span style="color:cyan">[파일 설명]</span></b>  
```bash
IaaS 환경 배포를 위해 Gradle 설정은 /sw/cicdadm/.gradle/gradle.properties 위치에 작성했음 (소스에 포함되지 않음)
--> 빌드서버는 gitlab-runner 가 cicdadm 으로 실행되기 때문에, ---> gradle build의 기본 

※ 각종 빌드 옵션이나 외부 프로젝트 경로를 gradle.properties 파일에 설정해두고,
build.gradle에서 이를 참조하도록 설정하면 빌드를 관리하기가 편하다. 
그러나 여러 명이 다양한 환경에서 개발하게될 경우, gradle.properties 파일이 버전관리 시스템에 들어가면 매우 불편한 상황이 생길수있음.


```

#### <b><span style="color:cyan">[gradle.properties 파일]</span></b>
```bash

#put this file ~/.gradle/gradle.properties
#also can use : -PdevonMavenUser=admin -PdevonMavenPassword=goodpeople@

## Maven 저장소에 액세스하기 위한 사용자 이름과 비밀번호를 설정
devonMavenUser=cfwmon
devonMavenPassword=abcd12345

# Default value: -Xmx10248m -XX:MaxPermSize=256m
#org.gradle.jvmargs=-Xmx2048   -XX:MaxPerSize=512m   -XX:+HeapDumpOnOutOfMemoryError   -Dfile.enconding-UTF-8

## Gradle 빌드 도구가 실행될 때 사용될 JVM 인자를 설정
org.gradle.jvmargs=-Xmx4096m   -XX:MaxPermSize=4096m   -XX:+HeapDumpOnOutOfMemoryError

## Gradle 자체의 설정을 조정 
## Gradle 캐싱을 비활성화하고, Gradle 데몬을 비활성화하며, 캐싱 스냅샷을 비활성화 설정
org.gradle.caching=false
org.gradle.daemon=false
org.gradle.caching.snapshots=false



```

