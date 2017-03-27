#Blob srorage http://derekfoster.cloudapp.net/cc2017/workshop4.htm

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

#Before any webapps can be deployed an App service plan is needed, We will check to see if the App Service Plan name is avalible or not before attempting to create it
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

#Creates a new App Service Plan
#https://docs.microsoft.com/en-us/powershell/resourcemanager/AzureRM.Websites/v2.1.0/new-azurermappserviceplan
New-AzureRmAppServicePlan -ResourceGroupName $rg -Name $asp -location "West Europe"

#Before any webapps can be created we need to check if the name the user wants to call the web app is avaliable
#https://docs.microsoft.com/en-us/powershell/resourcemanager/AzureRM.Websites/v2.1.0/get-azurermwebapp
do
{
    if ($null -ne $wa1)
    {
        Write-Host "Sorry Web App name taken, try again"
    }

    $wa1 = Read-Host -Prompt "What would you like to name the new Web App?"

}
until (!(Get-AzureRmWebApp -Name $wa1 -ResourceGroupName $rg -ErrorAction Ignore))

#https://docs.microsoft.com/en-us/powershell/resourcemanager/AzureRM.Websites/v2.1.0/new-azurermwebapp
New-AzureRmWebApp -ResourceGroupName $rg -AppServicePlan $asp -Name $wa2 -Location "West Europe"

do
{
    if ($null -ne $wa2)
    {
        Write-Host "Sorry Web App name taken, try again"
    }

    $wa2 = Read-Host -Prompt "What would you like to name the new Web App?"

}
until (!(Get-AzureRmWebApp -Name $wa2 -ResourceGroupName $rg -ErrorAction Ignore))

New-AzureRmWebApp -ResourceGroupName $rg -AppServicePlan $asp -Name $wa2 -Location "West Europe"

$webapp1 = "http://$wa1.azurewebsites.net"
$webapp2 = "http://$wa2.azurewebsites.net"

#Opens the newly created webapps in internet explorer
#https://blogs.msdn.microsoft.com/powershell/2006/09/10/controlling-internet-explorer-object-from-powershell/
$IE = new-object -com internetexplorer.application
$IE.navigate2($webapp1)
$IE.visible = $true

Get-AzureRmWebApp -ResourceGroupName $rg

#https://github.com/Microsoft/azure-docs/blob/master/articles/app-service-web/app-service-web-app-azure-resource-manager-powershell.md
