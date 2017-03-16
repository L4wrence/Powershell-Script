#Prompts the user to log into their Azure account
Add-AzureRmAccount

#$rg = Read-Host -Prompt "What would you like to name the new Resource Group"

#Check to see if Resource Group is avaliable or not, if it is then create a new resource group with the given name,
#if not then prompt the user to give a new name and create the resource group with that name 
#https://msdn.microsoft.com/en-us/library/mt603831.aspx
#https://msdn.microsoft.com/en-us/library/mt603739.aspx
#if (!(Get-AzureRmResourceGroup -ResourceGroupName $rg -ErrorAction Ignore)) 
#{
#    New-AzureRmResourceGroup -ResourceGroupName $rg -Location "West Europe"
#} 
#else {
#   $rg = Read-Host -Prompt "Resouce Group name not avaliable, please select another"
#   New-AzureRmResourceGroup -ResourceGroupName $rg -Location "West Europe"
#}

do
{
    $rg = Read-Host -Prompt "What would you like to name the new Resource Group"
    New-AzureRmResourceGroup -ResourceGroupName $rg -Location "West Europe"
}
while (!(Get-AzureRmResourceGroup -ResourceGroupName $rg -ErrorAction Ignore))
