using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Catalog.API.Infrastructure;
using Microsoft.Azure.EventHubs;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace AzureFunctionConsumer
{
    public static class Function1
    {
        [FunctionName("DataHubIngestion")]
        public static async Task Run([EventHubTrigger("data_integration_eh-integration", 
                                        Connection = "EVENTHUB_PRODUCER_SHARED_KEY" ,
                                        ConsumerGroup ="data_ingestion_consumer_group"
                                        )] EventData[] events,
                                      ILogger log)
        {
            var exceptions = new List<Exception>();

            var connectionString = Environment.GetEnvironmentVariable("COSMOS_DB_CONNECTION_STRING");
            var database = Environment.GetEnvironmentVariable("MONGO_DB_NAME");

            var context = new ProducContext(connectionString, database);



            foreach (EventData eventData in events)
            {
                try
                {
                    string messageBody = Encoding.UTF8.GetString(eventData.Body.Array,
                                                eventData.Body.Offset, 
                                                eventData.Body.Count);


                    // Replace these two lines with your processing logic.
                    dynamic output = JsonConvert.DeserializeObject<dynamic>(messageBody);

                    var product = new Product(output, Guid.NewGuid().ToString());
                    
                    context.ProductItemData.InsertOne(product);

                    log.LogInformation($"C# Event Hub trigger function processed a message: {messageBody}");
                    await Task.Yield();
                }
                catch (Exception e)
                {
                    // We need to keep processing the rest of the batch - capture this exception and continue.
                    // Also, consider capturing details of the message that failed processing so it can be processed again later.
                    exceptions.Add(e);
                }
            }

            // Once processing of the batch is complete, if any messages in the batch failed processing throw an exception so that there is a record of the failure.

            if (exceptions.Count > 1)
                throw new AggregateException(exceptions);

            if (exceptions.Count == 1)
                throw exceptions.Single();
        }
    }
}
