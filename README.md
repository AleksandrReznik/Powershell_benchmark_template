# Powershell benchmark template
![SaveScriptContentsToLogFile!](https://github.com/AleksandrReznik/Powershell_benchmark_template/blob/main/SaveScriptContentsToLogFile.jpg "SaveScriptContentsToLogFile")
Powershell benchmark template, Defines output to both screen and log file and saves currently executed file to log file  

Main thing in this script is LogWrite function. I created it to easy "search and replace" write-host or write-output
 to LogWrite.  
 
 So if it was  
&nbsp;&nbsp;&nbsp;&nbsp;write-host "Text to write"  
you can replace it with  
&nbsp;&nbsp;&nbsp;&nbsp;LogWrite "Text to write" *  
*also you need to copy function body and define $global:pathToLogFile variable  

Trying to reduce LogWrite paramater count i've defined $global:pathToLogFile variable in your main program.  
If this variable is defined before LogWrite call LogWrite uses it's value.  
LogWrite dunction paramaters:  
- paramTextToWrite - the text to output to both screen and logfile  
- paramPathToLogFile - full path (path+filename) to log file, if this paramater is not specified during function call  
                        function will try to read $global:pathToLogFile variable value  
- ForegroundColor - Color to print your defined in paramTextToWrite text to console (works only with write-host)  
                        if not specified, defaults to gray  
- NoNewLine - false by default, if true - will not add CRLF after outputed string, Works only with write-host  
- AddScriptContentsToLogFile - Function LogWrite with this parameter shoud be called as very last statement of your program  
                        will write information environment (Powershell and OS versions) and the content of file being   
                        executed to the end of log file  
