 __`build.xml.md`__

#### <b><span style="color:cyan">[스크립트 설명]</span></b>  
```bash
ant 빌드를 하기위한 빌드스크립트 
(Ant 프로젝트의 build.xml 파일은 Apache Ant를 사용하여 빌드 프로세스를 자동화하는 데 사용되는 XML 기반의 구성 파일)

아래 예시는 GDMi 에서 web프로젝트에서 사용하는 ant 스크립트인데, 
실제적으로 build_all 을 실행하는데 이때 관련 target이 clean > tar > web_deploy 뿐이다.
과거에 사용했을지 모르겠으나. 아래 정의된 대부분의 target은 실행되지 않고 있음.
또한 현재의 소스그조와 target들이 동작하는연관성에 이해 안되는 부분들이 있어서,
해당 ant 스크립트에 사용예시로만 참고하면 좋을 것 같다.


```

#### <b><span style="color:cyan">[build.xml (GDMi개발_web) 스크립트]</span></b>
```xml
<!-- XML 파서는 기본값으로 XML 1.0과 UTF-8 인코딩을 사용합니다. 그러나 명시적으로 선언하는 것이 좋음 -->
<?xml version="1.0" enconding="UTF-8"?>
<!-- project 명을 gdmi, 프로젝트 기본디렉토리를 현재디렉토리로 지정함 -->
<proejct name="gdmi" basedir=".">

<!-- Ant의 변수 설정
    Ant 변수 설정 방법: 1.build.xml에 property name, value로 정의
                       2.build.xml에 property file에 정의된 별도의 파일에 변수정의하여 관리 (파일명예 : build_dev.properties)
                       3.jenkins에서 ant 빌드 설정의 properties 를 사용하여 변수정의
-->
    <property name="env.PROJECT_MODE" value="{PROJECT_MODE_PARAM}" />
    <property name="PROJECT_NAME" value="gdmi" />
    <property file="build_${env.PROJECT_MODE}.properties" />

    <property name="work.home.dir" value="${basdir}" />
    <property name="build.src.dir" vaule="${work.home.dir}\src\main\java">
    <property name="nexacro.source.dir" value="${work.home.dir}\src\main\nxui" />
    <property name="nexacro.target.dir" value="${work.home.dir}\src\main\webapp\nxui" />

    <property name="nexacro.src.lib.path" value="${work.home.dir}\src\main\nxui\nexacro14lib" />
    <property name="nexacro.target.lib.path" value="${work.home.dir}\src\main\webapp\nxui\nexacro14lib" />
    
    <property name="build.resource.dir" value="${work.home.dir}\src\main\resources">
    <property name="build.webbasedir" value="${work.home.dir}\src\main\webapp">
    <property name="build.webinf.dir" value="${build.webbasedir}\WEB-INF" />
    <property name="build.target.dir" value="${build.webbasedir}\WEB-INF\classes" />
    <property name="build.lib.dir" value="${build.webbasedir}\WEB_INF\lib" />

    <property name="was.tar.dir" value="${basedir}\build\was">
    <property name="web.tar.dir" value="${basedir}\build\web">

    <property name="servlet.lib.dir" value="${prop.was.home}\lib" />


<!-- build_wall 실행시 clean > tar > web_deploy 순서로 target 실행 -->
<target name="build_all">
    <antcall target="clean" />
        <antcall target="tar" />
        <antcall target="web_deploy" />
</target>

<!-- target 지정, ant 빌드과정에서 사용자 필요하는 각 단계를 정의하고 사용할 수 있음 
         clean(target) : 워크스페이스의 src/main/webapp/WEB-INF/classes 디렉토리삭제 / gdmi.war 파일삭제
-->
<target name="clean">
    <delete dir="${build.target.dir}" />
        <delete>
            <fileset dir="${basedir}">
                <include name="${PROJECT_NAME}.war" />
            </fileset>
        </delete>
</target>

<!--    tar(target) : 웹정적소스 
          1. 워크스페이스의 build/web 디렉토리 삭제 후, build/web 다시 생성
          2. build/web/gdmi.tar라는 파일 생성
                src/main/webapp 아래 있는 nxui, common 등을 디렉토리 tar 포함시킴 (단, nxui/*.jsp는 제외) 
-->
<target name="tar">
    <echo>Delete directory and create directory... </echo>
    <delete dir="{web.tar.dir}" />
    <mkdir dir="${web.tar.dir}" />
    <tar destfile="${web.tar.dir}/${PROJECT_NAME}.tar" longfile="gnu">
        <tarfileset dir="${build.webbase.dir}"
                        preserveLeadingSlashes="true">
            <include name="nxui/**" />
            <include name="common/**" />
            <include name="tagfree/**" />
            <include name="Install/**" />
            <include name="index.html" />
            <exclude name="nxui/*.jsp" />
        </tarfileset>
    </tar>
</target>

<!--    web_deploy (target) :
          1. SCP로 WEB서버의 /sorc001/gdmiadm/application/htdocs 에 tar파일 복사
          2. SSH로 WEB서버 접속하여, /sorc001/gdmiadm/application/htdocs 하위에 디렉토리 삭제 후, tar파일을 해제하여 배포
--> 
<target name="web_deploy">
    <echo message="web.remote.server set to = ${prop.web.server}" />
    <echo message="### WEB COPY ###" />
    <tstamp>
        <format property="TODAY" pattern="yyyyMMdd_HHmmss" />
    </tstamp>
    <scp localfile="${web.tar.dir}/${PROJeCT_NAME}.tar" todir="${prop.web.user}:$prop.web.password}@${prop.web.server}:${prop.web.dir}" trust="true" />
    <sshexec host="${prop.web.server}" username="${prop.web.user}" password="${prop.web.password}"
             command="rm -rf ${prop.web.dir}/nxui/*;rm -rf ${prop.web.dir/common/*;rm -rf ${prop.web.dir/tagfree/*;rm -rf ${prop.web.dir/Install/*};
             tar xvf ${prop.web.dir}/${PROJECT_NAME}.tar -C ${prop.web.dir};
             rm -rf ${prop.web.dir}/${PROJECT_NAME}.tar" trust="true" />
    <echo message="### WEB Depoy Finished ###" />
</target>


<!-- ####### 아래 ant 설정은 참고만 ########## --> 

<!-- antcontrib : ant확장라이브러리로, 기본ant에서 제공하지 않는 추가적인 TASK (예: <foreach> <if> <switch>)등을 제공함
     taskdef : Ant 빌드내에서 새로운 TASK를 정의할 때 사용 (자체제공task 외에 사용자정의task 또는 외부라이브러리에서 제공하는 추가 task 사용할수 있음)
      - 설정방법 : <taskdef>의 resource 속성에 antcontrib.jar 내에 존재하는 리소스파일을 지정하면, 해당 리소스 파일내의 정의된 task를 로드하여 사용할수 있게됨
      - 1. ${user.home}/.ant/lib 위치에 ant-contrib.jar 파일을 다운로드함.
        2. ant는  ${user.home}/.ant/lib 위치를 클래스패스로 인지하고, 모든 클래스패스의 jar내에 antcontrib.properties 를 전부 확인하여, 해당파일의 TASK를 로드함       
-->
    <taskdef resource="net/sf/antcontrib/antcontrib.properties" />    
    <target name="bootstrap">
        <mkdir dir="${user.home}/.ant/lib"/>
        <get dest="${user.home}/.ant/lib/ant-contrib.jar" src="http://search.maven.org/remotecontent?filepath=ant-contrib/ant-contrib/1.0b3/ant-contrib-1.0b3.jar"/>
    </target>


<!--
    path : 아래 예시는 2개의 디렉토리에서 JAR 파일들을 클래스 경로에 포함시켜 빌드 과정에서 사용할 수 있도록 함
           (path 의 id를 지정하고, 컴파일단계(target)에서 id값을 지정하여 해당 클래스패스를 참조하도록 사용할수 있음)

        ※  src/main/webapp/WEB_INF/lib 의 **/*.jar 파일을 클래스패스에 포함 / /engn001/tomcat/8.0/lib 의 *.jar 파일을 클래스패스에 포함
-->

<path id="lib.classpath">
    <fileset dir="{servlet.lib.dir}">
        <include name="**/*.jar" />
    </fileset>
    <fileset dir="{build.lib.dir}">
        <include name="*.jar" />
    </fileset>
</path>


<!--    align(target) : 소스디렉토리 루트에 있는 파일 중, *_dev로 끝나는 파일을 *로 mv하여 rename함
                    ※ 특별히 사용되는 이유가 있는지는 모르겠음 (소스디렉토리 부분에 변경해야할 이유가 있는 파일을 못찾았음.)        
-->
<target name="align">
    <move todir="${work.home.dir}" verbose="true">
    <fileset dir="${work.home.dir}" />
    <mapper type="glob" from="*_${env.PROJECT_MODE}" to="*" />
    </move>
</target>

<!--    copy(target) : align(target)이 실행된 후 실행됨. 
        (※ 복사는 되더라도, 매칭되어 rename되는 경우가 있는지는 테스트를 해봐야할듯.. 하위디렉토리에 하위디렉토리까지 검색해서 바꾸는지..  )
            1. src/main/resources에 파일(include, exclude)을 src/main/webapp/WEB-INF/classes 디렉토리로 복사함
            2. src/main/resources에 모든파일을 src/main/webapp/WEB-INF/classes 디렉토리로 복사함 
               (1.번에서 이미 복사했기 때문에, overwrite true, 속도를 빠르게 하기 위해 빈디렉토리 복사는 안하는듯...)
               2.1) 단, *_dev.properties 파일을 *.properties 파일명으로 rename 시킴 
               2.2) 단, *_dev.xml 파일을 *.xml 파일명으로 rename 시킴
            3. src/main/webapp/WEB-INF 에 모든파일을 src/main/webapp/WEB-INF 디렉토리로 복사함
               (단, *_dev.xml 파일을 *.xml 파일명으로 rename 시킴)
-->
<target name="copy" depends="align">
    <copy todir="${build.target.dir}">
        <fileset dir="${build.resources.dir}">
            <include name="**/*"/>
            <exclude name="**/*_dev.properties"/>
            <exclude name="**/*_prod.properties"/>
            <exclude name="**/.*svn"/>
        </fileset>
    </copy>

    <copy toDir="${build.target.dir}" includeemptydirs="false" overwrite="true">
        <fileset dir="${build.resources.dir}" />
        <mapper type="regexp" from="(.*)_${env.PROJECT_MODE}\.properteis" to="\1.properties"/>
    </copy>
    <copy toDir="${build.target.dir}" includeemptydirs="false" overwrite="true">
        <fileset dir="${build.resources.dir}" />
        <mapper type="regexp" from="(.*)_${env.PROJECT_MODE}\.xml" to="\1.xml"/>
    </copy>
    <copy toDir="${build.webinf.dir}" includeemptydirs="false" overwrite="true">
        <fileset dir="${build.webinf.dir}" />
        <mapper type="regexp" from="(.*)_${env.PROJECT_MODE}\.xml" to="\1.xml"/>
    </copy>
</target>


<!--    complie(target) : copy(target)이 실행된 후 실행됨
            1. src/main/java 의 파일일 중에 .java파일빼고 모든 파일, 디렉토리를 src/main/webapp/WEB-INF/classes 에 복사
            2. <javac> 로 자바소스 컴파일함 
                // yes : 별도의 JVM 에서 컴파일 실행 // i~~ncludeantruntime : Ant 런타임 라이브러리 컴파일 클래스경로에 포함안시킴
                // 컴파일할 경로대상 : src/main/java // 위에서 <path id> 로 지정한 경로를 컴파일 클래스패스로 지정함~~.
-->
<target name="compile" depends="copy">
    <echo>Compile Start...</echo>
    <copy todir="{build.target.dir}">
        <fileset dir="{build.src.dir}">
            <exclude name="**/*.java"/>
        </fileset>
    </copy>

    <javac destdir="${build.target.dir}"
                    fork="yes"
                    memoryInitialSize="256M"
                    memoryMaximumSize="1024M"
                    encoding="utf-8"
                    includeantruntime="false"
                    debug="true">
    <src path="${build.src.dir}"/>
    <classpath refid="lib.classpath" />
    </javac>
    <echo>Compile End...</echo>
</target>


<!--    war(target) : compile(target) 완료 후 실행됨.
            1. gdmi.war 파일을 생성하고, WAR파일의 webxml파일의 위치는 src/main/webapp/WEB-INF/web.xml 임
            2. src/main/nxui 의 jsp파일을 WAR파일의 jsp에 복사함 (하지만, src/main/nxui와 WAR파일 nxui 파일내용전혀 다름....)
            3. WAR 파일의 WEB-INF/lib에 복사될 라이브러리 지정 : src/main/webapp/WEB-INF/lib (몇개 jar파일은 제외)
            4. 컴파일된 클래스 파일들이 위치한 디렉토리를 지정 : src/main/webapp/WEB-INF/classes
            5. WAR 파일의 WEB-INF에 포함될 파일 지정 : src/main/webapp/WEB-INF 에서 jsp, tags 디렉토리
            5. WAR 파일에 포함될 index.html 지정 : src/main/webapp/index.html
        ※ 생성된 WAR파일은 자동으로 target 하위에 만들어지는걸로 보임...

(예상)
1. src/main/webapp/WEB-INF/web.xml >> WAR파일 WEB-INF/web.xml
2. src/main/nxui에 있는 jsp파일만 >> WAR파일 nxui
3. src/main/webapp/WEB-INF/lib 에서 >>  WAR파일 WEB-INF/lib
4. src/main/webapp/WEB-INF/classes >> WAR파일 WEB-INF/classes
5. src/main/webapp/WEB-INF/jsp 에서 >> WAR파일 WEB-INF/jsp
6. src/main/webapp/index.html 에서 >> WAR파일 index.html
-->
<target name="war" depends="compile">
    <echo>WAR file start...</echo>
    <war destfile="${PROJECT_NAME}.war" webxml="${build.webbase.dir}/WEB-INF/web.xml">
        <zipfileset dir="${nexacro.source.dir}" prefix="nxui">
            <include name="**/*.jsp" />
        </zipfileset>
        <lib dir="${build.lib.dir}">
            <exclude name="httpclient-4.5.2.jar" />
            <exclude name="httpcore-4.4.4.jar" />
            <exclude name="server.agent.developer.jar" />
        </lib>
        <classes dir="${build.target.dir}"/>
        <webinf dir="${build.webinf.dir}">
            <include name="jsp/**/*"/>
            <include name="tags/**/*"/>
        </webinf>
        <fileset dir="${build.webbase.dir}">
            <include name="index.html">
        </fileset>
    </war>
    <echo>WAR END... </echo>
</target>



<!--    was_deploy (target) :
          1. SSH로 WAS서버 접속하여, /home/gdmiadm/applications/mainebApp.war 삭제 (해당파일없는걸로 보아 해당영역 사용안함...)
          2. SCP로 target/gdmi.war 파일을 /home/gdmiadm/applications 에 복사
          3. 복사된 gdmi.war파일 압축 해제하고, gdmi.war파일은 /logs001 하위디렉토리의 오늘날짜로 mv (백업)
--> 

<target name="was_deploy">
    <echo>"Delete target directory After WAS Deploy"</echo>
    <tstamp>
        <format property="TODAY" pattern="yyyyMMdd_HHmmss" />
    </tstamp>    
    <sshexec host="${prop.was.server}" username="${prop.was.user}" password="${prop.was.password}"
             command="rm -rf ${prop.was.dir}/mainWebApp.war/*" trust="trust" />

    <echo>"### WAS Deploy ###"</echo>
    <scp localfile="${work.home.dir}/target/${PROJeCT_NAME}.war" todir="${prop.was.user}:$prop.was.password}@${prop.was.server}:${prop.was.dir}" trust="true" />
    <sshexec host="${prop.was.server}" username="${prop.was.user}" password="${prop.was.password}"
             command="unzip -o ${prop.was.dir}/${PROJECT_NAME}.war -d ${prop.was.dir};
                      mv ${prop.was.dir}/${PROJECT_NAME}.war /logs001/tomcat/8.0/servers/gdmi_8180/war_bak/${PRJOECT_NAME}.war_${TODAY};"
             trust="true" />
    <echo>"### WAS Deploy finished ###"</echo>
</target>

<!--    real_was_deploy, real_web_deploy (target) : 동시 web_deploy, was_deploy(target) 에 대해 복수의 서버에 동시 실행 위해 사용
       (단, 위에 was_deploy target 설정이지, wasdeploy가 아님으로 실제 실행시 오류가 날것으로 예상)
-->
<target name="real_was_deploy">
    <foreach list="${prop.was.server}" target="wasdeploy" param="prop.was.server" parallel="true">
</target>

<target name="real_web_deploy">
    <foreach list="${prop.web.server}" target="webdeploy" param="prop.web.server" parallel="true">
</target>

<!-- build_web 실행시 clean > tar > web_deploy 순서로 target 실행 -->
<target name="build_web">
    <antcall target="clean" />
        <antcall target="tar" />
        <antcall target="web_deploy" />
</target>

<!-- build_was 실행시 clean > tar > was_deploy 순서로 target 실행 -->
<target name="build_was">
    <antcall target="clean" />
        <antcall target="war" />
        <antcall target="was_deploy" />
</target>



</project>















```