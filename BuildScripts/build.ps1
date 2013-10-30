param (
    [string]$Action="default",
    [string]$ChocoPath,
    [switch]$Help,
    [string]$VmName,
    [string]$package,
    [string]$testName
)
$here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
if($ChocoPath){
    $ChocoPath=$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ChocoPath)
    Write-Output "Setting ChocolateyInstall to $ChocoPath"
    [Environment]::SetEnvironmentVariable("ChocolateyInstall", $ChocoPath, [System.EnvironmentVariableTarget]::User)
    $env:ChocolateyInstall=$ChocoPath
}
if(-not $env:ChocolateyInstall -or -not (Test-Path "$env:ChocolateyInstall")){
    iex ((new-object net.webclient).DownloadString("http://bit.ly/psChocInstall"))
}

if(!(Test-Path $env:ChocolateyInstall\lib\Psake*)) { cinst psake -source http://packages.nuget.org/v1/FeedService.svc/ }
if(!(Test-Path $env:ChocolateyInstall\lib\7zip.CommandLine*)) { cinst 7zip.CommandLine }
if(!(Test-Path $env:ChocolateyInstall\lib\pester*)) { cinst pester }

if($Help){ 
  try {
    Write-Host "Available build tasks:"
    psake -nologo -docs | Out-Host -paging
  } catch {}
  return
}

$psakeDir = (dir $env:ChocolateyInstall\lib\Psake*)
if($psakeDir.length -gt 0) {$psakerDir = $psakeDir[-1]}
."$psakeDir\tools\psake.ps1" "$here/default.ps1" $Action -ScriptPath $psakeDir\tools -parameters $PSBoundParameters