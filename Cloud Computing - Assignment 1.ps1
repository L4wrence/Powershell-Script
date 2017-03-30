#Create a Resource Group (DONE)
#Create an App Service Plan (DONE)
#Create the first web app (DONE)
#Create the second web app (DONE)
#Open both webapps in internet explorer (DONE)
#Display the number of webapps that are currently deployed the app service plan (DONE)

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

#Creates the new App Service Plan, the pricing tier for it needs to be set to standard otherwise we won't be able to back them up later on
#https://docs.microsoft.com/en-us/powershell/resourcemanager/AzureRM.Websites/v2.1.0/new-azurermappserviceplan
New-AzureRmAppServicePlan -ResourceGroupName $rg -Name $asp -location "West Europe" -Tier Standard

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

    $wa2 = Read-Host -Prompt "What would you like to name the second new Web App to be deployed in East US?"

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

#Show SQL capability for West Europe (DONE)
#Create SQL Server A in West Europe and firewall rule (DONE)
#Create SQL Server B in US East and firewall rule (DONE)
#Include credentials as part of the script (DONE)
#Deploy database to Server A (DONE)
#Copy database from SQL Server A to SQL Server B (DONE)

#Getting the SQL capabilities of the servers will show us wether or not a SQL Server is able to be deployed and if so, what version number we can deploy to it
#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.sql/v2.3.0/get-azurermsqlcapability
Get-AzureRmSqlCapability -LocationName "West Europe"

Get-AzureRmSqlCapability -LocationName "East US"

#Prompts the user for a name for the SQL Server and then attempts too create it. If an error is thrown the error message pops up and then re-prompts the user to enter a new name
do
{
    $sql_1 = Read-Host -Prompt "What would you like to name the first SQL Sever?"

    #To avoid a prompt fot the SQL credentials from appearing when running the script we need to add a credentials parameter to the New-AzureRmSqlServer cmdlet
    #https://docs.microsoft.com/en-us/azure/sql-database/sql-database-get-started-powershell
    $sqlpassword1 = ConvertTo-SecureString "El3phant" -AsPlainText -Force

    $credentials1 = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "lmathurin" , $sqlpassword1

    try
    {
        #Attempts to create the SQL server but will loop back around if an error is thrown
        #https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.sql/v2.1.0/new-azurermsqlserver
        New-AzureRmSqlServer -ResourceGroupName $rg -Location "West Europe" -ServerName $sql_1 -ServerVersion "12.0" -SqlAdministratorCredentials $credentials1 -ErrorAction Stop
    }
    catch
    {
        Write-Host ""
        $error[0]|select -expand exception
        Write-Host ""
    }
}
while (!(Get-AzureRmSqlServer -ResourceGroupName $rg -ServerName $sql_1 -ErrorAction Ignore))

Write-Host "Setting Firewall Rule.."

#Without a firewall rule remote access to the server  will be locked down and you will not be able to access it
#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.sql/v2.1.0/new-azurermsqlserverfirewallrule
New-AzureRmSqlServerFirewallRule -ResourceGroupName $rg -ServerName $sql_1 -FirewallRuleName "Everything" -StartIpAddress "0.0.0.0" -EndIpAddress "255.255.255.255"

do
{
    $sql_2 = Read-Host -Prompt "What would you like to name the second SQL Sever?"

    $sqlpassword2 = ConvertTo-SecureString "El3phant" -AsPlainText -Force

    $credentials2 = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "lmathurin" , $sqlpassword2

    try
    {
        New-AzureRmSqlServer -ResourceGroupName $rg -Location "East US" -ServerName $sql_2 -ServerVersion "12.0" -SqlAdministratorCredentials $credentials2 -ErrorAction Stop
    }
    catch
    {
        Write-Host ""
        $error[0]|select -expand exception
        Write-Host ""
    }
}
while (!(Get-AzureRmSqlServer -ResourceGroupName $rg -ServerName $sql_2 -ErrorAction Ignore))

Write-Host "Setting Firewall Rule.."
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

