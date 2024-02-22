$PortalPosix = "C:\PortalPosix"
$PortalPosixLogs = "$PortalPosix\LOGS"
$FileLogGroups = "$PortalPosixLogs\group-changes.log"
$FileLogUsers = "$PortalPosixLogs\user-changes.log"
$HeaderLogs = "DATE;REQUEST;ANALYST;OWNER;ACTION LOGS"
$PortalExists = Test-Path -Path "$PortalPosixLogs"

if (!$PortalExists) {
    New-Item -Type Directory -Path "$PortalPosixLogs" > $null
    Set-Content -Encoding UTF8 -Value "$HeaderLogs" -Path "$FileLogGroups" 
    Set-Content -Encoding UTF8 -Value "$HeaderLogs" -Path "$FileLogUsers"  
    $LastFileExists = Test-Path -Path "$FileLogUsers"
    if($LastFileExists) {
        Write-host ""
        Write-host " Estrutura do Portal foi criada com sucesso em $($PortalPosix)!
        " -ForegroundColor Green

        Write-host " Arquivos de Logs em $($PortalPosixLogs):
        "
        Write-host " $(Get-ChildItem -Path $PortalPosixLogs).Name"
        Write-host ""
    }
}

Write-host " AVISO: Garanta que o grupo de analistas possam gravar os logs em $($PortalPosixLogs)." -ForegroundColor Yellow
