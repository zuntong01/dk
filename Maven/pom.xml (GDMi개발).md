 __`pom.xml.md`__

#### <b><span style="color:cyan">[스크립트 설명]</span></b>  
```bash
maven 빌드를 하기위한 빌드스크립트 (maven 프로젝트 빌드를 위한 설정파일)
프로젝트가 어떤 의존성을 사용할 건지, 프로젝트를 통해 어떤동작(컴파일, 프로젝트실행, 배포등)을 설정하는 곳
```

#### <b><span style="color:cyan">[pom.xml (GDMi개발) 스크립트]</span></b>
```xml
<!-- 
  <project섹션> : Maven 프로젝트의 기본적인 구조를 정의합니다. XML 네임스페이스와 스키마 정보를 포함하여 Maven이 이 파일을 올바르게 파싱하고 검증할 수 있는 정보를 제공
    ※ POM파일임을 정의(xmlns) 하고, XML문서가 스키마참조(xmlns:xsi)하도록 하고, 스키마 파일의 위치(xsi:schemaLocation)를 정의하여 pom.xml 파일의 구조를 검증하도록 함 
-->    
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

<!--
    Maven 프로젝트의 메타데이터를 정의
        <modelVersion> 현재사용하는 Maven Pom 모델 정의(4.0.0 버젼을 널리사용 / 작성된 형식과 버젼맞지 않으면 제대로된 해석못할수 있음) 
        <groupId><artifactId><version> : 프로젝트식별 및 버젼 정의 (도메인(역순)/프로젝트명/버젼) - 해당 네이밍으로 nexus 저장소에서 파일을 식별하는 구분자로 사용
        <packaging> : 빌드결과물 형식정의 - 실제 빌드결과물을 정의함 (예 : jar, war, ear 등)
        <name> : 프로젝트이름 - 내부POM 변수 ${project.artifactId} : 위에서 정의한 artifactId를 사용
        <url><description> : 설명용
-->
<modelVersion>4.0.0</modelVersion>
<groupId>com.lge</groupId>
<artifactId>gdmi</artifactId>
<version>1.6.1</version>
<packaging>war</packaging>
<name>${project.artifactId}</name>
<url>http://maven.apache.org</url>
<description>GDMi system</description>

<!--
    <properties섹션> : Maven 프로젝트에서 사용되는 전역변수 정의
        <java.version> maven-compiler-plugin에서 변수사용하여, 해당버젼호환성으로 컴파일하도록 설정
        <project.build.sourceEncoding><project.reporting.outputEncoding 각종 플로그인에서 인코딩 참조할 때 사용함
        <maven.test.skip><maven.javadoc.skip> 테스트와 Javadoc 생성을 스킵할지 여부 설정
        ※ COMPILE > TEST COMPILE(테스트소스) > 테스트(기본적으로 JUNIT실행, src/test/java 아래에 모든 테스트 클래스가 실행됨) > PACKAGE > VERIFY(통합테스트,품질검사 : 툴사용필요) > INSTALL(.m2로컬 MAVEN저장소에 아티팩트 복사) > DEPLOY
        그외 버젼들은 실제 depedancy 등에서 사용할 의존성들의 버젼들을 명시에서 사용함
        <webcontent-dir> 빌드 설정부분에서 해당 변수 사용하여, WAR파일 빌드할때, 참조하도록 할때 사용(정적리소스위치) / ${basedir}은 프로젝트 루트디렉토리 의미...
-->    
<properties>
  <java.version>1.7</java.version>
  <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
  <maven.test.skip>false</maven.test.skip>
  <maven.javadoc.skip>false</maven.javadoc.skip>
  <org.springframework.version>4.0.9.RELEASE</org.springframework.version>
  <devonframe.version>1.6.1</devonframe.version>
  <commons.io.version>2.2</commons.io.version>
  <commons.fileupload.version>1.3.1</commons.fileupload.version>
  <common.dhcp.version>1.4</common.dhcp.version>
  <jsp.api.version>2.1</jsp.api.version>
  <jstl.version>1.2</jstl.version>
  <servlet.api.version>3.0.1</servlet.api.version>
  <taglibs.version>1.1.2</taglibs.version>
  <jsr250.api.version>1.0</jsr250.api.version>
  <mybatis.version>3.3.0</mybatis.version>
  <junit.version>4.11</junit.version>
  <webcontent-dir>${basedir}/src/main/webapp</webcontent-dir>
</properties>

<!--
    <repository> maven 저장소 의존성파일을 검색위치 정의 (해당저장소에서 > .m2디렉토리로 가져옴 / 저장소에 접근할수 없다면, m2디렉토리를 검색함)
    <pluginRepository> Maven 플러그인을 검색하는 곳을 정의

-->
    
<repositories>
  <repository>
    <id>release</id>
    <name>repository for DevOn</name>
    <layout>default</layout>
    <url>http://10.185.219.170:6060/nexus/content/repositories/releases/</url>
  </repository>
</repositories>

<pluginRepositories>
  <pluginRepository>
    <id>release</id>
    <name>repository for DevOn</name>
    <layout>default</layout>
    <url>http://10.185.219.170:6060/nexus/content/repositories/releases</url>
  </pluginRepository>
</pluginRepositories>











```
