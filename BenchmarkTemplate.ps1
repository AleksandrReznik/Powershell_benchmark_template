<#
.SYNOPSIS
     Powershell benchmark template
.DESCRIPTION     
Powershell benchmark template, define LogWrite function which output defined text to both screen and log file 
and in final call saves currently executed file + OS and PS versions to log file.

 .PARAMETER param_pathToLogFile 
     paramPathToSaveFiles - path to create log file, if not specified will take current script execution path
 .NOTES
 Main thing in this script is LogWrite function. I created it to easy "search and replace" write-host or write-output
 to LogWrite.
 So if it was 
   write-host "Text to write"
 you can replace it with 
   LogWrite "Text to write" *
*also you need to copy function body and define $global:pathToLogFile variable

Trying to reduce LogWrite paramater count i've defined $global:pathToLogFile variable in your main program.
If this variable is defined before LogWrite call LogWrite uses it's value.
LogWrite dunction paramaters:
    paramTextToWrite - the text to output to both screen and logfile
    paramPathToLogFile - full path (path+filename) to log file, if this paramater is not specified during function call
                        function will try to read $global:pathToLogFile variable value
    ForegroundColor - Color to print your defined in paramTextToWrite text to console (works only with write-host)
                        if not specified, defaults to gray
    NoNewLine - false by default, if true - will not add CRLF after outputed string, Works only with write-host
    AddScriptContentsToLogFile - Function LogWrite with this parameter shoud be called as very last statement of your program
                        will write information environment (Powershell and OS versions) and the content of file being 
                        executed to the end of log file

 Author: Aleksandr Reznik (aleksandr@reznik.lt)
#>

param (
    [string]$paramPathToSaveFiles = $PSScriptRoot +"\" #by default equals to currently run script directory   
)
$global:pathToLogFile = ""
Function LogWrite{
    #prints output to both screen and file, adds currently executed file contents to log
    [CmdletBinding()]
    Param (
    [string]$paramTextToWrite,
    [string]$paramPathToLogFile = "",
    [Parameter(Mandatory=$False)]
    [string]$ForegroundColor = "gray",
    [switch]$NoNewLine,
    [switch]$AddScriptContentsToLogFile #- will add PS and OS versions and content of current file to logfile, this paramater should be used at the end of execution of your program
    )

    if ($paramPathToLogFile -eq ""){#if path to log is not specified in function call parameters - take value from global variable (to avoid writing to many parameters in function call)
        $paramPathToLogFile = $global:pathToLogFile
    }
    if (!$AddScriptContentsToLogFile)
    {    
        $timeStampStr = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
        $str4file = $timeStampStr + " "+ $paramTextToWrite
        
        #adding to file
        Add-content $paramPathToLogFile -value $str4file    
        
        #printing to screen
        if ($NoNewLine){   
            write-host $paramTextToWrite -ForegroundColor $ForegroundColor -NoNewLine
            }
        else{
            write-host $paramTextToWrite -ForegroundColor $ForegroundColor 
        }
    }
    else { #adding PS version, OS version and content of current file to log
        
        #adding Powershell Version
        #$psVersionStr =  $psversiontable.GetEnumerator().ForEach({ "$($_.Name)=$($_.Value)`r`n" }) 
        $psVersionStr ="End of program execution`r`n`r`n`####################################`r`nPowershell version:`r`n$($psversiontable.GetEnumerator().ForEach({ "$($_.Name)=$($_.Value)`r`n" }))"
        Add-content $paramPathToLogFile -value "End of execution`r`n`####################################r`nPowershell version:`r`n$($psVersionStr)"
        write-host $psVersionStr
        
        #adding OS Version
        $osSTR ="`r`n####################################`r`nOS version:`r`n$([Environment]::OSVersion)"   
        Add-content $paramPathToLogFile -value $osStr
        write-host $osSTR
        write-host
        
        #adding current script 
        $currentPS1file = $PSCommandPath
        $sourceCode = Get-Content $currentPS1file -Raw 
        Add-content $paramPathToLogFile -value "`r`n####################################`r`nFILE BEING EXECUTED:`r`n"
        Add-content $paramPathToLogFile -value $sourceCode
        write-output "Output written to $paramPathToLogFile"

    }
}


######################################################################################################
########################################    PROGRAM BEGIN     ########################################
######################################################################################################
$hostname = $env:computername
$benchmarkName = "myCustomBenchmark"

#defining and saving path and filename of log file to global variable
$CurrDateTimeStr=[DateTime]::Now.ToString("yyyyMMdd-HHmmss")
$fileNamePrefix = "$($CurrDateTimeStr)_$($hostname)_$benchmarkName"
$global:pathToLogFile = "$($paramPathToSaveFiles)$($fileNamePrefix).log"

#preparation before starting benchmark
$currOperationName = "Generate random string" 
LogWrite "OperationStart. Operation Name: $currOperationName"
$operationStartTime = Get-Date

#operation we want to benchmark, in this case generation of string of random symbols 
$generatedSTR = -join (1..20000 | ForEach {[char]((97..122) + (48..57) | Get-Random)})
LogWrite "GeneratedStr = $($generatedSTR)"

#preparation after benchmark
$operationEndTime = Get-Date
LogWrite "OperationFinish. Operation Name: $currOperationName"
$operationDuration = $operationEndTime - $operationStartTime
LogWrite "OperationDuration: $($operationDuration)"

#final LogWrite run which add current file contents to log file
LogWrite -AddScriptContentsToLogFile

