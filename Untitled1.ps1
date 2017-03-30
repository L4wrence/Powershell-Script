Add-AzureRmAccount

$rg = "lmathurin"
$sql_1 = "lmathurindb"
$sql_2 = "lmathurin"
$db = "table1"
$dbcopy = "$db-copy"
$StorageAccount = "lmathurincloud"
$dbbackup = "db-backup"
$sqlpassword1 = ConvertTo-SecureString "El3phant" -AsPlainText -Force
$credentials1 = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "lmathurin" , $sqlpassword1

New-AzureSBNamespace -Name "lmathurinns" -Location "West Europe" -NamespaceType NotificationHub

New-AzureRmNotificationHub -Namespace "lmathurinns" -ResourceGroup $rg

