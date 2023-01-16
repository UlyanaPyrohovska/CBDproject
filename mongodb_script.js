
    
    //works perfectly
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
      $unwind : "$Product"
    },
    {
      $match : {"Customer":"Tatjana Utjesenovic"}
    },
    {
        $group: { _id: "$Product.Name",
            TotalQuantity :
            {
                $sum: "$Quantity"
            }
        }
    }
    ])