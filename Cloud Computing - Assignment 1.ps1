#Prompts the user to log into their Azure account
Add-AzureRmAccount

$ResourceGroup = Read-Host -Prompt "What would you like to name the new Resource Group"

New-AzureRmResourceGroup -Name $ResourceGroup -Location "West Europe"