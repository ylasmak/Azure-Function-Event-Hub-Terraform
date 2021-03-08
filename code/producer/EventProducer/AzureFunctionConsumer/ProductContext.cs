using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Authentication;
using System.Threading.Tasks;
using AzureFunctionConsumer;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace Catalog.API.Infrastructure
{
    public class ProducContext
    {
        private readonly IMongoDatabase _database = null;

        public ProducContext(string connectionString,string database )
        {
            MongoClient client;

            MongoClientSettings mongoSettings = MongoClientSettings.FromUrl(
                new MongoUrl(connectionString)
            );
            mongoSettings.SslSettings =
                new SslSettings() { EnabledSslProtocols = SslProtocols.Tls12 };
            client = new MongoClient(mongoSettings);
            

            if (client != null)
            {
                _database = client.GetDatabase(database);
            }

        }

        public IMongoCollection<Product> ProductItemData
        {
            get
            {
                return _database.GetCollection<Product>("product-collection");
            }
        }


    }
}
