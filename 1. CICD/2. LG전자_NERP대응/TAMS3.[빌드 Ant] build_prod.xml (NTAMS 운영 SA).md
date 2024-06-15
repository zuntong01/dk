 __`build.xml.md`__

#### <b><span style="color:cyan">[스크립트 설명]</span></b>  
```bash
ant 빌드를 하기위한 빌드스크립트 
(Ant 프로젝트의 build.xml 파일은 Apache Ant를 사용하여 빌드 프로세스를 자동화하는 데 사용되는 XML 기반의 구성 파일)

NTAMS의 SA라는 jar파일을 빌드하기 위한 별도의 프로세스 (ant 빌드 > jar생성 > scp 배포 함)
```

#### <b><span style="color:cyan">[build.xml (BD_NTAMS_SA_PROD) 스크립트]</span></b>
```xml
<!-- XML 파서는 기본값으로 XML 1.0과 UTF-8 인코딩을 사용함. 그러나 명시적으로 선언하는 것이 좋음 -->
<?xml version='1.0' encoding='UTF-8'?>
<!-- project 명을 SecurityServiceAccess, 프로젝트 기본디렉토리를 현재디렉토리로, ant명령시 기본target값 : all -->
<project name='SecurityServiceAccess' default='all' basedir='.'>

<!-- Ant의 변수 설정
    Ant 변수 설정 방법: 1.build.xml에 property name, value로 정의
                       2.build.xml에 property file에 정의된 별도의 파일에 변수정의하여 관리가능 (파일명예 : <property file>build_dev.properties)
                       3.jenkins에서 ant 빌드 설정의 properties 를 사용하여 변수정의가능
-->
	<property name='app.name'                value='${ant.project.name}' />
    <property name='java.encoding'           value='UTF-8' />
    <property name='src.dir.java'            value='src' />
    <property name='lib.dir.runtime'         value='lib' />
	<property name='build.dir'               value='../build_prod' />
    <property name='build.dir.classes'       value='${build.dir}/classes' />
	<property name='target.dir'              value='/sorc001/appadm/applications/bizactor/lib' />
	<property name='target.gaai.dir'         value='/sorc001/appadm/applications/bizactor/lib' />
	<property name='target.jjobs.dir'        value='/sorc001/appadm/applications/bizactor_jjobs/lib' />

    <!-- 2017-06-12 Taeho Lee JJOBS 경로에 SA추가 수정 -->
	<property name='target.jjobs.dir.201706'        value='/sorc001/appadm/applications/jjobs/bizactorlib' />

	<!-- 운영서버 SCP 전송 관련 Properties -->
	<!-- 내부WAS #1 -->
	<property name="prod.LGEWTAMS01V.scp.host"      value="10.185.222.147"                                   />
	<property name="prod.LGEWTAMS01V.scp.password"  value="!dlatl00"                                         />
	<property name="prod.LGEWTAMS01V.scp.user"      value="midadm"                                           />

	<!-- 내부WAS #2 -->
	<property name="prod.LGEWTAMS02V.scp.host"      value="10.185.222.148"                                   />
	<property name="prod.LGEWTAMS02V.scp.password"  value="!dlatl00"                                         />
	<property name="prod.LGEWTAMS02V.scp.user"      value="midadm"                                           />

	<!-- 배치서버 #1 -->
	<property name="prod.LGEBTAMS01V.scp.host"      value="10.185.222.149"                                   />
	<property name="prod.LGEBTAMS01V.scp.password"  value="!dlatl00"                                         />
	<property name="prod.LGEBTAMS01V.scp.user"      value="midadm"                                           />

	<!-- 배치서버 #2 -->
	<property name="prod.LGEBTAMS02V.scp.host"      value="10.185.222.150"                                   />
	<property name="prod.LGEBTAMS02V.scp.password"  value="!dlatl00"                                         />
	<property name="prod.LGEBTAMS02V.scp.user"      value="midadm"                                           />

<!-- target 지정, ant 빌드과정에서 사용자 필요하는 각 단계를 정의하고 사용할 수 있음 
         all(target) : 
            init > compile > replace > jar > copyToProd 타겟 순으로 Ant 빌드 수행
-->	
	<target name='all' depends='init, compile, replace, jar, copyToProd'/>

<!--     init(target) : 
            ${Workspace}/build_prod 디렉토리 삭제/생성 (quiet=true : 해당디렉토리가 없더라도 오류발생안함)
            ${Workspace}/build_prod/classes 생성
-->	
    <target name='init'>
        <delete dir='${build.dir}' quiet='true' />
        <mkdir  dir='${build.dir}' />
        <mkdir  dir='${build.dir.classes}'/>
    </target>

<!--    complie(target) :
            <javac> 로 자바소스 컴파일함 
                // ${workspace}/${프로젝트명}/src 하위에 위치한 소스를 컴파일 하여 ->  ${Workspace}/build_prod/classes 저장
                // 컴파일시 필요한 jar파일을 ${workspace}/${프로젝트명}/lib 에 저장하고, classpath로 지정함
                // ※ source="1.8", target="1.8" 빌드호환성을 명시하지 않아서, 현재 ant가 사용하는 java버젼이 무엇인지 확인필요.... (젠킨스의 java.home을 따라갈듯)
-->	
    <target name='compile'>
        <javac srcdir='${src.dir.java}' destdir='${build.dir.classes}'
            encoding='${java.encoding}'
        	debug="true" >
            <classpath>
                <fileset dir='${lib.dir.runtime}' />
            </classpath>
        </javac>
    </target>

<!--    replace(target) :
         <copy> ${workspace}/${프로젝트명}/src/tams_sa_config_prod.properties 의 파일을 -> ${Workspace}/build_prod/classes/tams_sa_config.propertie 로 복사
-->	
	<target name='replace' depends='compile'>
	    <copy file='${src.dir.java}/tams_sa_config_prod.properties' tofile='${build.dir.classes}/tams_sa_config.properties' overwrite="true"/>
	</target>

<!--    jar(target) :
         <jar> ${Workspace}/build_prod/classes 하위에 파일들을 tamsServiceAccess.jar 파일로 생성
-->	
    <target name='jar' depends='compile'>
        <jar destfile='${build.dir}/tamsServiceAccess.jar' basedir='${build.dir.classes}'/>
    </target>

<!--    copyToProd(target) 을 통해 scp로 소스배포
          방식 : <antcall> 을 이용하여, 동일한 이름의 "scpToProd target" 반복호출 배포를 수행함. 
                 동일한 scpToProd target이지만 다른 <param>이 존재하여 각 서버에 배포
-->	
	<target name="copyToProd">
		<!-- 운영서버 SCP 전송 -->
		<!-- 내부WAS #1 -->
		<antcall target="scpToProd">
			<param name="scp.host"      value="${prod.LGEWTAMS01V.scp.host}"     />
			<param name="scp.user"      value="${prod.LGEWTAMS01V.scp.user}"     />
			<param name="scp.password"  value="${prod.LGEWTAMS01V.scp.password}" />
			<param name="scp.dir.root"  value="${target.dir}"                    />
		</antcall>
		<antcall target="scpToProd">
			<param name="scp.host"      value="${prod.LGEWTAMS01V.scp.host}"     />
			<param name="scp.user"      value="${prod.LGEWTAMS01V.scp.user}"     />
			<param name="scp.password"  value="${prod.LGEWTAMS01V.scp.password}" />
			<param name="scp.dir.root"  value="${target.gaai.dir}"                    />
		</antcall>

		<!-- 내부WAS #2 -->
		<antcall target="scpToProd">
			<param name="scp.host"      value="${prod.LGEWTAMS02V.scp.host}"     />
			<param name="scp.user"      value="${prod.LGEWTAMS02V.scp.user}"     />
			<param name="scp.password"  value="${prod.LGEWTAMS02V.scp.password}" />
			<param name="scp.dir.root"  value="${target.dir}"                    />
		</antcall>
		<antcall target="scpToProd">
			<param name="scp.host"      value="${prod.LGEWTAMS01V.scp.host}"     />
			<param name="scp.user"      value="${prod.LGEWTAMS01V.scp.user}"     />
			<param name="scp.password"  value="${prod.LGEWTAMS01V.scp.password}" />
			<param name="scp.dir.root"  value="${target.gaai.dir}"                    />
		</antcall>

		<!-- 배치서버 #1 -->
		<antcall target="scpToProd">
			<param name="scp.host"      value="${prod.LGEBTAMS01V.scp.host}"     />
			<param name="scp.user"      value="${prod.LGEBTAMS01V.scp.user}"     />
			<param name="scp.password"  value="${prod.LGEBTAMS01V.scp.password}" />
			<param name="scp.dir.root"  value="${target.jjobs.dir}"              />
		</antcall>

		<!-- 배치서버 #2 -->
		<antcall target="scpToProd">
			<param name="scp.host"      value="${prod.LGEBTAMS02V.scp.host}"     />
			<param name="scp.user"      value="${prod.LGEBTAMS02V.~~scp~~.user}"     />
			<param name="scp.password"  value="${prod.LGEBTAMS02V.scp.password}" />
			<param name="scp.dir.root"  value="${target.jjobs.dir}"              />
		</antcall>

		<!-- 2017-06-12 Taeho Lee 운영 Bizactor SA 추가 배치서버 #1 -->
		<antcall target="scpToProd">
			<param name="scp.host"      value="${prod.LGEBTAMS01V.scp.host}"     />
			<param name="scp.user"      value="${prod.LGEBTAMS01V.scp.user}"     />
			<param name="scp.password"  value="${prod.LGEBTAMS01V.scp.password}" />
			<param name="scp.dir.root"  value="${target.jjobs.dir.201706}"              />
		</antcall>

		<!-- 2017-06-12 Taeho Lee 운영 Bizactor SA 추가 배치서버 #2 -->
		<antcall target="scpToProd">
			<param name="scp.host"      value="${prod.LGEBTAMS02V.scp.host}"     />
			<param name="scp.user"      value="${prod.LGEBTAMS02V.scp.user}"     />
			<param name="scp.password"  value="${prod.LGEBTAMS02V.scp.password}" />
			<param name="scp.dir.root"  value="${target.jjobs.dir.201706}"              />
		</antcall>

	</target>

<!--    copyToProd(target) 이 호출할 scpToProd target 정의
            : scp 수행 (SFTP모드로 동작) / scp 수행시 오류나더라도 빌드계속수행, 원격호스트키 확인생략
-->	
	<target name="scpToProd">
		<scp todir="${scp.user}:${scp.password}@${scp.host}:${scp.dir.root}" port="22222" trust="true" sftp="true" failonerror="false">
			<fileset file='${build.dir}/tamsServiceAccess.jar' />
		</scp>
	</target>

</project>
```