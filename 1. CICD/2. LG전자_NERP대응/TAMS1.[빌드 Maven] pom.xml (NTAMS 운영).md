__`pom.xml.md`__

#### <b><span style="color:cyan">[스크립트 설명]</span></b>  
```bash
maven 빌드를 하기위한 빌드스크립트 (maven 프로젝트 빌드를 위한 설정파일)
※ 별도의 추가 설정파일 : (해당프로젝트에서는 별도파일에 적용된 설정은 없는듯)
    1. settings.xml : maven빌드의 글로벌 설정이 가능 / ${MAVEN경로}/conf 또는 ~/.m2 경로에 있다면 기본적용됨 (예시 : repo 설정, profile 설정등이 가능 )
    2. config.properties : pom.xml 에서 사용하는 변수 분리해서 관리 (pom.xml에 properties-maven-plugin을 사용하여 외부변수파일값을 읽어 올수 있음)
```

#### <b><span style="color:cyan">[pom.xml (NTAMS 운영]</span></b>
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
        <name> : 프로젝트이름
        <url><description> : 설명용
-->
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.lge</groupId>
    <artifactId>tams</artifactId>
    <version>1.0.0</version>
    <packaging>war</packaging>
    <name>TAMS</name>
    <url>https://tams.lge.com</url>
    <description>TAMS</description>

<!--
  <profiles 섹션> 빌드프로세스에서 조건부 설정을 지원하는 기능 제공 
    profile의 목적은 mvn clean install -P "프로파일ID" 명령을 수행했을때, profile id 에 따라 다른 profile을 사용하도록 하는것이 목적인데
    여기서는 mvn 실행할때, profile id를 명시하지 않았고, pom.xml 파일에 prod 프로파일에 대해 <activeByDefault>true을 적용하여, 
    항상 해당 프로파일을 변수값이 적용되도록 설정 되어 있다.
-->
	<profiles>
		<profile>
			<id>prod</id>
			<activation>
				<activeByDefault>true</activeByDefault>
			</activation>
			<properties>
				<!-- 개발서버내에서 Jenkins의 빌드 완료된 디렉토리 (FTP전송을 위한 소스디렉토리) -->
				<was.stage>/sorc001/appadm/stage/BD-TAMS-PROD</was.stage>

				<!-- 개발서버에 BizActor 디렉토리 (컴파일 Dependency)-->
				<bizactor.lib>/sorc001/appadm/applications/bizactor/lib</bizactor.lib>
				<was.lib.dir>/sorc001/appadm/ciserv/jenkins/workspace/BD-TAMS-PROD/GAAI/src/main/webapp/WEB-INF/lib</was.lib.dir>

			</properties>
		</profile>
	</profiles>

<!--
    <properties섹션> : Maven 프로젝트에서 사용되는 전역변수 정의
        <java.version> maven-compiler-plugin에서 변수사용하여, 해당버젼호환성으로 컴파일하도록 설정하기 위한 변수값 선언
        <project.build.sourceEncoding><project.reporting.outputEncoding 각종 플로그인에서 인코딩 참조할 때 사용함
        <maven.test.skip><maven.javadoc.skip> 테스트와 Javadoc 생성을 스킵할지 여부 설정
        ※ COMPILE > TEST COMPILE(테스트소스) > 테스트(기본적으로 JUNIT실행, src/test/java 아래에 모든 테스트 클래스가 실행됨) > PACKAGE > VERIFY(통합테스트,품질검사 : 툴사용필요) > INSTALL(.m2로컬 MAVEN저장소에 아티팩트 복사) > DEPLOY
        그외 버젼들은 실제 dependenncy 등에서 사용할 의존성들의 버젼들을 명시에서 사용함
