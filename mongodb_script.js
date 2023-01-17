
//List the “sales history” purchased by the customer by Product
db.Sales.aggregate([
    {
        $match: { "Customer": "Tatjana Utjesenovic" }
    },
    {
        $lookup: {
            from: "StockItems",
            localField: "StockItemID",
            foreignField: "StockItemID",
            as: "Product"
        }
    },
    {
        $unwind: "$Product"
    },
    {
        $group: {
            _id: "$Product.Name",
            TotalQuantity:
            {
                $sum: "$Quantity"
            }
        }
    }
])

db.Sales.aggregate([
    {
        $match: { "Customer": "Tatjana Utjesenovic"}
    },
    {
        $lookup: {
            from: "StockItems",
            localField: "StockItemID",
            foreignField: "StockItemID",
            as: "Product"
        }
    },
    {
        $unwind: "$Product"
    }
    {
        $group: {
            _id: "$SaleHeaderID",
            products:{
                $push: {
                    Product: "$Product",
                    Quantity: "$Quantity"
                }
            },
            totalvalue: {$sum: "$TotalIncludingTax"}
        }
    },
    {
        $sort: {"_id" : 1}
    }
    ])


//List the total value per month/year    
db.Sales.aggregate([
    {
        $group: {
            _id: { year: { $substr: ["$InvoiceDate", 0, 4] }, month: { $substr: ["$InvoiceDate", 5, 2] } },
            totalValue: { $sum: "$TotalIncludingTax" }
        }
    },
    {
        $sort: { _id: 1 }
    },
    {
        $group: {
            _id: "$_id.year",
            months: {
                $push: {
                    month: "$_id.month",
                    totalvalue: "$totalValue"
                }
            },
            totalValue: { $sum: "$totalValue" }
        }
    }
    {
        $sort: { _id: 1 }
    }
])

//List monthly average total value by Product
db.Sales.aggregate([
    {
        $lookup: {
            from: "StockItems",
            localField: "StockItemID",
            foreignField: "StockItemID",
            as: "Product"
        }
    },
    {
        $unwind: "$Product"
    },
    {
        $match: {
            "Product.Name": "Superhero action jacket (Blue) 5XL"
        }
    },
    {
        $group: {
            _id: { $substr: ["$InvoiceDate", 0, 7] } ,
            AverageVal: { $avg:  "$TotalIncludingTax" }
        }
    }
   {
       $sort: {_id : 1}
   }
])
//List by Brand, products and quantities purchased.
db.Sales.aggregate([
    {
        $lookup: {
            from: "StockItems",
            localField: "StockItemID",  
            foreignField: "StockItemID",
            as: "Product"
        }
    },
    {
        $unwind: "$Product"
    },
    {
        $match: { "Product.Brand": "N/A" }
    },
    {
        $group: {
            _id: "$Product.Name",
            TotalQuantity:
            {
                $sum: "$Quantity"
            }
        }
    }
])