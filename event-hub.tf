resource "azurerm_resource_group" "data-integration-rg" {
  name     = "data-hub-integration-rg"
  location = "East US"
}

resource "azurerm_eventhub_namespace" "evh-ns" {
  name                = "data-integration-eh-ns"
  location            = azurerm_resource_group.data-integration-rg.location
  resource_group_name = azurerm_resource_group.data-integration-rg.name
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = "Prototype"
  }
}

resource "azurerm_eventhub" "eh" {
  name                = "data_integration_eh-integration"
  namespace_name      = azurerm_eventhub_namespace.evh-ns.name
  resource_group_name = azurerm_resource_group.data-integration-rg.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_consumer_group" "consumer-group-1" {
  name                = "data_ingestion_consumer_group"
  namespace_name      = azurerm_eventhub_namespace.evh-ns.name
  eventhub_name       = azurerm_eventhub.eh.name
  resource_group_name = azurerm_resource_group.data-integration-rg.name
}

resource "azurerm_eventhub_authorization_rule" "eh-rule-writer" {
  name                = "writer"
  namespace_name      = azurerm_eventhub_namespace.evh-ns.name
  eventhub_name       = azurerm_eventhub.eh.name
  resource_group_name = azurerm_resource_group.data-integration-rg.name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_eventhub_authorization_rule" "eh-rule-reader" {
  name                = "reader"
  namespace_name      = azurerm_eventhub_namespace.evh-ns.name
  eventhub_name       = azurerm_eventhub.eh.name
  resource_group_name = azurerm_resource_group.data-integration-rg.name
  listen              = true
  send                = false
  manage              = false
}

output "writer-shared-access-url" {
  value = azurerm_eventhub_authorization_rule.eh-rule-writer.primary_connection_string
}

output "reader-shared-access-url" {
  value = azurerm_eventhub_authorization_rule.eh-rule-reader.primary_connection_string
}