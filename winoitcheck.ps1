# Windows OIT Check
#
# Revision 0.1 2017-04-24
#
# author: Gareth Darby
# contact: garethdarby@gmail.com
# blog post: http://www.rootshell.me/2017/05/observeit-win-oitcheck-tool.html
#
# DESCRIPTION
# This tool enables an administrator to verify an ObserveIT agent installation 
# on windows, similar to the ObserveIT linux tool oitcheck.  Currently, as of 
# version 6.6.2 a windows diagnostic tool is not provided by ObserveIT and 
# therefore I decided to create my own to aid rollouts and/or installations by
# users who do not have access to the Web console GUI.
#
# USAGE 
# ./winoitcheck.ps1
#
# TROUBLESHOOTING
# n/a
#
# LIMITATIONS
#
# Currently, this tool has only been confirmed wokring on Windows 2012 
# Server Standard running Powershell 4.0 using default ObserveIT settings.
# 
#
# LICENSE
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.   
#
# CHANGELOG
# V0.2 - Display installed ObserveIT version, re-defined how the service information is obtained and displayed 
# v0.1 - Initial Release
#

write-host "winoitcheck V0.1 2017-04-24"
write-Host "NOTE: This program is not endorsed by ObserveIT"
write-host
$Platform = Get-WmiObject -class Win32_OperatingSystem
write-host "Detected platform:" $Platform.caption
write-host

write-host "Checking for ObserveIT in Installed programs: " -NoNewLine
$Installed = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -match "ObserveIT Agent"}
if ($installed) {
 write-host "PASS - Version"$Installed.DisplayVersion -foregroundcolor "green"
 write-host 
} else {
 write-host "FAILED" -foregroundcolor "red"
 write-host   
}

write-host "Check for ObserveIT agent service: " -NoNewLine
#$service = Get-Service -name "ObserveIT Service Components Controller"
$service = Get-WmiObject -Class Win32_Service -Filter "Name='ObserveIT Service Components Controller'"
if ($service) {
    write-host "PASS" -foregroundcolor "green"
    write-host "ObserveIT Service Components Controller is"$service.state
    write-host "Service Startup Type :"$service.startmode
    write-host "Process ID           :"$service.ProcessId
    write-host
} else {
    write-host "FAILED" -foregroundcolor "red"
    write-host
}

write-host "Check for ObserveIT registry keys: " -NoNewLine
try { $config = Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\ObserveIT -erroraction stop
        if ($config) {
            write-host "PASS" -foregroundcolor "green"
            write-host
            write-host "HostURL     :"$config.AppSrvUrl
            write-host "Install Dir :"$config.TargetDir
            write-host "Server ID   :"$config.ServerID
            write-host "Agent Type  :"$config.AgentType
            write-host
        }
    } catch {
        write-host "FAILED - REASON:"$_.Exception.Message -foregroundcolor "red"
        write-host
    }

write-host "Check for registration by remote app server: " -NoNewLine
$URI = $config.AppSrvUrl+"/registerservermanager.asmx"
$SOAP = '<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"  
xmlns:ns2="http://ObserveIT.WebServices/RegisterServerManager.asmx/" 
xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <SOAP-ENV:Body>
      <ns2:GetServerInstallationStatus>
         <ns2:serverId>'+$config.ServerId+'</ns2:serverId>
      </ns2:GetServerInstallationStatus>
   </SOAP-ENV:Body>
</SOAP-ENV:Envelope>'
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("charset", 'utf-8')
$headers.Add("SOAPAction", 'http://ObserveIT.WebServices/RegisterServerManager.asmx/GetServerInstallationStatus')
try { [XML]$result = (iwr $URI -headers $headers –body $SOAP –contentType "text/xml" –method POST)
    if ($result) {
        if ($result.Envelope.Body.GetServerInstallationStatusResponse.GetServerInstallationStatusResult -eq "Default"){
            write-host "PASS" -foregroundcolor "green"
            write-host 
        } else {
            write-host "FAILED - REASON:"$result.Envelope.body.GetServerInstallationStatusResponse.GetServerInstallationStatusResult -foregroundcolor "red"
            write-host   
        }
    }
} catch {
            write-host "FAILED - REASON:"$_.Exception.Message -foregroundcolor "red"
            write-host
}
