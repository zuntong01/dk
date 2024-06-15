 __`build.xml.md`__

#### <b><span style="color:cyan">[스크립트 설명]</span></b>  
```bash
ant 빌드를 하기위한 빌드스크립트 
(Ant 프로젝트의 build.xml 파일은 Apache Ant를 사용하여 빌드 프로세스를 자동화하는 데 사용되는 XML 기반의 구성 파일)

아래 예시는 NTAMS의 빌드아트팩트를 ant를 통해 배포하는 스크립트임
단, war파일을, 배포하는것이 아니라, 
maven 빌드단계에서 target/tams 의 아트팩트를 -> /sorc001/appadm/stage/BD-TAMS-PROD에 위치시키고 해당 파일을 배포하는 설정이다.

```

#### <b><span style="color:cyan">[build.xml (BD_NTAMS_PROD) 스크립트]</span></b>
```xml
<!-- XML 파서는 기본값으로 XML 1.0과 UTF-8 인코딩을 사용함. 그러나 명시적으로 선언하는 것이 좋음 -->
<?xml version='1.0' encoding='utf-8'?>
<!-- project 명을 TAMS, 프로젝트 기본디렉토리를 현재디렉토리로 지정함 -->
<project name='TAMS' basedir='.'>

<!-- taskdef : Ant 빌드내에서 새로운 TASK를 정의할 때 사용 (자체제공task 외에 사용자정의task 또는 외부라이브러리에서 제공하는 추가 task 사용할수 있음)
            antcontrib : ant확장라이브러리로, 기본ant에서 제공하지 않는 추가적인 TASK (예: <foreach> <if> <switch>)등을 제공함
            조건 : ${ant설치path}/lib/ant-contrib.jar 에 파일이 존재하거나, ~/.ant/lib/ant-contrib.jar 에 파일이 존재해야함.
                  해당위치에 파일이 있다면 jar파일내에 antcontrib.properties 를 전부 확인하여, 해당파일의 TASK를 로드함 
-->
	<taskdef resource="net/sf/antcontrib/antcontrib.properties" />

<!-- Ant의 변수 설정
    Ant 변수 설정 방법: 1.build.xml에 property name, value로 정의
                       2.build.xml에 property file에 정의된 별도의 파일에 변수정의하여 관리가능 (파일명예 : <property file>build_dev.properties)
                       3.jenkins에서 ant 빌드 설정의 properties 를 사용하여 변수정의가능
-->
				<!-- 개발서버내에서 Jenkins의 빌드 완료된 디렉토리 (FTP전송을 위한 소스디렉토리) -->
				<property name="was.stage" value="/sorc001/appadm/stage/BD-TAMS-PROD" />

				<!-- 개발서버에 BizActor 디렉토리 (컴파일 Dependency)-->
				<property name="bizactor.lib" value="/sorc001/appadm/applications/bizactor/lib" />
				<property name="was.lib.dir" value="/sorc001/appadm/ciserv/jenkins/workspace/BD-TAMS-PROD/GAAI/src/main/webapp/WEB-INF/lib" />

				<!-- 운영서버 SCP 전송 관련 Properties -->
				<!-- 외부망 웹서버 #1 -->
				<property name="prod.LGEHTAMS01V.scp.host" value="165.186.128.39" />
				<property name="prod.LGEHTAMS01V.scp.password" value="!dlatl00" />
				<property name="prod.LGEHTAMS01V.scp.user" value="midadm" />
				<property name="prod.LGEHTAMS01V.scp.web.dir" value="/sorc001/appadm/applications/htdocs" />
				<!-- 외부망 웹서버 #2 -->
				<property name="prod.LGEHTAMS02V.scp.host" value="165.186.128.40" />
				<property name="prod.LGEHTAMS02V.scp.password" value="!dlatl00" />
				<property name="prod.LGEHTAMS02V.scp.user" value="midadm" />
				<property name="prod.LGEHTAMS02V.scp.web.dir" value="/sorc001/appadm/applications/htdocs" />
				<!-- 내부망 웹서버 #1 -->
				<property name="prod.LGEWTAMS01V.scp.host" value="10.185.222.147" />
				<property name="prod.LGEWTAMS01V.scp.password" value="!dlatl00" />
				<property name="prod.LGEWTAMS01V.scp.user" value="midadm" />
				<property name="prod.LGEWTAMS01V.scp.was.dir" value="/sorc001/appadm/applications/bizactor/GAAI" />
				<property name="prod.LGEWTAMS01V.scp.web.dir" value="/sorc001/appadm/applications/htdocs" />
				<!-- 내부망 웹서버 #2 -->
				<property name="prod.LGEWTAMS02V.scp.host" value="10.185.222.148" />
				<property name="prod.LGEWTAMS02V.scp.password" value="!dlatl00" />
				<property name="prod.LGEWTAMS02V.scp.user" value="midadm" />
				<property name="prod.LGEWTAMS02V.scp.was.dir" value="/sorc001/appadm/applications/bizactor/GAAI" />
				<property name="prod.LGEWTAMS02V.scp.web.dir" value="/sorc001/appadm/applications/htdocs" />

				<property name="prod.scp.port" value="22222" />

<!-- target 지정, ant 빌드과정에서 사용자 필요하는 각 단계를 정의하고 사용할 수 있음 
         deploy(target) : 
            SCP로 /sorc001/appadm/stage/BD-TAMS-PROD 의 소스를 -> WAS서버 /sorc001/appadm/applications/bizactor/GAAI 에 배포
            trust="true" : 원격서버 호스트키 자동수락 / failonerror="false" : 오류발생시 빌드실패로 처리할지 지정 (오류발생해도 빌드계속함.)
-->	
<target name="deploy">
	<!-- 3. SCP to PROD WAS -->
								<!-- 3.1 SCP to PROD WAS#1 -->
								<scp todir="${prod.LGEWTAMS01V.scp.user}:${prod.LGEWTAMS01V.scp.password}@${prod.LGEWTAMS01V.scp.host}:${prod.LGEWTAMS01V.scp.was.dir}" port="${prod.scp.port}" trust="true" failonerror="false">
									<fileset dir="${was.stage}" >
										<include name="WEB-INF/**" />
										<include name="**/*.jsp"   />
										<include name="mobile/**"  />
									</fileset>
								</scp>

								<!-- 3.2 SCP to PROD WAS#2 -->
								<scp todir="${prod.LGEWTAMS02V.scp.user}:${prod.LGEWTAMS02V.scp.password}@${prod.LGEWTAMS02V.scp.host}:${prod.LGEWTAMS02V.scp.was.dir}" port="${prod.scp.port}" trust="true" failonerror="false">
									<fileset dir="${was.stage}" >
										<include name="WEB-INF/**" />
										<include name="**/*.jsp"   />
										<include name="mobile/**"  />
									</fileset>
								</scp>


								<!-- 4. SCP to PROD WEB Server -->
								<!-- 4.1 SCP to PROD inner WEB#1 -->
								<scp todir="${prod.LGEWTAMS01V.scp.user}:${prod.LGEWTAMS01V.scp.password}@${prod.LGEWTAMS01V.scp.host}:${prod.LGEWTAMS01V.scp.web.dir}" port="${prod.scp.port}" trust="true" failonerror="false">
									<fileset dir="${was.stage}" >
										<exclude name="WEB-INF/**" />
										<exclude name="**/*.jsp"   />
									</fileset>
								</scp>

								<!-- 4.2 SCP to PROD inner WEB#2 -->
								<scp todir="${prod.LGEWTAMS02V.scp.user}:${prod.LGEWTAMS02V.scp.password}@${prod.LGEWTAMS02V.scp.host}:${prod.LGEWTAMS02V.scp.web.dir}" port="${prod.scp.port}" trust="true" failonerror="false">
									<fileset dir="${was.stage}" >
										<exclude name="WEB-INF/**" />
										<exclude name="**/*.jsp"   />
									</fileset>
								</scp>

								<!-- 4.3 SCP to PROD outter WEB#1 -->
								<scp todir="${prod.LGEHTAMS01V.scp.user}:${prod.LGEHTAMS01V.scp.password}@${prod.LGEHTAMS01V.scp.host}:${prod.LGEHTAMS01V.scp.web.dir}" port="${prod.scp.port}" trust="true" failonerror="false">
									<fileset dir="${was.stage}" >
										<exclude name="WEB-INF/**" />
										<exclude name="**/*.jsp"   />
									</fileset>
								</scp>

								<!-- 4.4 SCP to PROD outter WEB#2 -->
								<scp todir="${prod.LGEHTAMS02V.scp.user}:${prod.LGEHTAMS02V.scp.password}@${prod.LGEHTAMS02V.scp.host}:${prod.LGEHTAMS02V.scp.web.dir}" port="${prod.scp.port}" trust="true" failonerror="false">
									<fileset dir="${was.stage}" >
										<exclude name="WEB-INF/**" />
										<exclude name="**/*.jsp"   />
									</fileset>
								</scp>
</target>
</project>


```