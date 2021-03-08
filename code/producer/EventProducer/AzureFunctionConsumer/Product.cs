using System;
using System.Collections.Generic;
using System.Text;

namespace AzureFunctionConsumer
{
    public class Product
    {
       public dynamic productObject { get; set; }
       public string uniqueKey { get; set; }

        public Product(dynamic productObject, string uniqueKey)
        {
            this.productObject = productObject;
            this.uniqueKey = uniqueKey;
        }
    }
}
