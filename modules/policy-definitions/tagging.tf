resource "azurerm_policy_definition" "addTagToRG" {
  count = length(var.mandatory_tag_keys)

  name         = "addTagToRG_${var.mandatory_tag_keys[count.index]}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Add tag ${var.mandatory_tag_keys[count.index]} to resource group"
  description  = "Adds the mandatory tag key ${var.mandatory_tag_keys[count.index]} when any resource group missing this tag is created or updated. \nExisting resource groups can be remediated by triggering a remediation task.\nIf the tag exists with a different value it will not be changed."

  metadata = jsonencode(
    {
      "category" : "${var.policy_definition_category}",
      "version" : "1.0.0"
    }
  )
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "type",
            "equals" : "Microsoft.Resources/subscriptions/resourceGroups"
          },
          {
            "field" : "[concat('tags[', parameters('tagName'), ']')]",
            "exists" : "false"
          }
        ]
      },
      "then" : {
        "effect" : "modify",
        "details" : {
          "roleDefinitionIds" : [
            "/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
          ],
          "operations" : [
            {
              "operation" : "add",
              "field" : "[concat('tags[', parameters('tagName'), ']')]",
              "value" : "[parameters('tagValue')]"
            }
          ]
        }
      }
    }
  )
  parameters = jsonencode(
    {
      "tagName" : {
        "type" : "String",
        "metadata" : {
          "displayName" : "Mandatory Tag ${var.mandatory_tag_keys[count.index]}",
          "description" : "Name of the tag, such as ${var.mandatory_tag_keys[count.index]}"
        },
        "defaultValue" : "${var.mandatory_tag_keys[count.index]}"
      },
      "tagValue" : {
        "type" : "String",
        "metadata" : {
          "displayName" : "Tag Value '${var.mandatory_tag_value}'",
          "description" : "Value of the tag, such as '${var.mandatory_tag_value}'"
        },
        "defaultValue" : "${var.mandatory_tag_value}"
      }
    }
  )
}

resource "azurerm_policy_definition" "inheritTagFromRG" {
  count = length(var.mandatory_tag_keys)

  name         = "inheritTagFromRG_${var.mandatory_tag_keys[count.index]}"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Inherit tag ${var.mandatory_tag_keys[count.index]} from the resource group"
  description  = "Adds the specified mandatory tag ${var.mandatory_tag_keys[count.index]} with its value from the parent resource group when any resource missing this tag is created or updated. Existing resources can be remediated by triggering a remediation task. If the tag exists with a different value it will not be changed."

  metadata = jsonencode(
    {
      "category" : "${var.policy_definition_category}",
      "version" : "1.0.0"
    }
  )
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "[concat('tags[', parameters('tagName'), ']')]",
            "exists" : "false"
          },
          {
            "value" : "[resourceGroup().tags[parameters('tagName')]]",
            "notEquals" : ""
          }
        ]
      },
      "then" : {
        "effect" : "modify",
        "details" : {
          "roleDefinitionIds" : [
            "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
          ],
          "operations" : [
            {
              "operation" : "add",
              "field" : "[concat('tags[', parameters('tagName'), ']')]",
              "value" : "[resourceGroup().tags[parameters('tagName')]]"
            }
          ]
        }
      }
    }
  )
  parameters = jsonencode(
    {
      "tagName" : {
        "type" : "String",
        "metadata" : {
          "displayName" : "Mandatory Tag ${var.mandatory_tag_keys[count.index]}",
          "description" : "Name of the tag, such as '${var.mandatory_tag_keys[count.index]}'"
        },
        "defaultValue" : "${var.mandatory_tag_keys[count.index]}"
      }
    }
  )
}

