terraform {
  required_providers {
    azurerm = {
      version = "3.14.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-sandbox"
    storage_account_name = "sttfstatesandbox"
    container_name       = "tfstate-sandbox"
    key                  = "tfstate-sandbox.tfstate"
  }
}

provider "azurerm" {
  features {}
}

module "policy_definitions" {
  source = "./modules/policy-definitions"

}

module "policy_assignments" {
  source = "./modules/policy-assignments"

  region                      = var.default_region
  tag_governance_policyset_id = module.policyset_definitions.tag_governance_policyset_id
}

module "policyset_definitions" {
  source = "./modules/policyset-definitions"

  custom_policies_tag_governance = [
    {
      policyID = module.policy_definitions.addTagToRG_policy_ids[0]
    },
    {
      policyID = module.policy_definitions.inheritTagFromRG_policy_ids[0]
    },
    {
      policyID = module.policy_definitions.inheritTagFromRGOverwriteExisting_policy_ids[0]
    },
    {
      policyID = module.policy_definitions.bulkInheritTagsFromRG_policy_id
    }
  ]


}
