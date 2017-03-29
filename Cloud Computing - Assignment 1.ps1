#The user first needs to login in to their Azure account before any thing can be created
Add-AzureRmAccount

#A Resource group needs to be created. We will check that the resource group name that they want to use is avaliable or not before attempting to create it to avoid any errors
#https://msdn.microsoft.com/en-us/library/mt603831.aspx
do
{
    if ($null -ne $rg)
    {
        Write-Host "Sorry that Resource Group name isn't avaliable, try again"
    }

    $rg = Read-Host -Prompt "What would you like to name the new Resource Group?"

}
until (!(Get-AzureRmResourceGroup -ResourceGroupName $rg -ErrorAction Ignore))

#Creates a new Resource Group using the name that was checked against the Azure account
#https://msdn.microsoft.com/en-us/library/mt603739.aspx
New-AzureRmResourceGroup -ResourceGroupName $rg -Location "West Europe"

#Before any webapps can be deployed an App service plan is needed, we will check to see if the App Service Plan name is avalible or not before attempting to create it
#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.websites/v2.1.0/get-azurermappserviceplan
do
{
    if ($null -ne $asp)
    {
        Write-Host "Sorry App Service Plan name taken, try again"
    }

    $asp = Read-Host -Prompt "What would you like to name the new App Service Plan?"

}
until (!(Get-AzureRmAppServicePlan -ResourceGroupName $rg -Name $asp -ErrorAction Ignore))

#Creates the new App Service Plan
#https://docs.microsoft.com/en-us/powershell/resourcemanager/AzureRM.Websites/v2.1.0/new-azurermappserviceplan
New-AzureRmAppServicePlan -ResourceGroupName $rg -Name $asp -location "West Europe"

#Before any webapps can be deployed we need to check if the name the user wants for the web app is avaliable before we attept to create it
#https://docs.microsoft.com/en-us/powershell/resourcemanager/AzureRM.Websites/v2.1.0/get-azurermwebapp
do
{
    if ($null -ne $wa1)
    {
        Write-Host "Sorry Web App name taken, try again"
    }

    $wa1 = Read-Host -Prompt "What would you like to name the new Web App to be deployed in West Europe?"

}
until (!(Get-AzureRmWebApp -Name $wa1 -ResourceGroupName $rg -ErrorAction Ignore))

#Creates the first webapp
#https://docs.microsoft.com/en-us/powershell/resourcemanager/AzureRM.Websites/v2.1.0/new-azurermwebapp
New-AzureRmWebApp -ResourceGroupName $rg -AppServicePlan $asp -Name $wa1 -Location "West Europe"

do
{
    if ($null -ne $wa2)
    {
        Write-Host "Sorry Web App name taken, try again"
    }

    $wa2 = Read-Host -Prompt "What would you like to name the second new Web App to be deplyed in East US?"

}
until (!(Get-AzureRmWebApp -Name $wa2 -ResourceGroupName $rg -ErrorAction Ignore))

#Creates the second webapp
New-AzureRmWebApp -ResourceGroupName $rg -AppServicePlan $asp -Name $wa2 -Location "East US"

$webapp1 = Get-AzureRmWebApp -ResourceGroupName $rg -Name $wa1 | % {$_.DefaultHostName}
$webapp2 = Get-AzureRmWebApp -ResourceGroupName $rg -Name $wa2 | % {$_.DefaultHostName}

#Opens the newly created webapps in internet explorer
#https://blogs.msdn.microsoft.com/powershell/2006/09/10/controlling-internet-explorer-object-from-powershell/
Write-Host "Opening the first webapp: $wa1"
$IE = new-object -com internetexplorer.application
$IE.navigate2($webapp1)
$IE.visible = $true

Write-Host "Opening the second webapp: $wa2"
$IE = new-object -com internetexplorer.application
$IE.navigate2($webapp2)
$IE.visible = $true

#Now we need to find out the number of webapps deployed to the current app plan. And then list their names
$wanpre = Get-AzureRmWebApp -ResourceGroupName $rg
$wanpost =$wanpre.count
Write-Host "You currently have $wanpost of webapp(s) deployed."

Write-Host "Deployed Webapps:"
Get-AzureRmWebApp -ResourceGroupName $rg | % {$_.Name }

