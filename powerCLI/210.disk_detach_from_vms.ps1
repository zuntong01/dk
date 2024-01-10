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

# 1. PowerCLI Module Import
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
# 5. 대상VM 리스트 준비
## DRVMList.csv 파일을 읽음(import-Csv)
## pwsh문법 : | %{ } 파이프 앞의 DRVMList.csv 파일을 1줄씩 읽어서 { } 괄호안의 Get-VM 반복실행함 (ForEach-Object)
## $_ : 1줄씩 읽어오는 인수를 받는 변수(객체)역할 
$importVMs = import-Csv -Path $csvPath | %{Get-VM -Name $_.vmName}

$startDate = Get-date
## $targetVMs는 본 스크립트에서 정의된바 없음 (사용되지 않음)
$targetVMsLength = $targetVMs.lengh
$failCount = 0
$detachResult = @()

WriteLog (“[“+(Get-Date).ToString(“yyyy/MM/dd HH:mm:ss”)+”]”+” Start VM Disk Detach…”)
Add-Content $logFile -Value (“[“+(Get-Date).ToString(“yyyy/MM/dd HH:mm:ss”)+”]”+” Start VM Disk Detach…”)

# DR VM에 붙어있는 하드디스크1을 제외한 모든 디스크 제거
## DR VM 1대씩 차례로 연결된 디스크를 확인후 제거함
foreach($targetVM in $importVMs)
{
 	$targetVMDisks = $targetVM | Get-HardDisk | Where-Object {$_.Name -ne "Hard disk 1"}
  
	WriteLog (“[“+(Get-Date).ToString(“yyyy/MM/dd HH:mm:ss”)+”]”+” Target VM : $targetVM Disk List…”)
	Add-Content $logFile -Value (“[“+(Get-Date).ToString(“yyyy/MM/dd HH:mm:ss”)+”]”+” Target VM : $targetVM Disk List…”)

  	foreach($targetVMDisk in $targetVMDisks)
   	{
    		## 연결확인한 디스크 VM에서 제거
      		Get-HardDisk -VM $targetVM -id $targetVMDisk.id | Remove-HardDisk -Confirm:$false | Out-Null
      
		WriteLog (“[“+(Get-Date).ToString(“yyyy/MM/dd HH:mm:ss”)+”]”+” Disk Name : $($targetVMDisk.Name) / Path: $($targetVMDisk.Filename)…”)
		Add-Content $logFile -Value (“[“+(Get-Date).ToString(“yyyy/MM/dd HH:mm:ss”)+”]”+” Disk Name : $($targetVMDisk.Name) / Path: $($targetVMDisk.Filename)…”)
 	}

	# VM 에 연결된 디스크 정보를 다시 전달받고, 해당 객체의 length가 1개라면 Hard Disk 1만 연결되어 있다고 판단하고, Success logging / 1이 아닐경우 $failCount 증가
   	$checkVM = (Get-VM -Name $targetVM.Name | Get-HardDisk).length
    	if($checkVM -eq 1)
     	{
      		WriteLog (“[“+(Get-Date).ToString(“yyyy/MM/dd HH:mm:ss”)+”]”+” Disk Detach successfully VM : $targetVM…”)
		Add-Content $logFile -Value (“[“+(Get-Date).ToString(“yyyy/MM/dd HH:mm:ss”)+”]”+” Disk Detach successfully VM : $targetVM…”)
	}
 	else
  	{
   		WriteLog (“[“+(Get-Date).ToString(“yyyy/MM/dd HH:mm:ss”)+”]”+” Disk Detach Fail VM : $targetVM…”)
		Add-Content $logFile -Value (“[“+(Get-Date).ToString(“yyyy/MM/dd HH:mm:ss”)+”]”+” Disk Detach Fail VM : $targetVM…”)
  		$failCount++
    	}
}

$endDate = Get-Date
$elapsedTime = $endDate-$startDate

## 스크립트시작, 완료시간 로깅
“Start Time : {0}” -f $startDate
Add-Content $logFile -Value (“[“+$StartDate.ToString(“yyyy/MM/dd HH:mm:ss”)+”] Script Start Time”)

“Start Time : {0}” -f $endDate
Add-Content $logFile -Value (“[“+$endDate.ToString(“yyyy/MM/dd HH:mm:ss”)+”] Script End  Time”)

## pwsh문법 : {0:N2} -f $변수.TotalMinutes --> 변수에 저장된 값을 분으로 환산하여 소수점 2째자리까지 표현
## pwsh문법 : [Math]::Round() —> .netframework의 클래스를 사용하여, 소요시간값을 분으로 환산하고, 소수점 2째자리까지 출력
“Elapsed Time : {0:N2}” -f $elapsedTime.TotalMinutes
Add-Content $logFile -Value (“[“+[Math]::Round($elapsedTime.TotalMinutes,2)+”] Script Elpased Time(Minutes)”)

## vCenter 연결 해제
Disconnect-VIServer * -Confirm:$false

## RunScripts() 를 실행하고, return 받은 failCount값을 스크립트 exit 코드로 사용 (모두 정상연결되면 exit 0으로 정상종료됨)
exit $failCount







```