-->    
	<properties>
		<!-- Generic properties -->
		<java.version>1.8</java.version>
		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
		<project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>

		<maven.test.skip>true</maven.test.skip>
		<maven.javadoc.skip>true</maven.javadoc.skip>

		<!-- Spring -->
		<org.springframework.version>3.2.10.RELEASE</org.springframework.version>
		<devonframe.version>1.0.3</devonframe.version>
		<!-- Logging -->
		<log4j.version>1.2.17</log4j.version>
		<slf4j.version>1.6.1</slf4j.version>
		<!-- commons -->
		<commons.io.version>2.2</commons.io.version>
		<commons.fileupload.version>1.3.1</commons.fileupload.version>
		<commons.dbcp.version>1.3</commons.dbcp.version>
		<!-- Web -->
		<jsp.api.version>2.1</jsp.api.version>
		<jstl.version>1.2</jstl.version>
		<servlet.api.version>2.5</servlet.api.version>
		<taglibs.version>1.1.2</taglibs.version>

		<jsr250.api.version>1.0</jsr250.api.version>
		<hsqldb.version>1.8.0.10</hsqldb.version>
		<!-- Test -->
		<junit.version>4.11</junit.version>
	</properties>

<!--
    <repository> maven 저장소 의존성파일을 검색위치 정의 (해당저장소에서 > .m2디렉토리로 가져옴 / 저장소에 접근할수 없다면, m2디렉토리를 검색함)
    <pluginRepository> Maven 플러그인을 검색하는 곳을 정의
        <snapshots>, <releases> 버젼에 대한 활성화시켜 다운로드 받도록 허용함 (기본적으로 releases는 허용 / snapshot은 허용하지 않음)
            ※<snapshots>의 경우 의존성파일의 버젼을 <version>1.0-SNAPSHOT</version> 라고 명시할경우, 
            예를 들어, http://repo_URL/"groupID"/"artifactID"/1.0-SNAPSHOT 하위에 최신파일을 예) artifact-1.0-20240614.123456-1.jar 가져오는데, 해당 파일을 가져올지/말지 빌드가 트리거될때마다, 가져올지/말지 등을 주기를 지정할수도 있음
            ※<releases>는 일반적일 버젼명시를 사용하는 의존성파일에 대한 다운로드 유무등의 정책을 결정하는것 같음
    ※별도의 인증이 없는 repo인듯... ID/PW 정의 설정이 없음
-->
	<repositories>
		<repository>
			<id>devon-repository</id>
			<name>repository for DevOn</name>
			<layout>default</layout>
			<url>http://www.dev-on.com/devon_framework/nexus/content/groups/public</url>
			<snapshots>
				<enabled>true</enabled>
			</snapshots>
			<releases>
				<enabled>true</enabled>
			</releases>
		</repository>
	</repositories>

	<pluginRepositories>
		<pluginRepository>
			<id>devon-repository</id>
			<name>repository for DevOn</name>
			<layout>default</layout>
			<url>http://www.dev-on.com/devon_framework/nexus/repository</url>
			<snapshots>
				<enabled>true</enabled>
			</snapshots>
			<releases>
				<enabled>true</enabled>
			</releases>
		</pluginRepository>
	</pluginRepositories>

