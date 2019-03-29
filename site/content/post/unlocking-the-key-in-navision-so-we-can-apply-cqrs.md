+++
date = "2013-06-23T14:46:11.0000000-07:00"
title = "Unlocking the Key in Navision So We Can Apply CQRS"
author = "João P. Bragança"
tags = ["CQRS","Navision"]
+++

## The Soap Box Part

We've heard this before, but it bears repeating: CQRS is not just for greenfield event-sourced ddd systems. It can apply to crappy brownfield systems too. It may even have _more_ relevance there.

Let's take the penultimate brownfield system, an ERP system. In particular, Navision. Navision has a _fantastic_ interface for interacting with it (snipped for brevity):

```csharp
public interface SalesPrice_Port
{
	Read_Result Read(Read request);
	ReadMultiple_Result ReadMultiple(ReadMultiple request);
	Create_Result Create(Create request);
	Update_Result Update(Update request);
	Delete_Result Delete(Delete request);
}
```

In other words, a 100% behavior free SQL-like interface that isn't sql because you have `Create` / `Read` instead of `INSERT` / `SELECT`. Yup. In addition to the obvious computing cost of serialization/deserialization, http, etc, there's a hidden mental cost as well:

```csharp
var result = salesPricePort.ReadMultiple(new ReadMultiple
{
	filter = new[]
	{
		new SalesPrice_Filter
		{
			Field = SalesPrice_Fields.Sales_Type, Criteria = "Customer"
		},
		new SalesPrice_Filter
		{
			Field = SalesPrice_Fields.Sales_Code, Criteria = customerNumber
		},
		new SalesPrice_Filter
		{
			Field = SalesPrice_Fields.Item_No, Criteria = itemNumber
		},
		new SalesPrice_Filter
		{
			Field = SalesPrice_Fields.Variant_Code, Criteria = variant
		},
		new SalesPrice_Filter
		{
			Field = SalesPrice_Fields.Ending_Date, Criteria = null
		},
		new SalesPrice_Filter
		{
			Field = SalesPrice_Fields.Unit_of_Measure_Code, Criteria = Constants.UnitsOfMeasure.Pieces
		}
	}
});
```

Here's where CQRS fits into this. While suboptimal, the web service interface is good enough for creating / changing records. Most of the time we will either be a) hiding navision behind a much better UI that only exposes the fields that matter to the business or b) changing records based on an event coming in from another system, e.g. `PricingAttemptAccepted`.

The webservice interface is _terrible_ for reading records. Good luck if you want to aggregate information. SQL is a much better fit for querying here. It also looks nicer too. Here's the same query in Simple.Data:

```csharp
var navision = NavisionDatabase.OpenNamedConnection("navision");

var prices = navision.SalesPrices;

var result = prices.All.Where(prices.SalesType == "Customer" 
	&& prices.SalesCode == customerNumber 
	&& prices.ItemNumber == itemNumber 
	&& prices.VariantCode == variant
	&& prices.EndingDate == null
	&& prices.UnitOfMeasureCode == Constants.UnitsOfMeasure.Pieces);
```

This works just fine most of the time. Until you need to read before updating. Navision web services have this concept of a `Key` - you send the `Key` you get with a Read request with any subsequent Update or Delete requests, presumably as a form of concurreny control. Which is dumb because you already _have_  most of the `Key` information. All you need is the timestamp.

## The Fixing it Part

From what I can tell so far, the `Key` is based on what would be the primary key in the table, the timestamp, and some voodoo. Let's take a relatively simple record type, `Item`. `Item` has only it's number as the PK, a `code[20]`. Other record types, such as `SalePrice`, have far more columns.

```json
{
	"No_": "ATAT1001",
	"timestamp": "0x000000002F5736A6"
}
```
	
Invoking the Navision web service gives the `Key` as `20;GwAAAACJ/0FUQVQxMDAx9;7942447740;`. It seems to be

```
{Length of Base 64 Part};{Base 64 Encoded Stuff}9;{Timestamp}0;
```	

AFAICT the 9; and 0; are just formatting garbage. Now, let's decode the string:

```
{
	Decoded: [ "1b", "0", "0", "0", "0", "89", "ff", "41", "54", "41", "54", "31", "30", "30", "31" ]
}
```

Ok, now I'm making progress! `1b` is `27` in decimal. I know that the `Item` table is program 27. So the first 5 bytes seem to be the table number, little-endian. Also, `41-54-41-54-31-30-30-31` is just `ATAT1001`. Awesome! That just leaves `89-ff`, I can't figure that out yet. I'll leave that for another post.