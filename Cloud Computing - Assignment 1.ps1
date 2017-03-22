#Prompts the user to log into their Azure account
Add-AzureRmAccount

#Checks if the Resource Group name is avalibale and will prmpt the user to keep trying a new name until they input one that is avaliable
#https://msdn.microsoft.com/en-us/library/mt603831.aspx
#https://msdn.microsoft.com/en-us/library/mt603739.aspx
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
New-AzureRmResourceGroup -ResourceGroupName $rg -Location "West Europe"

do
{
    if ($null -ne $asp)
    {
        Write-Host "Sorry App Service Plan name taken, try again"
    }

    $asp = Read-Host -Prompt "What would you like to name the new App Service Plan?"

}
until (!(Get-AzureRmAppServicePlan -Name $asp -ErrorAction Ignore))

#Creates a new App Service Plan
#https://docs.microsoft.com/en-us/powershell/resourcemanager/AzureRM.Websites/v2.1.0/new-azurermappserviceplan
New-AzureRmAppServicePlan -ResourceGroupName $rg -Name $asp -location "West Europe"

#https://docs.microsoft.com/en-us/powershell/resourcemanager/AzureRM.Websites/v2.1.0/new-azurermwebapp
#New-AzureRmWebApp -ResourceGroupName $rg

#https://docs.microsoft.com/en-us/powershell/resourcemanager/AzureRM.Websites/v2.1.0/get-azurermwebapp
#Get-AzureRmWebApp -ResourceGroupName $rg

#https://github.com/Microsoft/azure-docs/blob/master/articles/app-service-web/app-service-web-app-azure-resource-manager-powershell.md
