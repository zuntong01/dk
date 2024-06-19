 __`Post step 스크립트 1.md`__

#### <b><span style="color:cyan">[스크립트 설명]</span></b>  
```bash
SCM dashboard maven 빌드 후, jenkins에서 실행하는 Post 스크립트
scmdb.war 파일 배포(cp) > war압축해제(unzip) > 기타작업 (rm, ln -s) > war압축해제파일
web소스배포 : war압축해제된 전체디렉토리를 그대로 ---> /sorc001/appadm/applications/htdocs 에 복사
  ※ src/main/webapp/ 하위의 경로의 정적컨텐츠만 선택해서 복사하는데, 여기는 WAR압축한 모든 파일을 넘겼음... 
```

#### <b><span style="color:cyan">[Post step 스크립트 1 (SCM_Dash개발) 스크립트]</span></b>
```bash
rm -rf /sorc001/appadm/applications/scmdb.war
mkdir /sorc001/appadm/applications/scmdb.war
cp ${WORKSPACE}/target/scmdb.war /sorc001/appadm/applications/scmdb.war
cd /sorc001/appadm/applications/scmdb.war/
unzip scmdb.war
rm -rf scmdb.war
rm -rf ./WEB-INF/classes/spring/mvc-context-fileupload.xml
rm -rf ./WEB-INF/classes/spring/mvc-context-fileupload-prod.xml
rm -rf ./WEB-INF/classes/config/project.properties
mv ./WEB-INF/classes/config/project.properties_dev ./WEB-INF/classes/config/project.properties
mv ./WEB-INF/classes/spring/mvc-context-fileupload-dev.xml ./WEB-INF/classes/spring/mvc-context-fileupload.xml
cd /sorc001/appadm/applications/scmdb.war/
rm -rf ./WEB-INF/lib/ojdbc6-11.2.0.3.jar
rm -rf export
ln -s /data001/fileupload/export/ export
rm -rf import
ln -s /data001/fileupload/import/ import
rm -rf fileupload
ln -s /data001/fileupload/temp/ fileupload
rm -rf /sorc001/appadm/applications/htdocs
cp -R /sorc001/appadm/applications/scmdb.war /sorc001/appadm/applications/htdocs
```