#Creates a blank database in the first SQL Server we created ready for it to be copied to the second SQL Sevrer
#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.sql/v2.2.0/new-azurermsqldatabase
New-AzureRmSqlDatabase -DatabaseName $db -ServerName $sql_1 -ResourceGroupName $rg

$dbcopy = "$db-copy"
Write-Host "Copying $db in $sql_1 to $sql_2 as $dbcopy"

#Copies over the data from the SQL Database in Server A to Server B
#https://docs.microsoft.com/en-us/azure/sql-database/scripts/sql-database-copy-database-to-new-server-powershell
New-AzureRmSqlDatabaseCopy -ResourceGroupName $rg -ServerName $sql_1 -DatabaseName $db -CopyResourceGroupName $rg -CopyServerName $sql_2 -CopyDatabaseName $dbcopy

<#*********************************************************************************************************************************************************************#>
<#*********************************************************************************************************************************************************************#>
<#*********************************************************************************************************************************************************************#>
<#*********************************************************************************************************************************************************************#>
<#*********************************************************************************************************************************************************************#>

#Create Azure BLOB Storage (DONE)
#Export DB .bacpac on SQL Server A to BLOB storage (DONE)
#Get status of export operation (DONE)
#Create SQL Server C with firewall rule in Canada East (DONE)
#Restore .bacpac from BLOB storage to SQL Server C (DONE)
#Get status of import operation (DONE)
#Backup both webapps to BLOB storage (DONE)
#Create new notification hub to resource group (IMPOSSIBLE?)

#Before we can export the SQL Database to BLOB Storage we need to create the Storage Account we wish to store it in 
do
{
    $StorageAccount = Read-Host -Prompt "What would you like to name the Storage Account?"

    try
    {
        New-AzureRmStorageAccount -ResourceGroupName $rg -AccountName $StorageAccount -Location "West Europe" -Type "Standard_LRS" -ErrorAction Stop
    }
    catch
    {
        Write-Host ""
        $error[0]|select -expand exception
        Write-Host ""
    }
}
until (Get-AzureRmStorageAccount -ResourceGroupName $rg -Name $StorageAccount -ErrorAction Ignore)

#Set the storage account we just created as the default for the azure account, this means we no longer need to specify the ResourceGroupName and StorageAccountName parameters
#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.storage/v2.2.0/set-azurermcurrentstorageaccount
Set-AzureRmCurrentStorageAccount -ResourceGroupName $rg -StorageAccountName $StorageAccount

#Before we can back up the database we need to create a container within our storage account for it to be stored in, again we are checking if the contrainer name is avaliable befroe we create it
do
{
    if ($null -ne $dbbackup)
    {
        Write-Host "Sorry that folder already exists, please try again"
    }

    $dbbackup = Read-Host -Prompt "Please create a new folder to store DB backups"

}#https://docs.microsoft.com/en-us/powershell/storage/azure.storage/v2.1.0/get-azurestoragecontainer
until (!(Get-AzureStorageContainer -Name $dbbackup -ErrorAction Ignore))

#https://docs.microsoft.com/en-us/powershell/storage/azure.storage/v2.1.0/new-azurestoragecontainer
New-AzureStorageContainer -Name $dbbackup -Permission Blob

#https://docs.microsoft.com/en-us/azure/sql-database/sql-database-export-powershell

$dbbacpac = $db + "-" + (Get-Date).ToString("yyyyMMddHHmm") + ".bacpac"

#A storage key is needed before we can access the container 
#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.storage/v2.3.0/get-azurermstorageaccountkey
$StorageKey = (Get-AzureRmStorageAccountKey -Name $StorageAccount -ResourceGroupName $rg)[0].Value

$StorageFolder = "https://$StorageAccount.blob.core.windows.net/$dbbackup/"

$StorageUri = $StorageFolder + $dbbacpac

#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.sql/v2.1.0/new-azurermsqldatabaseexport
$export = New-AzureRmSqlDatabaseExport -ResourceGroupName $rg -ServerName $sql_1 -DatabaseName $db -StorageKeytype "StorageAccessKey" -StorageKey $StorageKey -StorageUri $StorageUri -AdministratorLogin $credentials1.UserName -AdministratorLoginPassword $credentials1.Password

