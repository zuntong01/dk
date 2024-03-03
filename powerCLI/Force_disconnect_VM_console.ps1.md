## __`Force_disconnect_VM_console.ps1.md`__

#### <b><span style="color:cyan">[pwsh스크립트 설명]</span></b>  
```bash
vCenter에 접속된 콘솔연결을 강제로 disconnect 하기 위해 PowerCLI 사용
```

```powershell
$env:PSModulePath += ";C:\TEMP\VMware-PowerCLI-13.1.0-21624340"
Get-Module -ListAvailable VMware* | Import-Module
Connect-VIServer -Server hivmwvcsd01.infra.io -User administrator -Password Kebhana1!

# 콘솔접속하고자 하는 VM 이름
$targetVM = "hivmwdnsd01"

# VM의 콘솔 connection을 확인하고, DropConnetion 수행하여 콘솔 연결 끊음
$connection01 = (Get-VM -Name $targetVM).ExtensionData
$connection02 = $connection01.QueryConnections()
(Get-VM -Name $targetVM).ExtensionData.DropConnections(@($connection02))
* 변수로 받지 않으면, ExtentionData.하위에 QueryConnections() 가 실행 안됨
```