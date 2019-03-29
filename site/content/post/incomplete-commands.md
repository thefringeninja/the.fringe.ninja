+++
date = "2014-04-03T15:27:21.0000000-05:00"
title = "Incomplete Commands"
author = "João P. Bragança"
tags = ["ddd","cqrs"]
+++

Recently a question came up in the [CQRS chatroom](https://jabbr.net/#/rooms/DDD-CQRS-ES) on Jabbr: 

> Here's the situation. New command comes in, They can sometimes be missing some info (for daft reasons), if it is missing info then I need to call off to an external api to get the info back. This external api is unreliable so it would be better to supply the information upfront if possible.

There are a couple of ways to do this.

1) Enrich the command before it goes to the domain.

```csharp
Post["/list-stuff"] = _ => {
     var listStuff = this.BindAndValidate<ListStuff>();
     
     if (false == listStuff.GrossWeight.HasValue) {
    listStuff.GrossWeight = getUnitWeight(listStuff.PartNumber);
     }
     
     bus.Send(listStuff);
}
```

2) Do it from inside the aggregate.

```csharp
public Listing(string partNumber, Money unitPrice, Mass grossWeight, GetUnitWeight getUnitWeight) {
     Guard.Against(partNumber == null);
     Guard.Against(unitPrice == null || unitPrice <= 0m);

     grossWeight = grossWeight ?? getUnitWeight(partNumber);

     Guard.Against(grossWeight <= 0m);
     
     ApplyChange(new StuffListed(...));
}
```

1) and 2) are basically the same thing - you add additional state before any state change occurs. However, there's a big disadvantage when time is of the essence. What happens when the 3rd party service is down?

If your typical user gets a couple of these a day, this is not really a big deal. His work queue is manageable. What if he needs to do one of these every five minutes?

3) Make it explicit!

```csharp
public Listing(string partNumber, Money unitPrice, Mass grossWeight) {
     Guard.Against(partNumber == null);
     Guard.Against(unitPrice == null || unitPrice <= 0m);
     Guard.Against(grossWeight == null || grossWeight <= 0m);

     ApplyChange(new StuffListed(...));
     
     if (grossWeight.Equals(Mass.Empty)) {
    ApplyChange(new ListingWeightRequired(...));
     }
     else {
    ApplyChange(new ListingApproved(...));
     }
}

public void SpecifyGrossWeight(Mass grossWeight) {
     ApplyChange(new GrossWeightSpecified(...));
     ApplyChange(new ListingApproved(...));
}

public void Handle(ListingWeightRequired e) {
     bus.Send(new ListStuff(e.ListingId, getUnitWeight(e.PartNumber)));
}
```

This has its drawbacks too. You now have a queue to manage; there's somewhat more code to maintain.

As usual, the answer is it *depends* :) If there is a low volume of work here, you can just present the user with a list of things that need to get done. If there is an error on an item he can come back to it later. If your users are going to get inundated with work items, or there is some other kind of time constraint, I would go with 3).