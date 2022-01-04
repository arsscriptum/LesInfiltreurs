
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
param (

    [Parameter(Mandatory=$true,Position=0)]
    [ValidateScript({
        if(-Not ($_ | Test-Path) ){
            throw "File or folder does not exist"
        }
        if(-Not ($_ | Test-Path -PathType Leaf) ){
            throw "The Path argument must be a File. Files paths are not allowed."
        }
        return $true 
    })]        
    [String]$InputPath,
    [Parameter(Mandatory=$true,Position=1)]
    [String]$OutputPath,
    [Parameter(Mandatory=$true,Position=2)]
    [int]$UnlockId
)


$Script:ProtectorPath = "$ENV:AXPROTECTOR_SDK\bin\AxProtector.exe"
&"$Script:ProtectorPath" -x -kcm -f6000010 -p101001 -cf0 -d:6.20 -fw:3.00 -sl -nn -cae -cav -cas100 -wu1000 -we100 -eac -eec -emc -me:"err" -mi:"err" -v -cag71 -caa7 -o:"$OutputPath" "$InputPath"
Write-Host "Done! $OutputPath"