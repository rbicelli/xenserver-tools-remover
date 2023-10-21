# clean-xentools.p1
# Removes Citrix Xenserver Tools from a Windows VM
# Version 0.9
# Author: Riccardo Bicelli <r.bicelli@gmail.com>

Write-Host "--------------------------------------------------------------------------------"
Write-Host " Xenserver VM Tools Cleaning Script"
Write-Host "--------------------------------------------------------------------------------"


$xen_svcs=@('XEN','xenbus_monitor','xenagent','xenvif','xenbus','xendisk','xenfilt','xeniface','xennet','xenvbd','xenvif','xeninstall','xensvc','installagent')

Write-Host " Cleaning Services ..."

foreach ( $svc in $xen_svcs) {
    Write-Host " Deleting Service $svc"    
    sc.exe stop $svc
    sc.exe delete $svc
    gwmi win32_pnpentity | % {gwmi -query "select * from win32_systemdriver where name=`"$svc`""} | % {$_.StopService();$_.Delete()}    
}

Write-Host "--------------------------------------------------------------------------------"
Write-Host "Removing Files ..."

rm c:\windows\system32\xen* -fo -Confirm:$false
rm c:\ProgramData\Citrix* -fo -Confirm:$false

Write-Host "--------------------------------------------------------------------------------"
Write-Host " Cleaning Registry ..."

# Cycle through registry in search of drivers with XENFILT as Upperfilter
# This clears the UpperFilter Value in the registry.

$controlsets = @("CurrentcontrolSet","ControlSet001","ControlSet002")

Foreach ($cs in $controlsets) {
    Write-Host "Checking  $cs ..."
    Get-ChildItem "HKLM:\SYSTEM\$cs\Control\Class\*" | ForEach-Object {
          
           if ((Get-ItemProperty "Registry::$_").PSObject.Properties.Name -contains "Upperfilters") {        
        
            if ((Get-ItemProperty -Path "Registry::$_" -Name UpperFilters).UpperFilters -contains "XENFILT") {
                Get-ItemProperty -Path "Registry::$_"                
                Write-Host "Removing XENFILT FROM $_"
                Set-Itemproperty -Path "Registry::$_" -Name UpperFilters -Type MultiString -Value @()                
            }
           }
}

}

Write-Host "--------------------------------------------------------------------------------"
Write-Host " ALL DONE !!!"
Write-Host "--------------------------------------------------------------------------------"
