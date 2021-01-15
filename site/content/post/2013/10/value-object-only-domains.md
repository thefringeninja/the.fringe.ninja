+++
date = "2013-10-09T23:12:28.0000000-07:00"
title = "Value Object Only Domains"
author = "João P. Bragança"
tags = ["random","ddd"]
+++

Word on the street is value objects have been getting the short stick in **DDD** ORMS. That's too bad. Value objects should be first class citizens because like aggregates their role is to enforce invariants. e.g.

```csharp
DateTime.Parse("NOPE") // <-- nope
DateTime.TryParse("NOPE", out date) // <-- still nope
```

What about something like an address? Is a part of your core domain 'validate this address?' Or can you delegate to a generic domain, and implement with [SmartyStreets](http://smartystreets.com) or [Melissa Data](http://www.melissadata.com/)? These are economic decisions. I imagine you can present their price calculator and your own estimate to the man and see what she says.

I prefer the second option. Store your value object as a string and validate when you convert one to the other.

If the data storage mechanism is behind some poorly designed web servicey nonsense but still is pretty good at maintaining consistency, why model an aggregate on top? Systems like these force users to remember a sequence of manual steps, (sadly sometimes without validation) to 'make shit work.' Do the validation yourself with a value object and pass it along to the other model.
