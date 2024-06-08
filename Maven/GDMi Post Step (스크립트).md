 __`Post step 스크립트 1.md`__

#### <b><span style="color:cyan">[스크립트 설명]</span></b>  
```bash
GDMI maven 빌드 후, jenkins에서 실행하는 Post 스크립트

WAS서버에 배포 : /sorc001/gdmiadm/ciserv/hudson/jobs/NERP_GDMi_dev/deploy_dev.sh
WAS서버 restart : /sorc001/gdmiadm/ciserv/hudson/jobs/NERP_GDMi_dev/restart_dev.sh
```

#### <b><span style="color:cyan">[Post step 스크립트 1 (GDMi개발) 스크립트]</span></b>
```bash
#!/bin/bash

CURRENT_TIME=`date +%Y%m%d_%H%M%S`

rm -rf /sorc001/gdmaiadm/applications/mainWebApp.war/*
cp /sorc001/gdmiadm/ciserv/hudson/jobs/GDMi_dev/workspace/target/gdmi.tar /sorc001/gdmiadm/applications/mainWebApp.war
cd /sorc001/gdmiadm/applications/mainWebApp.war

# WAR 배포
/engn001/java/1.7/bin/jar -xvf gdmi.war

# nexacro 라이센스 배포
cp /sorc001/gdmiadm/ciserv/hudson/jobs/GDMi_dev/res_dev/nexacro14_server_license.xml /sorc001/gdmiadm/applications/mainWebApp.war/WEB-INF/lib

# nexacro 엑셀 export/import 디렉토리 권한 변경
chmod 775 export
chmod 775 import
chmod -R 775 fileupload
```
#### <b><span style="color:cyan">[Post step 스크립트 2 (GDMi개발) 스크립트]</span></b>
```bash
#!/bin/bash

ssh midadm@10.185.221.153 "sh ~/restart.sh"

※ midadm 홈디렉토리의 restart.sh 파일 내용
cd /engn001/tomcat/8.0/servers/gdmi_8180/
./stop.sh
sleep 1
./start.sh
sleep 1
sleep 19
exit 0
```