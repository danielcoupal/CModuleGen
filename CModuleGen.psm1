################################################################################
#!/usr/bin/pwsh
#
# Date: 2022-04-25
# Last: 2024-05-15
# Author: Daniel Coupal
# Create C module header, source and -optionally- test files.
#
# Include copy of ./proj_conf.ps1 with project-specific details.
# For best results, use Doxygen module name as "-ModuleName" arg.
################################################################################

New-Variable -Name ProjName -Scope Script -Force
New-Variable -Name Date -Scope Script -Force
New-Variable -Name Compiler -Scope Script -Force
New-Variable -Name Target -Scope Script -Force
New-Variable -Name Author -Scope Script -Force
New-Variable -Name Version -Scope Script -Force

function New-Header {
    param (
        [string]$fileBaseName
    )

    $boiler = Get-Content "$env:REPOS/CModuleGen/header.templ"
    $boiler = $boiler -Replace '{FileBaseName}', "$fileBaseName"
    $boiler = $boiler -Replace '{ProjName}', "$ProjName"
    $boiler = $boiler -Replace '{Date}', "$Date"
    $boiler = $boiler -Replace '{DoxGroup}', "$fileBaseName"
    $boiler = $boiler -Replace '{DoxGroupName}', "$doxGroupName"
    $boiler = $boiler -Replace '{Author}', "$Author"
    $boiler = $boiler -Replace '{INCLUDE_GUARD}', "$includeGuard"
    if ($Version.Length -ne 0) {
        $boiler = $boiler -Replace '{Version}', " * @version $Version`n *`n"
    }
    else {
        $boiler = $boiler | Select-String '{Version}' -NotMatch
    }

    if ($PrintOnly -or $Debug) {
        Write-Output $boiler
    }
    else {
        $boiler | Set-Content "$fileBaseName.h" -Encoding UTF8
    }
}

function New-Source {
    param (
        [string]$fileBaseName
    )

    $boiler = Get-Content "$env:REPOS/CModuleGen/source.templ"
    $boiler = $boiler -Replace '{FileBaseName}', "$fileBaseName"
    $boiler = $boiler -Replace '{ProjName}', "$ProjName"
    $boiler = $boiler -Replace '{Year}', "$Year"
    $boiler = $boiler -Replace '{Date}', "$Date"
    $boiler = $boiler -Replace '{Compiler}', "$Compiler"
    $boiler = $boiler -Replace '{Target}', "$Target"
    $boiler = $boiler -Replace '{DoxGroup}', "$fileBaseName"
    $boiler = $boiler -Replace '{Author}', "$Author"

    if ($RTOS) {
        $boiler = $boiler -Replace '{RTOS}', "
  /*==============================================================================
   = OS ROUTINES
   =============================================================================*/
  "
    }
    else {
        $boiler = $boiler | Select-String '{RTOS}' -NotMatch
    }

    if ($PrintOnly -or $Debug) {
        Write-Output $boiler
    }
    else {
        $boiler | Set-Content "$fileBaseName.c" -Encoding UTF8
    }
}

function New-Unit-Test {
    param (
        [string]$fileBaseName
    )

    $boiler = Get-Content "$env:REPOS/CModuleGen/unit_test.templ"
    $boiler = $boiler -Replace '{FileBaseName}', "$fileBaseName"
    $boiler = $boiler -Replace '{ProjName}', "$ProjName"
    $boiler = $boiler -Replace '{Date}', "$Date"
    $boiler = $boiler -Replace '{Compiler}', "$Compiler"
    $boiler = $boiler -Replace '{Target}', "$Target"

    if ($PrintOnly -or $Debug) {
        Write-Output $boiler
    }
    else {
        $boiler | Set-Content "test_$fileBaseName.c" -Encoding UTF8
    }
}

function New-CModule {
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [string]$ModuleName,
        [string]$Version,
        [switch]$RTOS,
        [switch]$UnitTest,
        [switch]$PrintOnly,
        [Parameter()] 
        [ValidateSet("Header", "Source", "UnitTest")] 
        [string[]]$Only = "All"
    )

    if ($ModuleName.Length -eq 0) {
        Write-Error "No -ModuleName. Exiting." 
        return
    }

    $fileBaseName = $ModuleName.ToLower() -Replace " ", "_"
    $doxGroupName = $ModuleName -Replace "_", " "
    $includeGuard = ($ModuleName.ToUpper() -Replace " ", "_") + "_H_"

    if (Test-Path "./proj_conf.ps1") {
        $ProjName, $Date, $Compiler, $Target, $Author = ./proj_conf.ps1
    }
    else {
        $ProjName, $Date, $Compiler, $Target, $Author = Read-Host
    }

    if($Only -in ("All", "Header")) {
        New-Header $fileBaseName
    }
    if($Only -in ("All", "Source")) {
        New-Source $fileBaseName
    }
    if(($Only -like "All" -and $UnitTest) -or $Only -like "UnitTest") {
        New-Unit-Test $fileBaseName
    }
}

Export-ModuleMember -Function 'New-CModule'
