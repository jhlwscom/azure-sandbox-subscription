output "addTagToRG_policy_ids" {
  value       = azurerm_policy_definition.addTagToRG.*.id
  description = "The policy definition ids for addTagToRG policies"
}

output "inheritTagFromRG_policy_ids" {
  value       = azurerm_policy_definition.inheritTagFromRG.*.id
  description = "The policy definition ids for inheritTagFromRG policies"
}

output "inheritTagFromRGOverwriteExisting_policy_ids" {
  value       = azurerm_policy_definition.inheritTagFromRGOverwriteExisting.*.id
  description = "The policy definition ids for inheritTagFromRGOverwriteExisting policies"
}

output "bulkInheritTagsFromRG_policy_id" {
  value       = azurerm_policy_definition.bulkInheritTagsFromRG.id
  description = "The policy definition id for bulkInheritTagsFromRG"
}

output "addCreatedOnTag_policy_id" {
  value       = azurerm_policy_definition.addCreatedOnTag.id
  description = "The policy definition id for addCreatedOnTag"
}

output "restrictCloudShellStorage_policy_id" {
  value       = azurerm_policy_definition.restrictCloudShellStorage.id
  description = "The policy definition id for restrictCloudShellStorage"
}