<#*********************************************************************************************************************************************************************#>
<#*********************************************************************************************************************************************************************#>
<#*********************************************************************************************************************************************************************#>
<#*********************************************************************************************************************************************************************#>
<#*********************************************************************************************************************************************************************#>

#Show SQL capability for West Europe DONE
#Create SQL Server A in West Europe and firewall rule DONE
#Create SQL Server B in US East and firewall rule DONE
#Include credentials as part of the script DONE
#Deploy database to Server A
#Copy database from SQL Server A to SQL Server B

#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.sql/v2.3.0/get-azurermsqlcapability
Get-AzureRmSqlCapability -LocationName "West Europe"

Get-AzureRmSqlCapability -LocationName "East US"

do
{
    $sql_1 = Read-Host -Prompt "What would you like to name the first SQL Sever?"

    #https://docs.microsoft.com/en-us/azure/sql-database/sql-database-get-started-powershell
    $sqlpassword = ConvertTo-SecureString "El3phant" -AsPlainText -Force

    $credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "lmathurin" , $sqlpassword

    try
    {
        #https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.sql/v2.1.0/new-azurermsqlserver
        New-AzureRmSqlServer -ResourceGroupName $rg -Location "West Europe" -ServerName $sql_1 -ServerVersion "12.0" -SqlAdministratorCredentials $credentials -ErrorAction Stop
    }
    catch
    {
        Write-Host ""
        $error[0]|select -expand exception
        Write-Host ""
    }
}
while (!(Get-AzureRmSqlServer -ResourceGroupName $rg -ServerName $sql_1 -ErrorAction Ignore))

#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.sql/v2.1.0/new-azurermsqlserverfirewallrule
New-AzureRmSqlServerFirewallRule -ResourceGroupName $rg -ServerName $sql_1 -FirewallRuleName "Everything" -StartIpAddress "0.0.0.0" -EndIpAddress "255.255.255.255"

do
{
    $sql_2 = Read-Host -Prompt "What would you like to name the second SQL Sever?"

    $sqlpassword = ConvertTo-SecureString "El3phant" -AsPlainText -Force

    $credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "lmathurin" , $sqlpassword

    try
    {
        New-AzureRmSqlServer -ResourceGroupName $rg -Location "East US" -ServerName $sql_2 -ServerVersion "12.0" -SqlAdministratorCredentials $credentials -ErrorAction Stop
    }
    catch
    {
        Write-Host ""
        $error[0]|select -expand exception
        Write-Host ""
    }
}
while (!(Get-AzureRmSqlServer -ResourceGroupName $rg -ServerName $sql_2 -ErrorAction Ignore))

New-AzureRmSqlServerFirewallRule -ResourceGroupName $rg -ServerName $sql_2 -FirewallRuleName "Everything" -StartIpAddress "0.0.0.0" -EndIpAddress "255.255.255.255"

do
{
    if ($null -ne $db)
    {
        Write-Host "Sorry that Database name isn't avaliable, try again"
    }

    $db = Read-Host -Prompt "What would you like to name the new SQL Database?"

}
until (!(Get-AzureRmSqlDatabase -ResourceGroupName $rg -ServerName $sql_1 -DatabaseName $db -ErrorAction Ignore))

#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.sql/v2.2.0/new-azurermsqldatabase
New-AzureRmSqlDatabase -DatabaseName $db -ServerName $sql_1 -ResourceGroupName $rg














<#*********************************************************************************************************************************************************************#>
<#*********************************************************************************************************************************************************************#>
<#*********************************************************************************************************************************************************************#>
<#*********************************************************************************************************************************************************************#>
<#*********************************************************************************************************************************************************************#>

#Create Azure BLOB Storage (http://derekfoster.cloudapp.net/cc2017/workshop4.htm)
#Export DB .bacpac on SQL Server A to BLOB storage
#Get status of export operation
#Create SQL Server C with firewall rule in Canada East
#Restore .bacpac from BLOB storage to SQL Server C
#Get status of import operation
#Backup both webapps to BLOB storage
#Create new notification hub to resource group

#https://docs.microsoft.com/en-us/azure/sql-database/sql-database-export-powershell

#https://github.com/Azure/azure-content-nlnl/blob/master/articles/sql-database/sql-database-import-powershell.md

#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.notificationhubs/v2.2.0/new-azurermnotificationhub
New-AzureRmNotificationHub

