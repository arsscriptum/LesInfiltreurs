

[CmdletBinding()] 
   param(
      [Switch]$Deploy,
      [Switch]$Test
)

function Clean-SourceTree {

    [CmdletBinding()] 
    param(
        [String]$Path
    )
    $Source=(gci $path -Recurse -File -Filter "*.c").Fullname

    ForEach($cfile in $Source){
            Write-Host "[del] " -n -f DarkRed
        Write-Host "$cfile" -f DarkYellow
        remove-item -force $cfile
    }
    return
}

function Remove-HeaderCommentsFromSource {

    [CmdletBinding()] 
    param(
        [String]$Path
    )
    $Content = Get-Content -Path $Path
    $IsOneLineComment = $False
    $IsComment = $False
    $Output = ""
    $NoCommentException = $False
    $GrabEverything = $False
    $index = 0
    $Arr=$Content.Split("`n")
    ForEach ($Line in $Arr) 
    {
 
        if($GrabEverything){
            $Output += "$Line`n"
            continue
        }

        if ($Line -like "/`**"){   ###NCX
            $IsComment = $True    
        }elseif ($Line -like "*`*/") {   ###NCX
            $IsComment = $False
            $IsOneLineComment = $True
            $GrabEverything = $True
         
        }elseif($Line -like "//") {     ###NCX
            $IsOneLineComment = $True
        }

 
        if (-not $IsComment -And -not $IsOneLineComment) {
            $Output += "$Line`n"
        }

        $IsOneLineComment = $False


    }

    return $Output
}





function Import-SourceFiles{
    [CmdletBinding()] 
    param(
        [String]$SourceRootPath,
        [String]$DestRootPath
    )

    $SourceRootPathLen = $SourceRootPath.Length
    Write-Host "===============================================================================" -f DarkRed
    Write-Host "Import-SourceFiles " -f DarkYellow;
    Write-Host "                          $SourceRootPath" -f Magenta;
    Write-Host "                                 ====>>> " -f DarkBlue;
    Write-Host "                          $DestRootPath" -f DarkGreen;
    Write-Host "===============================================================================" -f DarkRed    

    $Folders = (Get-DirectoryTree $SourceRootPath).Relative
    $Sources=(gci $SourceRootPath -Recurse -File -Filter "*.c").Fullname
    $Headers=(gci $SourceRootPath -Recurse -File -Filter "*.h").Fullname
    Remove-Item -Force -Recurse -Path $DestRootPath -EA Ignore| Out-Null
    New-Item -Path $DestRootPath -Force -ItemType Directory| Out-Null
    ForEach($child in $Folders){
        $NewDir = $DestRootPath + '\' + $child
        New-Item -Path $NewDir -Force -ItemType Directory | Out-Null
        Write-Host "[Moulinette] " -n -f DarkRed
        Write-Host "creating dir $NewDir" -f DarkYellow    
    }

    ForEach($hfile in $Headers){
        $relpath = $hfile.SubString( $SourceRootPathLen )
        $newfilename =  $DestRootPath +  $relpath ; $newpath
        $basename = (Get-Item $hfile).Basename
        $name = (Get-Item $hfile).Name 
        #$OriginalContent = Remove-HeaderCommentsFromSource -Path $hfile
        $OriginalContent = Get-Content -Path $hfile
        $NewContent = @"
//==============================================================================`
//
//  $name 
//
//==============================================================================
//  Ars Scriptum - made in quebec 2020 <guillaumeplante.qc>
//==============================================================================

"@

        
        New-Item  -Path $newfilename -Force -ItemType File
        Clear-Content -Path $newfilename
        Set-Content -Path $newfilename -Value $NewContent
        Add-Content -Path $newfilename -Value $OriginalContent

        Write-Host "[Moulinette] " -n -f DarkGreen
        Write-Host "Processing $hfile ==> $newfilename" -f DarkCyan
    }



    ForEach($cfile in $Sources){
        $relpath = $cfile.SubString( $SourceRootPathLen )
        $newfilename =  $DestRootPath +  $relpath ; $newpath
        $basename = (Get-Item $cfile).Basename
        $name = (Get-Item $cfile).Name
        $OriginalContent = Remove-HeaderCommentsFromSource -Path $cfile
        
        $NewContent = @"

//==============================================================================`
//
//  $name 
//
//==============================================================================
//  Ars Scriptum - made in quebec 2020 <guillaumeplante.qc>
//==============================================================================



"@

        $NewContent += $OriginalContent
        Set-Content -Path $newfilename -Value $NewContent

        Write-Host "[Moulinette] " -n -f DarkRed
        Write-Host "Processing $cfile ==> $newfilename" -f DarkYellow
    }

}


$CurrentPath = (Get-Location).Path
$TestPath = Join-Path $CurrentPath 'Test'

if($Test){
    $TestFileSrc = Join-Path $TestPath 'src.c'
    $TestFileHeader = Join-Path $TestPath 'header.h'
    $TestFileHeader = "P:\CodeRessouces\UACME\Source\Shared\cmdline.h"
    #$Data = Remove-HeaderCommentsFromSource $TestFileSrc
    #Write-Host "$Data" -f Blue -b White
    $Data = Remove-HeaderCommentsFromSource $TestFileHeader
    Write-Host "$Data" -f MAgenta -b Gray
}

if($Deploy){
    Write-Host "===============================================================================" -f DarkRed
    Write-Host "DEPLOYING ---- OFFICIAL " -f DarkYellow;
    Write-Host "===============================================================================" -f DarkRed  
    $SourceRootPath = 'P:\CodeRessouces\UACME\Source\Akagi'
    $DestRootPath = 'P:\Development\AdminLoader\src'
    Import-SourceFiles -SourceRootPath $SourceRootPath -DestRootPath $DestRootPath


    $SourceRootPath = 'P:\CodeRessouces\UACME\Source\Shared'
    $DestRootPath = 'P:\Development\AdminLoader\src\shared'
    Import-SourceFiles -SourceRootPath $SourceRootPath -DestRootPath $DestRootPath    
}


