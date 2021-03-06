# Managed Storage Account
# Reference: https://docs.microsoft.com/en-us/azure/key-vault/key-vault-overview-storage-keys-powershell

# Authorize Key Vault to access to your storage account

# Create a storage account
New-AzStorageAccount -ResourceGroupName 'oreilly' `
    -Name 'oreillystg7837' `
    -Location 'eastus2' `
    -SkuName Standard_LRS `
    -Kind StorageV2

# TODO: Update with the resource group where your storage account resides, your storage account name, the name of your active storage account key, and your Key Vault instance name
$resourceGroupName = "oreilly"
$storageAccountName = "oreillystg7837"
$storageAccountKey = ""
$keyVaultName = "oreilly-keyvault"
$keyVaultSpAppId = "cfa8b339-82a2-471a-a3c9-0fc0be7a4093" # See "IMPORTANT" block above for information on Key Vault Application IDs

# Ref: https://docs.microsoft.com/en-us/azure/key-vault/key-vault-overview-storage-keys-powershell

# Authenticate your PowerShell session with Azure AD
$azureProfile = Connect-AzAccount

# Get a reference to your Azure storage account
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName

# Assign RBAC role "Storage Account Key Operator Service Role" to Key Vault, limiting the access scope to your storage account.
New-AzRoleAssignment -ApplicationId $keyVaultSpAppId -RoleDefinitionName 'Storage Account Key Operator Service Role' -Scope $storageAccount.Id

# Give your user principal access to all storage account permissions, on your Key Vault instance

Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -UserPrincipalName $azureProfile.Context.Account.Id -PermissionsToStorage get, list, listsas, delete, set, update, regeneratekey, recover, backup, restore, purge

# Add your storage account to your Key Vault's managed storage accounts
Add-AzKeyVaultManagedStorageAccount -VaultName $keyVaultName -AccountName $storageAccountName -AccountResourceId $storageAccount.Id -ActiveKeyName $storageAccountKey -DisableAutoRegenerateKey

# Enable key regeneration
$regenPeriod = [System.Timespan]::FromDays(3)
Add-AzKeyVaultManagedStorageAccount -VaultName $keyVaultName -AccountName $storageAccountName -AccountResourceId $storageAccount.Id -ActiveKeyName $storageAccountKey -RegenerationPeriod $regenPeriod