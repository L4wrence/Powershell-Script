#Prompts the user to log into their Azure account
Add-AzureRmAccount

$Rg = Read-Host -Prompt "What would you like to name the new Resource Group"

if () {
New-AzureRmResourceGroup -Name $Rg -Location "West Europe"
}