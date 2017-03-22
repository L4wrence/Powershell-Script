#Add-AzureRmAccount

<#do
{
    if ($null -ne $rg)
    {
        Write-Host "Sorry Resource Group name taken, try again"
    }

    $rg = Read-Host -Prompt "What would you like to name the new Resource Group?"

}
until (!(Get-AzureRmResourceGroup -ResourceGroupName $rg -ErrorAction Ignore))

New-AzureRmResourceGroup -ResourceGroupName $rg -Location "West Europe"#>

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
