
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
param (

    )



try{

    Write-ChannelMessage  "====================================="
    Write-ChannelMessage  "Compile-Runner"
    Write-ChannelMessage  "====================================="

    $RootPath = (Resolve-Path "$PSScriptRoot\..").Path
    $BinPath = Join-Path $RootPath 'bin'
    $ImgPath = Join-Path $RootPath 'img'
    $SetupPath = Join-Path $RootPath 'setup'
    $RunnerScriptPath = Join-Path $SetupPath 'Protector.ps1'
    $ImagePath = Join-Path $ImgPath 'ima.png'
    $IconPath = Join-Path $ImgPath 'safe.ico'
    $RunnerPath = Join-Path $BinPath 'Protector.exe'


    Write-ChannelMessage  "RootPath $RootPath"
    Write-ChannelMessage  "BinPath $BinPath"
    Write-ChannelMessage  "ImgPath $ImgPath"
    Write-ChannelMessage  "IconPath $IconPath"
    Write-ChannelMessage  "RunnerPath $RunnerPath"

    Write-Host "Invoke-ps2exe -inputFile $RunnerScriptPath -outputFile `"$RunnerPath`" -iconFile `"$IconPath`" "

    Invoke-ps2exe -inputFile $RunnerScriptPath -outputFile "$RunnerPath" -iconFile "$IconPath" 

    Write-ChannelResult "SUCCESS!"  

}catch {
    Write-ChannelResult "Build failure" -Warning    
}