resource "azurerm_policy_definition" "inheritTagFromRGOverwriteExisting" {
  count = length(var.mandatory_tag_keys)

  name         = "inheritTagFromRG_${var.mandatory_tag_keys[count.index]}_OverwriteExisting"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Inherit tag ${var.mandatory_tag_keys[count.index]} from the resource group & overwrite existing"
  description  = "Overwrites the specified mandatory tag ${var.mandatory_tag_keys[count.index]} and existing value using the RG's tag value. Applicable when any Resource containing the mandatory tag ${var.mandatory_tag_keys[count.index]} is created or updated. Ignores scenarios where tag values are the same for both Resource and RG, or when the RG's tag value is one of the parameters('tagValuesToIgnore'). Existing resources can be remediated by triggering a remediation task."

  metadata = jsonencode(
    {
      "category" : "${var.policy_definition_category}",
      "version" : "1.0.0"
    }
  )
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "[concat('tags[', parameters('tagName'), ']')]",
            "exists" : "true"
          },
          {
            "value" : "[resourceGroup().tags[parameters('tagName')]]",
            "notEquals" : ""
          },
          {
            "field" : "[concat('tags[', parameters('tagName'), ']')]",
            "notEquals" : "[resourceGroup().tags[parameters('tagName')]]"
          },
          {
            "value" : "[resourceGroup().tags[parameters('tagName')]]",
            "notIn" : "[parameters('tagValuesToIgnore')]"
          }
        ]
      },
      "then" : {
        "effect" : "modify",
        "details" : {
          "roleDefinitionIds" : [
            "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
          ],
          "operations" : [
            {
              "operation" : "addOrReplace",
              "field" : "[concat('tags[', parameters('tagName'), ']')]",
              "value" : "[resourceGroup().tags[parameters('tagName')]]"
            }
          ]
        }
      }
    }
  )
  parameters = jsonencode(
    {
      "tagName" : {
        "type" : "String",
        "metadata" : {
          "displayName" : "Mandatory Tag ${var.mandatory_tag_keys[count.index]}",
          "description" : "Name of the tag, such as '${var.mandatory_tag_keys[count.index]}'"
        },
        "defaultValue" : "${var.mandatory_tag_keys[count.index]}"
      },
      "tagValuesToIgnore" : {
        "type" : "Array",
        "metadata" : {
          "displayName" : "Tag values to ignore for inheritance",
          "description" : "A list of tag values to ignore when evaluating tag inheritance from the RG"
        },
        "defaultValue" : [
        ]
      }
    }
  )
}

resource "azurerm_policy_definition" "bulkInheritTagsFromRG" {
  name         = "bulkInheritTagsFromRG"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Bulk inherit tags from the resource group"
  description  = "Bulk adds the specified mandatory tags with its value from the parent resource group when any resource missing this tag is created or updated. Existing resources can be remediated by triggering a remediation task. If the tag exists with a different value it will not be changed."

  metadata = jsonencode(
    {
      "category" : "${var.policy_definition_category}",
      "version" : "1.0.0"
    }
  )
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "[concat('tags[', parameters('tagName1'), ']')]",
            "exists" : "false"
          }
        ]
      },
      "then" : {
        "effect" : "modify",
        "details" : {
          "roleDefinitionIds" : [
            "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
          ],
          "operations" : [
            {
              "operation" : "add",
              "field" : "[concat('tags[', parameters('tagName1'), ']')]",
              "value" : "[resourceGroup().tags[parameters('tagName1')]]"
            }
          ]
        }
      }
    }
  )
  parameters = jsonencode(
    {
      "tagName1" : {
        "type" : "String",
        "metadata" : {
          "displayName" : "Mandatory Tag ${var.mandatory_tag_keys[0]}",
          "description" : "Name of the tag, such as '${var.mandatory_tag_keys[0]}'"
        },
        "defaultValue" : "${var.mandatory_tag_keys[0]}"
      }
    }
  )
}

resource "azurerm_policy_definition" "addCreatedOnTag" {
  name         = "addCreatedOnDate"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Add a CreatedOn tag"
  description  = "Adds the mandatory CreatedOn tag when any resource group missing this tag is created or updated. \nExisting resource groups can be remediated by triggering a remediation task.\nIf the tag exists with a different value it will not be changed."

  metadata = jsonencode(
    {
      "category" : "${var.policy_definition_category}",
      "version" : "1.0.0"
    }
  )
  policy_rule = jsonencode(
    {
      "if" : {
        "allOf" : [
          {
            "field" : "tags['CreatedOn']",
            "exists" : "false"
          }
        ]
      },
      "then" : {
        "effect" : "append",
        "details" : [
          {
            "field" : "tags['CreatedOn']",
            "value" : "[utcNow()]"
          }
        ]
      }
    }
  )
}
