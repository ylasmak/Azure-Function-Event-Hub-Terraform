

resource "azurerm_cosmosdb_account" "cosmos-db-account" {
  name                = "tfex-cosmos-db-17381"
  location            = azurerm_resource_group.data-integration-rg.location
  resource_group_name = azurerm_resource_group.data-integration-rg.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 301
    max_staleness_prefix    = 100001
  }

  geo_location {
    location          = var.failover_location
    failover_priority = 1
  }

  geo_location {
    location          = azurerm_resource_group.data-integration-rg.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "mongo-db" {
  name                = "product-db"
  resource_group_name = azurerm_cosmosdb_account.cosmos-db-account.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos-db-account.name
}

resource "azurerm_cosmosdb_mongo_collection" "collection" {
  name                = "product-collection"
  resource_group_name = azurerm_cosmosdb_account.cosmos-db-account.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos-db-account.name
  database_name       = azurerm_cosmosdb_mongo_database.mongo-db.name

  default_ttl_seconds = "777"
  shard_key           = "uniqueKey"
  throughput          = 400
}

output "cosmosdb_connectionstrings" {
   value = azurerm_cosmosdb_account.cosmos-db-account.connection_strings
}



