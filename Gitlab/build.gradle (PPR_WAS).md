 __`gradle.build.md`__

#### <b><span style="color:cyan">[스크립트 설명]</span></b>  
```bash


```

#### <b><span style="color:cyan">[gradle.build 스크립트]</span></b>
```json
// [buildscript] 설정 : gradle 자체를 위한 것이고, gradle이 빌드를 수행하는 방법에 대해 명시 / sprintboot 플러그인을 실행 할 수 있는 기본 바탕 정의
// ext : 전역변수 설정
// dependencies : 빌드 자체를 위해 필요한 springboot 플러그인의 클래스패쓰 의존성을 지정 (buildscript 밖의 dependencies는 소스컴파일때 사용되는 라이브러리)
buildscript {
  ext {
    springBootVersion = '2.7.13'
    devonBootVersion = '2.1.2'

    devonBootEntVersion = '1.1-SNAPSHOT'
    
    mavenUrl = "http://10.76.5.131:8081"
  }
  repositories {
    maven {
      credentials {
        username devonMavenUser
        password devonMavenPassword
        }
        url = uri("${mavenUrl}/repository/maven-releases/")
        allowInsecureProtocol = true
    }
  }
  dependencies {
    classpath("org.springframework.boot:spring-boot-gradle-plugin:${springBootVersion}")
  }
}

// 소스 빌드의 의존성을 해결하기 위해, 어떤 저장소를 사용할지에 대한 설정 진행 
// username과 password는 gradle.properties에서 설정함
repositories {
  maven {
    credentials {
      username devonMavenUser
      password devonMavenPassword
    }
    url = uri("${mavenUrl}/repository/maven-releases/")
    allowInsecureProtocol = true
  }
  maven {
    credeentials {
      username devonMavenUser
      password devonMavenPassword
    }
    url = uri("${mavenUrl}/repository/maven-snapshots/")
    allowInsecureProtocol = true
  }
}

//프로젝트의 groupID (다른프로젝트 충돌방지, 일반적으로 도메인이름 역순)
//또한 여러 프로젝트(PPR_WAS, PPR_BAT)를 동일그룹으로 설정하여 의존성관리 (특정프로젝트 기능을 사용하거나, 클래스참조 등) 을 함께 할수 있음
group 'com.hanabank.ppr'

// sourceCompatibility : 프로젝트 소스를 컴파일하는 JDK 버전
// targetCompatibility : class 파일의 호환 JVM 버전
sourceCompatibility = '1.8'
targetCompatibility = '1.8'

// 프로젝트에서 사용하는 gradle plugin 추가 (java 프로젝트 빌드를 위한 플러그인, spring boot 의존성버전 자동관리하는 플러그인 등)
apply plugin: 'io.spring.dependency-management'
apply plugin: 'java'
apply plugin: 'java-library'
apply plugin: "eclipse-wtp"


//[compileJava, compileTestJava]라는 이름으로 시작하는 모든 TASK 유형에 인코딩 설정]
[compileJava, compileTestJava]*.options*.enconding = 'MS949'

// JavaCompile TASK의 특정유형에 해당하는 모든TASK (예:compileJava, compileTestjava) 에 컴파일러 경고 메시지를 비활성화하는 옵션
tasks.withType(javaCompile) {
  options.compilerArgs << '-Xlint:none'
}

// dev.boot그룹에 속하는 종속성 버젼을 2.1.0 으로 관리해서, dependancies 항목에서 해당 종속성을 정의할때, 버젼은 따로 명시하지 않아도됨.
dependencyManagement {
  imports {
    mavenBom "devon.boot:devon-boot-dependencies:${devonBootVersion}"
  }
}

// [configurations.all] 설정 : Gradle 빌드스크립트에 정의된 모든 구성에 대해 적용되는 설정 블럭
// [resolutionStrategy] 설정 : 종속성 해결에 관한 전략 정의 (특정종속성버젼, 대체, 충돌해결, 또는 snapshot 시간초과를 강제함)
// 변경가능한 모듈을 캐시하지 않고 매번 다운로드함 
configurations.all {
  // Check for updates every build
  resolutionStrategy.cacheChangingModulesFor(0, "seconds")
}

// [dependencies] 설정 : repository에서 필요한 라이브러리를 사용할 수 있도록 설정
// * compileOnly : 컴파일시에만 필요한 종속성 지정 (테스트 라이브러리나, 컴파일시에만 필요한 도구)
// * implementation : 컴파일, 런타임 단계에서, 필요한 종속성 지정
// * runtimeOnly : 런타임(응용프로그램) 실행시에만 필요한 종속성 지정
// * annotationProcessor : 컴파일시에만 필요, 컴파일시 소스코드에 작성된 어노테이션을 처리, 새로운 소스파일을 생성하거나 코드를 수정함
dependencies {
  compileOnly 'devon.boot:devon-boot-starter'
  compileOnly "devon.boot:devon-boot-enterprise-starter:${devonBootEntVersion}"
  compileOnly 'devon.boot.devon-boot-starter-log4j2'
  compileOnly fireTree( dir: './lib' , include: ['*.tar'] )
  annotationProcessor 'org.projectlombok:lombok:1.18.24'
  compileOnly 'org.projectlombok:lombok:1.18.24'
}

configurations {
  all {
    exclude group: 'org.apache.logging.log4j', module: 'log4j-to-slf4j'
    exclude group: 'ch.qos.logback', module: 'logback-classic'
    exclude group: "org.apache.tomcat.embed"
    // exclude group: lena
    exclude group: "org.springframework.boot", modle: "spring-boot-starter-tomcat"
  }
}

// 여기 하위부터 [PPR] gradle.build 파일과 다른 부분임
dependancies {
  implementation 'devon.boot:devon-boot-starter'
  implementation "devon.boot:devon-boot-enterprise-starter:${devonBootEntVesions}"
  implementation "devon.boot:devon-boot-enterprise-agent-was:${devonBootEntVersion}"
  implementation 'org.springframework.boot:spring-boot-starter-actuator'
  implementation 'com.github.ulisesbocchio:jasypt-spring-boot-starter:3.0.4'
  compileOnly files('./libnfsrv_gw_1.1.jar')
  annotationProcessor 'org.projectlombok:lombok:1.18.24'
  compileOnly 'org.projectlombok:lombok:1.18.24'
  compileOnly 'javax.servlet:javax.servlet-api'

  runtimeOnlu 'org.yaml:snakeyaml:2.0'

  implementation 'com.fasterxml.jackson.core.:jackson-core:2.15.2'
  implementation 'com.fatsterxml.jackson.core:jackson-databind:2.15.2'
  implementation 'com.fasterxml.jackson.core:jackson-annoations:2.15.2'

  runtimeOnly 'org.glassfish.javxb:jaxb-runtime:2.3.6'
  runtimeOnly 'org.glassfish.jaxb:txw2:2.3.6'

  // 동일그룹 (com.hanabank.ppr)의 다른 프로젝트인 PPR 를 종속성 추가 (PPR 프로젝트코드, 리소스사용가능함)
  // 현재 프로젝트가 PPR이라는 다른 gradle 프로젝트에 의존하고 있음을 나타냄 (현재프로젝트 빌드할때, Gradle PPR프로젝트도 함께 빌드함)
  // implementation ;com.hanabank.ppr:PPR'
  implementation project('PPR')
}

// Eclipse플러그인을 사용하여, 웹프로젝트의 컨텍스트 경로를 설정 (이설정은 Eclipse IDE에서 프로젝트를 웹어플리케이션으로 인식하고 실행할때 사용)
// Eclipse 에서 Gradle 프로젝트를 Import 할때, 해당 프로젝트가 웹어플리케이션으로 인식되어 톰캣과 같은 웹서버에서 실행할수 있도록 도와줌
eclipse {
  wtp {
    component {
      contextPath = "ppr"
      }
    }
}

configurations {
  all {
      exclude group: 'net.sf.ehache', module: 'ehcache'
      exclude group: 'org.apache.logging.log4j', modlue: 'log4j-to-slf4j'
      exclude group: 'ch.qos.logback', module: 'logback-classic'
      exclude group: "org.apache.tomcat.embed"
      //exclude group: "lena"
      exclude group: "org.springframework.boot", modle: "spring-boot-starter-tomcat"
      exlcude group: "org.springframework.boot", module: "spring-boot-starter-data-redis"
      exclude group: "org.springframwork.cloud", modle: "spring—cloud-starter-openfeign"
      exlcude group: 'org.jboss.logging', module: 'jboss-logging'
      exclude group: org.hiberneate.validator', modle: 'hibernate-validator'
      exlcude group: 'javax.xml.stream', module: 'stax-api'
    }
 }


//이설정은 기본적으로 Gradle 에서 war 파일을 생성하지 않도록 설정
war {
  enabled = false
}

//spring boot 어플리케이션을 위한 Gradle 플러그인으로 War파일을 생성하도록 설정
// 생성되는 War 파일의 기본이름을 PPR로 설정, 기본이름에 파일확장자, war를 추가하여 최종이름을 정의함
bootWar {
  baseName = 'PPR'
  archiveName = 'PPR.war'
}



```

