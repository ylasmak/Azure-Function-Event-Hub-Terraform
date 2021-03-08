

resource "azurerm_storage_account" "sa" {
  name                     = "azurefunctionsa86915"
  resource_group_name      = azurerm_resource_group.data-integration-rg.name
  location                 = azurerm_resource_group.data-integration-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "service-plan" {
  name                = "azure-functions-service-plan"
  location            = azurerm_resource_group.data-integration-rg.location
  resource_group_name = azurerm_resource_group.data-integration-rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "func-app" {
  name                       = "azure-function-data-hub"
  location                   = azurerm_resource_group.data-integration-rg.location
  resource_group_name        = azurerm_resource_group.data-integration-rg.name
  app_service_plan_id        = azurerm_app_service_plan.service-plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  os_type                    = "linux"

   app_settings = {
        FUNCTIONS_WORKER_RUNTIME         = "dotnet"
        AZURE_FUNCTIONS_ENVIRONMENT      ="development"
        FUNCTIONS_EXTENSION_VERSION      = "~3"
        EVENTHUB_PRODUCER_SHARED_KEY     = azurerm_eventhub_authorization_rule.eh-rule-writer.primary_connection_string
    }
}