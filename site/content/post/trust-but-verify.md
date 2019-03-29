+++
date = "2013-08-06T18:15:42.0000000-07:00"
title = "Trust, but Verify"
author = "João P. Bragança"
tags = ["DDD"]
+++

[![](http://i.imgur.com/5YNHmXd.jpg "Trust, but Verify")](http://en.wikipedia.org/wiki/Trust,_but_verify)

Sage advice. I almost made a huge mistake this sprint, but thankfully caught it because I had one last conversation with the domain expert before I deployed anything.

As we're using eventing / event sourcing this would have been bad as events are immutable. You can always fix bugs later but that is just more code to write which can introduce more bugs and... you get the picture.

There's a shared concept in the company, called the `Packout`. It describes the unit of measure conversions of one of our products. For example, we'll have 3 pieces in a carton and 8 cartons in a case. Production needs it to know what quantity to order, and probably to know how many will fit in a cargo container. Sales needs it to tell the customers how much space they need to allocate in their warehouses. It happens to be a good candidate for a value object.

I'd like to make this value object convertible to and from a string to avoid doing weird shit like putting the value object on a message contract. So naturally I assumed the `Packout` string looked like "8/3". I even confirmed it with another developer and one or two people in the company. Boy was I wrong!

The mistake I made was in trusting without verification. The people I had spoken to sometimes speak about how many cartons there are in a case. Unfortunately they were the wrong people. They were basing what they told me on what they saw in the ERP system.

The domain expert used another field, called 'description 2' of all things, to actually store this information. This field is normally hidden by default, so if you don't know where to look, you won't find it. It's a string, so it doesn't get ETL'd anywhere. But when you talk to Sales, other people in Production, &c., they all agreed that 'description 2' actually had the correct commonly understood `Packout` definition.

[![](http://i.imgur.com/PXowj3as.jpg "Sometimes you don't have a whiteboard")](http://i.imgur.com/PXowj3a.jpg)

Really the moral of the story is this: Enough with the computer! Forget it exists! I asked them that if the computers stopped working tomorrow, and they had to put this information on a sheet of paper, what would it look like?