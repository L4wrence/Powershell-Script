#Prompts the user to log into their Azure account
Add-AzureRmAccount

#$rg = Read-Host -Prompt "What would you like to name the new Resource Group"

#Check to see if Resource Group is avaliable or not, if it is then create a new resource group with the given name,
#if not then prompt the user to give a new name and create the resource group with that name 
#https://msdn.microsoft.com/en-us/library/mt603831.aspx
#https://msdn.microsoft.com/en-us/library/mt603739.aspx
<#do
{
    $rg = Read-Host -Prompt "What would you like to name the new Resource Group"
    if (!(Get-AzureRmResourceGroup -ResourceGroupName $rg -ErrorAction Ignore)) 
    {
        New-AzureRmResourceGroup -ResourceGroupName $rg -Location "West Europe"
    } 
    else {
        $rg = Read-Host -Prompt "Resouce Group name not avaliable, please select another"
        New-AzureRmResourceGroup -ResourceGroupName $rg -Location "West Europe"
    }
    
}
while (!(Get-AzureRmResourceGroup -ResourceGroupName $rg -ErrorAction Ignore))
#>
#do
#{
#    $rg = Read-Host -Prompt "What would you like to name the new Resource Group"
#     New-AzureRmResourceGroup -ResourceGroupName $rg -Location "West Europe"
#}
#while (!(Get-AzureRmResourceGroup -ResourceGroupName $rg -ErrorAction Ignore))

do
{
    if (!(Get-AzureRmResourceGroup -ResourceGroupName $rg -ErrorAction Ignore))
    {
        Write-Host -Prompt "Resouce Group name not avaliable"
        
    }

    $rg = Read-Host -Prompt "What would you like to name the new Resource Group?"
    New-AzureRmResourceGroup -ResourceGroupName $rg -Location "West Europe"
}
until (Get-AzureRmResourceGroup -ResourceGroupName $rg)

do
{
    # coming round from a previous loop, $num exists, indicating this is a retry.
    if ($null -ne $num) { Write-Host "Sorry, try again" }

    [int]$num = Read-Host "Enter a number"

} until ($num -gt 10)
