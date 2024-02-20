$PortalAdmin = "C:\PortalAdmin"
$FileLogGroups = "$PortalAdmin\group-changes.log"
$Analyst = "Alan"

function Add-UsersInGroupsPosix {
    
    param (
        # Recebe o número do chamado.
        [Parameter(Mandatory=$true)]
        [string] $RequestNumber,

        [Parameter(Mandatory=$true)]
        [string] $OwnerGroup,

        # Recebe o nome de um ou mais grupos.
        [Parameter(Mandatory=$true)]
        [string[]] $GroupNames,

        # Recebe o nome de um ou mais usuários.
        [Parameter(Mandatory=$true)]
        [string[]] $UserNames
    )

    begin {
        $AccountsValidade = @()
        $AccountsInvalids = @()
        $UserNames | ForEach-Object {
            $UserEnabled = Get-UsersEnabled $_
            if ($UserEnabled) {
                $AccountsValidade += $($UserEnabled)
            } Else {
                $AccountsInvalids += $($_)
            }
        }

        Start-Sleep 2
    }

    process {
        foreach ($UserName in $AccountsValidade) {
            try {
                Write-Host "$($RequestNumber) - A conta de $($UserName) foi adicionado no grupo $($GroupNames) com sucesso." -ForegroundColor Green
                $LogAcction = "$(Get-Date);$($RequestNumber);$($Analyst);$($OwnerGroup);A conta de $($UserName) foi adicionado no grupo $($GroupNames) com sucesso."
            }
            catch {
                Write-Host "$($RequestNumber) - Error ao adicionar a conta de $($UserName) no grupo $($GroupNames)!" -ForegroundColor Yellow
                $LogAcction = "$(Get-Date);$($RequestNumber);$($Analyst);$($OwnerGroup);Error ao adicionar a conta de $($UserName) no grupo $($GroupNames)!"
            }
            finally {
                Write-Output "$($LogAcction)" | Out-File -Append -Encoding utf8 -FilePath $FileLogGroups
            }
        }
    }

    end {
        $AccountsInvalids | ForEach-Object {
            Get-UsersEnabled $_
        }
    }
}


function Get-UsersEnabled {
    
    param (
        # Recebe o nome de um ou mais usuários.
        [Parameter(Mandatory=$true)]
        [string[]] $UserNames
    )

    $UserNames | ForEach-Object {
        try {
            (Get-ADUser -Identity $_).Enabled
            if ($($_.Enabled) -eq "Enabled") {
                $UserEnabled =  $($_.SamAccountName)
                return $UserEnabled.tolower()
            }
        }
        catch {
            return $false
        }
    }
}

function Get-InvalidUsers {
    
    param (
        # Recebe o nome de um ou mais usuários.
        [Parameter(Mandatory=$true)]
        [string[]] $UserNames
    )

    $UserNames | ForEach-Object {
        try {
            $UserName = Get-ADUser -Identity $_ -Propreties DisplayName
            if ($($UserName.Enabled) -eq "Disabled") {
                Write-host " A conta $($UserName.SamAccountName) de $($UserName.DisplayName) está desativada no AD!" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host " A $($_) conta informada não existe na base de dados do AD!" -ForegroundColor Red
        }
    }
}
