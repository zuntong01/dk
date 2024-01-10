## __`210. disk_detach_from_vms.ps1.md`__

#### <b><span style="color:cyan">[pwsh스크립트 설명]</span></b>  
```bash

```

#### <b><span style="color:cyan">[PowerCLI 스크립트]</span></b> 

```powershell
#!/usr/bin/pwsh
# Return 0 = 정상, Return = Task Fail Count
# 삭제 시 result 값 없음
# 삭제 완료 후, Get-HardDisk 조회 후, 하드디스크1만 있을 경우 정상

##################### 사용자 환경변수 설정 ######################
$csvPath = “/DRWORK/infra/vmware/DRVMList.csv”
$vCenterServer = “hivmwvcsr01.infra.io”
$vCenterServerUser = “drosvc@vsphere.local”
$vCenterServerPwdPath = “/DRWORK/infra/vmwre/token.vc”

$logFolder = “/DRWORK/infra/vmware/log”
$date = Get-Date -Format yyMMdd
$logFile = “/DRWORK/infra/vmware/log/LUNAttachLog_$date.log”
############################################################

####################################### 스크립트 환경 설정 #################################################

# 0.로그파일 경로확인 -경로가 없을시 디렉토리, 파일 생성(New-Item cmdlet)
if(-not(Test-Path -Path $logFolder)){New-Item -ItemType Directory -Path $logFolder | Out-Null}
if(-not(Test-Path -Path $logFile))(New-Item -ItemType File -Path $logFile | Out-Null}

# 1. PowerCLU Module Import
Get-Module -ListAvailable Vmware* | Import-Module | Out-Null
# 2. 보안동의 (powerCLI 구성설정 : 인증서유효성검증안함, 사용자에게 확인메세지 표시안함)
Set-PowerCLIConfiguration - InvalidCertificateAction Ignore -confirm:$false | Out-Null
# 3. vCenter 로그인(자격증명생성, 로그인)
$passwordString = Get-Content -Path $vCenterServerpwdPath
$secureObject = ConvertTo-SecureString -String $passwordString
$credential = New-Object System.Management.Automation.PSCredential ($vCenterServerUser, $secureObject)
Connect-VIServer -Server $vCenterServer -Credential $credential -ErrorAction SilentlyContinue | Out-Null

# 4. 사용자가 원하는 문자열을 ---> Write-Host(표준출력)으로 생성
function WriteLog($message)
{
	Write-Host “… $message” -Foreground White
}
########################################################################################################

################################## 실제 스크립트를 실행하는 영역 ################################