#This gives the export status, and the code won't continue to the next part until the databse has been sucessfully been backed up
try
{
    $export
}
catch
{
        Write-Host ""
        $error[0]|select -expand exception
        Write-Host ""
}

#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.sql/v2.3.0/get-azurermsqldatabaseimportexportstatus
Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $export.OperationStatusLink

do{
}
until ((Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $export.OperationStatusLink | % {$_.Status }) -eq "Succeeded")

Write-Host "Database Sucessfully exported"

do
{
    $sql_3 = Read-Host -Prompt "What would you like to name the third SQL Sever?"

    $sqlpassword3 = ConvertTo-SecureString "El3phant" -AsPlainText -Force

    $credentials3 = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "lmathurin" , $sqlpassword3

    try
    {
        New-AzureRmSqlServer -ResourceGroupName $rg -Location "Canada East" -ServerName $sql_3 -ServerVersion "12.0" -SqlAdministratorCredentials $credentials3 -ErrorAction Stop
    }
    catch
    {
        Write-Host ""
        $error[0]|select -expand exception
        Write-Host ""
    }
}
while (!(Get-AzureRmSqlServer -ResourceGroupName $rg -ServerName $sql_3 -ErrorAction Ignore))

Write-Host "Setting Firewall rule..."
New-AzureRmSqlServerFirewallRule -ResourceGroupName $rg -ServerName $sql_3 -FirewallRuleName "Everything" -StartIpAddress "0.0.0.0" -EndIpAddress "255.255.255.255"

#https://github.com/Azure/azure-content-nlnl/blob/master/articles/sql-database/sql-database-import-powershell.md
#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.sql/v2.2.0/new-azurermsqldatabaseimport
$import = New-AzureRmSqlDatabaseImport -ResourceGroupName $rg -ServerName $sql_3 -DatabaseName $db -StorageKeytype "StorageAccessKey" -StorageKey $StorageKey -StorageUri $StorageUri -AdministratorLogin $credentials1.UserName -AdministratorLoginPassword $credentials1.Password -Edition Standard -ServiceObjectiveName s0 -DatabaseMaxSizeBytes 50000 -ErrorAction Stop

#Just like when exporting the database, the code won't move on to the next part until the database has been sucessfully imported to the new SQL Server
try
{
    $import
}
catch
{
        Write-Host ""
        $error[0]|select -expand exception
        Write-Host ""
}

Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $import.OperationStatusLink

do{
}
until ((Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $import.OperationStatusLink | % {$_.Status }) -eq "Succeeded")

Write-Host "Database Sucessfully imported"

do
{
    if ($null -ne $wabackup)
    {
        Write-Host "Sorry that folder already exists, please try again"
    }

    $wabackup = Read-Host -Prompt "Please create a new folder to store Web App backups"

}
until (!(Get-AzureStorageContainer -Name $wabackup -ErrorAction Ignore))

New-AzureStorageContainer -Name $wabackup -Permission Blob


$StorageKey = (Get-AzureRmStorageAccountKey -Name $StorageAccount -ResourceGroupName $rg)[0].Value
$context = New-AzureStorageContext -StorageAccountName $storageAccount -StorageAccountKey $storageKey

#This creates a SAS url to be used when backing up the web apps to BLOB storage
#https://msdn.microsoft.com/en-us/library/azure/dn584416.aspx
$sasUrl = New-AzureStorageContainerSASToken -Name $wabackup -Permission rwdl -Context $context -ExpiryTime (Get-Date).AddMonths(1) -FullUri

$wabackup1 = $wa1 + "-" + (Get-Date).ToString("yyyyMMddHHmm")
$wabackup2 = $wa2 + "-" + (Get-Date).ToString("yyyyMMddHHmm")

#https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.websites/v2.2.0/new-azurermwebappbackup
New-AzureRmWebAppBackup -ResourceGroupName $rg -Name $wa1 -StorageAccountUrl $sasUrl -BackupName $wabackup1
New-AzureRmWebAppBackup -ResourceGroupName $rg -Name $wa2 -StorageAccountUrl $sasUrl -BackupName $wabackup2


