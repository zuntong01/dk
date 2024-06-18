 __`pom.xml.md`__

#### <b><span style="color:cyan">[스크립트 설명]</span></b>  
```bash
maven 빌드를 하기위한 빌드스크립트 (maven 프로젝트 빌드를 위한 설정파일)
※ 별도의 추가 설정파일 : (해당프로젝트에서는 별도파일에 적용된 설정은 없는듯)
    1. settings.xml : maven빌드의 글로벌 설정이 가능 / ${MAVEN경로}/conf 또는 ~/.m2 경로에 있다면 기본적용됨 (예시 : repo 설정, profile 설정등이 가능 )
    2. config.properties : pom.xml 에서 사용하는 변수 분리해서 관리 (pom.xml에 properties-maven-plugin을 사용하여 외부변수파일값을 읽어 올수 있음)
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
    ※별도의 인증이 없는 repo인듯... ID/PW 정의 설정이 없음
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

<!--
  <profiles 섹션> 빌드프로세스에서 조건부 설정을 지원하는 기능 제공 
    mvn clean install -P dev 명령을 수행했을때, profile id값이 dev 프로파일의 변수를 사용하게 됨(여기서는, env변수에 dev값이 들어감)
    해당 변수을 활용해서 개발, 운영환경에 따라 동일변수에 다른값을 사용하여 빌드프로세스에 활용
-->

<profiles>
  <profile>
    <id>dev</id>
    <properties>
      <env>dev</env>
    </properties>
  </profile>
  <profile>
    <id>prod</id>
    <properties>
      <env>prod</env>
    </properties>
  </profile>
</profiles>

<!--
  <build 섹션> 빌드프로세스에 설정들에 대해 명시
    <defaultGoal> : mvn 명령어 실행시 명시적인 목표지정하지 않았을때, 사용되는 기본 목표
                예) package : build + packaging(예:war)
    <directory> : 빌드산출물이 저장되는 디렉토리 위치 (프로젝트 루트디렉토리/target)
    <finalName> : 빌드산출물의 이름 (properties섹션에서 명시한 artifactID를 따라감)
    <plugins> : Maven plugin
      <plugin> maven-compiler-plugin 을 통해 빌드하고, 1.7 호환, UTF-8인코딩으로 빌드처리함
      <plugin> mvn test명령어로 maven-surefire-plugin 은 기본적으로 src/test/java 하위의 **/*Test*.java 컴파일하고 실행함.
               <include>를 사용하면, 기본적으로 해당 path의 테스트 코드만 실행하는걸로 override 함 
               : 따라서 devonframe/**/*Test.java는 src/test/java/devonframe/**/*Test.java 를 컴파일하고 실행 (예상)
              (컴파일되지 않았음으로 maven을 컴파일하고 테스트코드를 실행함)
      <plugin> maven-war-plugins 을 통해, 빌트 아티팩트를 war로 만듬
               1. src/main/webapp 디렉토리의 모든 파일을 WAR파일 최상단으로 위치 시킴
               2. src/main/java 디렉토리를 컴파일하여 WAR파일의 WEB-INF/classes/프로젝트 하위에 위치시킴
               3. src/main/resources 디렉토리를 모두 복사하여 WAR파일의 WEB-INF/classes 하위에 위치시킴
               4. src/main/wbapp 디렉토리의 /export, /import, /fileupload 는 WAR파일에 포함안시키는걸로 예상되지만, WAR파일에 실제 포함되어 있어서, 안먹은듯...
               5. <profile 섹션>에서 정의한 env 변수를 사영하여 src/main/profiles/${env}에 위치한 파일들을 WEB-INF/lcasses에 위치 시킴
-->
<build>
  <defaultGoal>package</defaultGoal>
  <directory>${basedir}/target</directory>
  <finalName>${proejct.artifactId}</finalName>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-compiler-plugin</artifactId>
      <configuration>
        <source>1.7</source>
        <target>1.7</target>
        <encoding>UTF-8</encoding>
      </configuration>
    </plugin>

    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-surefire-plugin</artifactId>
      <configuration>
        <skip>false</skip>
        <includes>
          <include>devonframe/**/*Test.java</include>
        </includes>
        <testFailureIgnore>false</testFailureIgnore>
        <argLine>-Xms256m -Xms512m -XX:MaxPermSize=128m -ea
                 -Dfile.enconding=UTF-8</argLine>
      </configuration>
    </plugin>

    <plugin>
      <artifactId>maven-war-plugin</artifactId>
      <version>2.4</version>
      <configuration>
        <warSourceExcludes>/export,/import,/fileupload</warSourceExcludes>
        <packagingExcludes>/export,/import,/fileupload</packagingExcludes>
        <webResources>
          <resource>
            <directory>src/main/profiles/${env}</directory>
            <targetPath>WEB-INF/classes</targetPath>
          </resource>
        </webResources>
      </configuration>
    </plugin>
  </plugins>
</build>


<!--
  <dependencies 섹션> dependency의 각항목들은 프로젝트가 의존하고 있는 라이브러리들을 명시하고, 
                     빌드프로세스에서 어떻게사용되는지 / 다운로드되는지 / 빌드결과물에 포함되는지 등을 결정
-->
<dependencies>

  <!-- 예시) devnframe 그룹의 devon-web아티팩트를 ${devonframe.version} 버젼으로 가져옴
         기본값으로 compile 단계에서, 컴파일러 클래스패스에 추가(소스컴파일에 사용됨), 
         WEB-INF/lib 하위에 저장되어, 빌드결과물에 포함됨 (runtime에 사용됨). -->
  <dependency>
    <groupId>devonframe</groupId>
    <artifactId>devon-web<artifactId>
    <version>${devonframe.version}</version>
  <dependency>

  <!-- 예시) devnframe 그룹의 devon-transaction아티팩트를 ${devonframe.version} 버젼으로 가져옴
          <exclusion> 단, devon-transaction 이 의존하는 mybatis는 다운로드 하지 않음
                    maven은 의존성트리라고하여, 해당라이브러리가 의존성하는 다른라이브러리를 함께 다운로드 됨
                    라이브러리가 의존하는 파일이 없다면, Maven 빌드는 실패
          <scope> compile : 컴파일단계에서 컴파일러 클래스패스에 추가(소스컴파일에 사용됨),
                            WEB-INF/lib 하위에 저장되어, 빌드결과물에 포함됨 (runtime에 사용됨). -->
  <dependency>
    <groupId>devonframe</groupId>
    <artifactId>devon-transaction<artifactId>
    <version>${devonframe.version}</version>
    <exclusions>
      <exclusion>
        <groupId>org.mybatis</groupId>
        <artifactId>mybatis</artifactId>
      </exclusion>
    </exclusions>
    <scope>compile</scope>
  </dependency>

  <!-- 예시) javax.servlet 그룹의 javax.servlet-api아티팩트를 ${servlet.api.version} 버젼으로 가져옴 
          <scope> provided : 컴파일단계에서 컴파일러 클래스패스에 추가되고, 빌드결과물에는 포함안됨 X --> 
  <dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>javax.servlet-api<artifactId>
    <version>${servlet.api.version}</version>
    <scope>provided</scope>
  </dependency>

  <!-- 예시) org.springframework 그룹의 spring-test아티팩트를 ${org.springframework.version} 버젼으로 가져옴 
          <scope> test : 테스트단계에서, 컴파일러 클래스패스에 추가되어 테스트소스 컴파일 / 
                         컴파일된 테스트코드를 실행할때도, 클래스패스에 포함되어 사용됨, 빌드결과물에는 포함안됨 X --> 
  <dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-test<artifactId>
    <version>${org.springframework.version}</version>
    <scope>test</scope>
  </dependency>

  <dependency>
    <groupId>junit</groupId>
    <artifactId>junit<artifactId>
    <version>${junit.version}}</version>
    <scope>test</scope>
  </dependency>

  <!-- 예시) activation 그룹의 activation 아티팩트를 1 버젼으로 가져옴 
          <scope> system : 로컬디렉토리(sysemPath) 에 있는 파일을 빌드과정에서 클래스패스로 추가,
                           빌드결과물에는 포함되지 않지만, 실제 systemPath위치가 WEB-INF/lib 이기 때문에, 결론은 포함됨. -->
  <dependency>
    <groupId>activation</groupId>
    <artifactId>activation<artifactId>
    <version>1</version>
    <scope>system</scope>
    <systemPath>${webcontent-dir}/WEB-INF/lib/activation.jar</systemPath>
  </dependency>

</dependencies>
</proejct>

<!-- ※ 실제 사용된 depedency 라이브러리 항목들
  <groupID> devonframe <artifactID> devon-web, devon-dataaccess, devon-transaction, devon-fileupload, devon-paging, devon-mail, devon-crypto
  <groupID> org.mybatis / <artifactID> mybatis
  <groupID> org.springframework / <artifactID> spring-context, spring-jdbc, spring-webmvc, spring-test
  <groupID> org.aspectj / <artifactID> aspectjweaver
  <groupID> com.googlecode.json-simple / <artifactID> json-simple
  <groupID> javax.servlet / <artifactID> javax.servlet-api, jstl
  <groupID> javax.annotation / <artifactID> jsr250-api
  <groupID> taglibs / <artifactID> standard
  <groupID> commons-dbcp / <artifactID> commons-dbcp
  <groupID> com.tobesoft / <artifactID> nexacro-xapi
  <groupID> nexacro-xeni / <artifactID> nexacro-xeni
  <groupID> sevlets.com / <artifactID> cos
  <groupID> org.codehaus.jackson / <artifactID> jackson-mapper-asl
  <groupID> junit / <artifactID> junit
  <groupID> org.quarts-scheduler / <artifactID> quartz
  <groupID> activation / <artifactID> activation
  <groupID> axis-ant / <artifactID> axis-ant
  <groupID> axis / <artifactID> axis
  <groupID> commons-httpclient / <artifactID> commons-httpclient
  <groupID> commons-discovery / <artifactID> commons-discovery
  <groupID> jaxrpc / <artifactID> jaxrpc
  <groupID> mail / <artifactID> mail
  <groupID> saaj / <artifactID> saaj
  <groupID> wsdl4j / <artifactID> wsdl4j
  <groupID> wsh / <artifactID> wsh
  <groupID> xalan / <artifactID> xalan
  <groupID> xerceslmpl / <artifactID> xerceslmpl
  <groupID> xmlParserAPIs / <artifactID> xmlParserAPIs
  <groupID> scpdb / <artifactID> scpdb
  <groupID> org.bouncycastle / <artifactID> bcprov-jdk15on
  <groupID> org.mindrot / <artifactID> jbcrypt
  <groupID> org.apache.poi / <artifactID> poi, poi-ooxml, poi-oxml-schemas, poi-excelant, poi-scratchpad
  <groupID> sax / <artifactID> sax
  <groupID> javax.xml.stream / <artifactID> stax-api
  <groupID> stax / <artifactID> stax-api
  <groupID> apache-xerces / <artifactID> xml-apis
  <groupID> xml-apis / <artifactID> xml-apis
  <groupID> org.apache.xmlbeans / <artifactID> xmlbeans
  <groupID> commons-codec / <artifactID> commons-codec
  <groupID> dom4j / <artifactID> dom4j
  <groupID> ant-contrib / <artifactID> ant-contrib
-->
```
