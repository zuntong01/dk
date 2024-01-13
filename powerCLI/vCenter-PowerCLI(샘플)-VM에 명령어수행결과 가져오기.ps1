$env:PSModulePath = $env:PSModulePath + ";C:\Temp\PowerCLI"

Get-Module -ListAvailable VMware* | Import-Module

Connect-VIServer -Server hivmwvcsd01.infra.io -User administrator@vsphere.local -Password VMware1!

<#
    1. filePath 경로의문서(CSV)에 대상 VM 업데이트
    2. 14번 라인부터 마지막 라인까지 드래그 후, F8을 눌러 실행
#>

# 개발 대상 VM 목록이 저장된 파일에서 리스트 불러오기
$file = "F:\파일Path_to_Inst.csv"
$importVMs = Import-Csv -Path $filePath
$count = 1
$vmsCount = $importVMs.length
# GET-VM
$vms = @()
foreach($vm in $importVMs)
{
    $targetVM = Get-VM -Name $vm.vmName
    $vms+=$targetVM
}

### 명령어 수정 ###
$invokeText = "cat /etc/ssh/sshd_config | grep internal-sftp"
####################

### OS 사용자 인증 ###
$userName = "root"
$UserPwd = "Phk~cl07"
#######################


$reports = @()

foreach($targetVM in $vms)
{
    Write-Host "($count / $vmsCount).... "$targetVM.Name -ForegroundColor Green
    $row = "" | select vmName, Result
    $invokeResult = Invoke-VMScript -VM $targetVM -ScriptText $invokeText -GuestUser $userName -GuestPassword $userPwd -Confirm:$false
    $row.vmName = $targetVM.Name
    $row.Result = $invokeResult.ScriptOutput
    $reports+=$row
    $count++
}

$date = Get-Date -Format yyyyMMddss
$reports | Export-Csv -Path "F:\Result\파일Path_to_inst_$date.csv" -NoTypeInformation -Encoding UTF8
$reports | Out-GridView