<!--
  <build 섹션> 빌드프로세스에 설정들에 대해 명시
    <defaultGoal> : mvn 명령어 실행시 명시적인 목표지정하지 않았을때, 사용되는 기본 목표
                예) package : build + packaging(예:war)
    <finalName> : 빌드산출물의 이름 (properties섹션에서 명시한 artifactID를 따라감)
    <directory> : 는 설정되어 있지 않기 때문에... 기본값인 target이 사용됨
    <plugins> : Maven plugin
      1. <plugin> maven-compiler-plugin 을 통해 빌드하고, 1.8 호환, UTF-8인코딩으로 빌드처리함
      2. <plugin> maven-resources-plugin 을 통해, 소스코드외에 리소스파일 처리함 (명시적으로 추가하지 않아도 기본동작함)
            (예: src/main/resources (복사)-> target/classes)
      3. <plugin> mvn test명령어로 maven-surefire-plugin 은 기본적으로 src/test/java 하위의 **/*Test*.java 컴파일하고 실행함.
                ※ <include>를 사용하면, 기본적으로 해당 path의 테스트 코드만 실행하는걸로 override 함 
            <forkMode>always : 각 테스트클래스별로 별도의 JVM을 포크하는 모드 설정 (독립환경에서 실행)
            <parallel>classes : 테스트 클래스별로 병렬로 실행하여, 테스트 실행 단축
      4. <plugin> com.google.code.maven-replacer-plugin의 replacer : prepare-package 단계에서 파일 내 문자열을 찾고 대체(replace)하는 용도로 사용 (예:환경별 구성적용위해)
            #주석처리되어 있어서, 삭제함....
      5. <plugin> maven-war-plugin 을 통해, 빌드 아티팩트를 war로 만듬.
            1. src/main/webapp 디렉토리의 모든 파일을 WAR파일 최상단으로 위치 시킴
            2. src/main/java 디렉토리를 컴파일하여 WAR파일의 WEB-INF/classes/프로젝트 하위에 위치시킴
            3. src/main/resources 디렉토리를 모두 복사하여 WAR파일의 WEB-INF/classes 하위에 위치시킴
            4. <dependency> 의 의존성파일들을 WEB-INF/lib 하위에 위치시킴
            5. src/main/webapp/WEB-INF/web.xml 파일을 WEB-INF/ 디렉토리 하위에 위치시킴 
-->
	<build>
		<defaultGoal>clean package</defaultGoal>
		<finalName>${project.artifactId}</finalName>
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-compiler-plugin</artifactId>
				<version>2.5.1</version>
				<configuration>
					<source>${java.version}</source>
					<target>${java.version}</target>
					<encoding>${project.build.sourceEncoding}</encoding>
				</configuration>
			</plugin>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-resources-plugin</artifactId>
				<version>2.6</version>
			</plugin>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-surefire-plugin</artifactId>
				<version>2.12.4</version>
		        <configuration>
<!-- 		        	<skipTests>true</skipTests> -->
			        <forkMode>always</forkMode>
			        <parallel>classes</parallel>
<!-- 					<argLine>-Xms256m -Xmx512m -XX:MaxPermSize=128m -Dfile.encoding=UTF-8</argLine> -->
		        </configuration>
			</plugin>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-war-plugin</artifactId>
				<version>2.2</version>
			</plugin>
<!--
      6. <plugin>maven-antrun-plugin 을 통해 maven 빌드안에서 ant plugin을 설치하여, ant 스크립트를 사용 할 수 있음
            - war를 배포 목적이지만, 신규TAMS시스템에서는 ant scp 에러가 계속발생하여, 실제배포는 jenkins 파이프라인 stage로 분리했음
            - 여기서는 Maven <phase>package</phase>단계에서 실행되고, 특정파일 복사등을 위해서만 사용하였음
            - TAMS는 빌드결과물인 war를 배포하지 않고, 압축대상인 target/tams 디렉토리를 복사하고, 해당 파일을 scp로 배포하고 있음
                - <goal>run</goal> maven빌드에서 antrun플러그인에서 스크립트 실행을 위한 설정
                - <tasks> 실행할 ant Task를 구체적으로 작성
                    > (소스)target/tams 에서 -> (타겟)/sorc001/appadm/stage/BD-TAMS-PROD 로 동기화 시킴 (copy와 다른점은 파일내용과, 파일명은 동일하면 덮어쓰기 안함)
                       ※ ${project.build.finalName}은 <fineName>설정시 자동저장되는 변수임
                    > /sorc001/appadm/stage/BD-TAMS-PROD/WEB-IMF/classes/설정파일들을 -> mv 명령어로 rename 함..
                    > /sorc001/appadm/stage/BD-TAMS-PROD/lib/몇몇 jar파일들을 삭제함.. (삭제의 이유는 잘 모르겠음)
                - <dependencies>에서 antrun 실행시 필요한 depedency 의존성 파일들을 명시(ant-jsch, ant-commons-net, commons-net)
-->
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-antrun-plugin</artifactId>
				<version>1.7</version>
				<executions>
					<execution>
						<id>war_deploy</id>
						<phase>package</phase>
						<goals>
							<goal>run</goal>
						</goals>
						<configuration>
							<tasks>
								<!-- 1. file sync to stage dir from target dir -->
								<sync todir='${was.stage}' includeemptydirs='true'>
							    	<fileset dir="${basedir}/target/${project.build.finalName}" />
								</sync>

								<!-- 2. Change configuration for PROD server (jar and config files) -->
								<move file="${was.stage}/WEB-INF/classes/log4j_prod.xml"                         tofile="${was.stage}/WEB-INF/classes/log4j.xml"                         overwrite="true"/>
								<move file="${was.stage}/WEB-INF/web.xml_prod"                                   tofile="${was.stage}/WEB-INF/web.xml"                                   overwrite="true"/>
								<move file="${was.stage}/WEB-INF/classes/spring/mvc-context-fileupload.xml_prod" tofile="${was.stage}/WEB-INF/classes/spring/mvc-context-fileupload.xml" overwrite="true"/>
								<move file="${was.stage}/WEB-INF/classes/spring/context-datasource.xml_prod"     tofile="${was.stage}/WEB-INF/classes/spring/context-datasource.xml"     overwrite="true"/>

								<move file="${was.stage}/WEB-INF/classes/config/ncd_prod.properties"             tofile="${was.stage}/WEB-INF/classes/config/ncd.properties"             overwrite="true"/>
								<move file="${was.stage}/WEB-INF/classes/config/project_prod.properties"         tofile="${was.stage}/WEB-INF/classes/config/project.properties"         overwrite="true"/>
								<move file="${was.stage}/index_prod.html"                                        tofile="${was.stage}/index.html"                                        overwrite="true"/>

								<delete file="${was.stage}/WEB-INF/lib/bizactor.dataset.jar"/>
								<delete file="${was.stage}/WEB-INF/lib/bizactor.exception.jar"/>
								<delete file="${was.stage}/WEB-INF/lib/server.agent.developer.jar"/>
								<delete file="${was.stage}/WEB-INF/lib/httpclient-4.5.2.jar"/>
								<delete file="${was.stage}/WEB-INF/lib/httpcore-4.4.4.jar"/>

								<!-- JASPER 관련 수정 -->
								<delete file="${was.stage}/WEB-INF/lib/jasperreports-5.6.0.jar"/>
								<delete file="${was.stage}/WEB-INF/lib/commons-digester-2.1.jar"/>
								<delete file="${was.stage}/WEB-INF/lib/commons-collections-3.2.1.jar"/>
								<delete file="${was.stage}/WEB-INF/lib/ArialUnicodeMS.jar"/>
								<delete file="${was.stage}/WEB-INF/lib/Code2000.jar"/>

                            <!-- 아래내용은 maven에서 실행하지 않고, stage를 분리해서 실행하는것으로 수정 -->
								<!-- 3. SCP to PROD WAS -->
								<!-- 3.1 SCP to PROD WAS#1 -->
								<!-- 3.2 SCP to PROD WAS#2 -->
								<!-- 4. SCP to PROD WEB Server -->
								<!-- 4.1 SCP to PROD inner WEB#1 -->
								<!-- 4.2 SCP to PROD inner WEB#2 -->
								<!-- 4.3 SCP to PROD outter WEB#1 -->
								<!-- 4.4 SCP to PROD outter WEB#2 -->

							</tasks>
						</configuration>
					</execution>
				</executions>
				<dependencies>
					<dependency>
						<groupId>ant</groupId>
						<artifactId>ant-commons-net</artifactId>
						<version>1.6.5</version>
					</dependency>
					<dependency>
						<groupId>commons-net</groupId>
						<artifactId>commons-net</artifactId>
						<version>1.4.1</version>
					</dependency>
					<dependency>
						<groupId>org.apache.ant</groupId>
						<artifactId>ant-jsch</artifactId>
						<version>1.8.4</version>
					</dependency>
				</dependencies>
			</plugin>
            <plugin>
        	    <groupId>org.apache.maven.plugins</groupId>
        		<artifactId>maven-deploy-plugin</artifactId>
        		<version>2.7</version>
      		</plugin>
		</plugins>
	</build>



<!--
  <dependencies 섹션> dependency의 각항목들은 프로젝트가 의존하고 있는 라이브러리들을 명시하고, 
                     빌드프로세스에서 어떻게사용되는지 / 다운로드되는지 / 빌드결과물에 포함되는지 등을 결정
-->
	<dependencies>

  <!-- 예시) devonframe 그룹의 devon-validator 아티팩트를 ${devonframe.version} 버젼으로 가져옴
          <exclusion> 단, devon-transaction 이 의존하는 commons-collections 다운로드 하지 않음
                    maven은 의존성트리라고하여, 해당라이브러리가 의존성하는 다른라이브러리를 함께 다운로드 됨
                    라이브러리가 의존하는 파일이 없다면, Maven 빌드는 실패 -->
		<dependency>
			<groupId>devonframe</groupId>
			<artifactId>devon-validator</artifactId>
			<version>${devonframe.version}</version>
			<exclusions>
		        <exclusion>
		            <groupId>commons-collections</groupId>
		            <artifactId>commons-collections</artifactId>
		        </exclusion>
		    </exclusions>
		</dependency>

  <!-- 예시) org.slf4j 그룹의 slf4j-api 아티팩트를 ${slf4j.version} 버젼으로 가져옴
          ※ <scope>가 명시 되지 안으면 compile로 동작함

          <scope> compile : 컴파일단계에서 컴파일러 클래스패스에 추가(소스컴파일에 사용됨),
                            WEB-INF/lib 하위에 저장되어, 빌드결과물에 포함됨 (runtime에 사용됨).
          <scope> runtime : 컴파일단계에서 컴파일러 클래스패스에 사용되지 않음 X
                            WEB-INF/lib 하위에 저장되어, 빌드결과물에 포함됨 (runtime에 사용됨).
          <scope> provided : 컴파일단계에서 컴파일러 클래스패스에 추가되고, 빌드결과물에는 포함안됨 X 
          <scope> test : 테스트단계에서, 컴파일러 클래스패스에 추가되어 테스트소스 컴파일 / 
                         컴파일된 테스트코드를 실행할때도, 클래스패스에 포함되어 사용됨, 빌드결과물에는 포함안됨 X 
          <scope> system : 로컬디렉토리(sysemPath) 에 있는 파일을 빌드과정에서 클래스패스로 추가 / 런타임에는 포함안됨X
            <systemPath>"외부path에 있는 jar파일 path 지정"<systemPath> -->

		<!-- Logging -->
		<dependency>
			<groupId>org.slf4j</groupId>
			<artifactId>slf4j-api</artifactId>
			<version>${slf4j.version}</version>
			<scope>compile</scope>
		</dependency>
	</dependencies>
</project>

<!-- ※ 실제 사용된 depedency 라이브러리 항목들
  <groupID> devonframe  <artifactID> devon-web,devon-dataaccess,devon-paging,devon-excel,devon-fileupload,devon-validator,devon-crypto,devon-xplatform
  <groupID> org.springframework <artifactID> spring-context,spring-context-support,spring-test,
  <groupID> org.slf4j           <artifactID> slf4j-api,jcl-over-slf4j,jcl-over-slf4j,
  <groupID> log4j               <artifactID> log4j
  <groupID> org.aspectj         <artifactID> aspectjweaver
  <groupID> javax.servlet       <artifactID> servlet-api,jstl
  <groupID> javax.annotation    <artifactID> jsr250-api
  <groupID> taglibs             <artifactID> standard
  <groupID> commons-dbcp        <artifactID> commons-dbcp
  <groupID> org.apache.commons  <artifactID> commons-collections4
  <groupID> com.oracle          <artifactID> ojdbc
  <groupID> hsqldb              <artifactID> hsqldb
  <groupID> com.fasterxml.jackson.core  <artifactID> jackson-databind
  <groupID> org.apache.cxf      <artifactID> cxf-rt-frontend-jaxws,>cxf-rt-transports-http,cxf-rt-management
  <groupID> junit               <artifactID> junit
  <groupID> org.codehaus.jackson    <artifactID> jackson-mapper-asl
  <groupID> com.google.code.gson    <artifactID> gson
  <groupID> org.hibernate       <artifactID> hibernate-validator
  <groupID> net.sf.ehcache      <artifactID> ehcache
  <groupID> org.json            <artifactID> json
  <groupID> bizactor            <artifactID> bizactor.server,bizactor.dataset,bizactor.exception,server.agent
  <groupID> miplatform          <artifactID> miplatform
  <groupID> nexacro-xapi        <artifactID> nexacro-xapi
  <groupID> org.lazyluke        <artifactID> log4jdbc-remix
  <groupID> org.quartz-scheduler    <artifactID> quartz
  <groupID> net.sf.jasperreports    <artifactID> jasperreports
  <groupID> org.codehaus.groovy <artifactID> groovy-all
  <groupID> net.sf.jasperreports    <artifactID> jasperreports-fonts,ArialUnicodeMS
  <groupID> com.google.zxing    <artifactID> javase,core

```
