+++
date = "2013-08-04T13:20:01.0000000-07:00"
title = "Replacing Mocks with Events in Your Tests"
author = "João P. Bragança"
tags = ["DDD","Navision"]
+++

Sometimes our model can't be as pure as the driven snow. Sometimes we have to use a really crappy external model because replacing it outright would be too expensive. Typically we deal with this in our tests with some kind of mocking framework.

Example,we have a use case for 'creating' an item in the ERP system. Of course in real life nothing ever gets 'created.' Instead our inventory items are 'created' upstream in the product development context. Once the product has reached a certain point of development, they are released to manufacturing. They must go into the ERP system which is where purchase orders originate.

```csharp
var mockItems = new Mock<Items_Port>();
mockItems.Setup(client => client.Create(It.IsAny<Item>()).Returns(new Item_Result());

// do your thing

mockItems.Verify(client => client.Create(It.IsAny<Item>(), Times.Once());
```

Oops, there's already a problem here! This works fine if this interface has a method with a few parameters on it. What happens when the parameter list is 50? Or if there's 1 parameter, a DTO with 50 properties? Navision's default web services for something like Item has a _ton_ of properties on them (of course the enterprise only actually uses 10 of these properties, making you wonder why the rest of them are there). At 10 properties, if you want to verify that certain properties were set, you're gonna have a bad time.

When you order something from a factory, you don't order 3 pieces. You have to order by the case. Which means you need to have your unit of measure matrix setup. But you can't do that until the item record is 'created.' So guess what? Now you have to make 3 calls here! One to create the item (and get its id back), another to setup the UoM with the id, then a third call to update the item record with the default units of measure. This is quickly becoming a pain in the ass.

If you're already leveraging an Event Driven Architecture there's an easy solution: make a fake that publishes events on your `IBus` when you make those method calls.

```csharp
internal class FakeItemsPort : Item_Port
{
    private readonly IBus bus;
    private readonly Func<Create, Create_Result> create;
    private readonly Func<Delete, Delete_Result> delete;

    public FakeItemsPort(IBus bus, Func<Create, Create_Result> create = null, Func<Delete, Delete_Result> delete = null)
    {
        this.bus = bus;
        this.create = create ?? (_ => new Create_Result(_.Item));
        this.delete = delete ?? (_ => new Delete_Result());
    }

    private static IEnumerable<Event> ItemCreated(CreateItem request)
    {
        yield return new TestEvents.ItemCreated(request.Item);
    }
    
    public Create_Result Create(Create request) 
    {
        var result = create(request);
        
        ItemCreated(request).ForEach(bus.Publish);
        
        return result;
    }
    
    // etc
}

public static class TestEvents
{
    public Event ItemCreated(Item item) 
    {
        return new 
    }
    
    class ItemCreated: Event : IEquatable<Event> // after you choose the fields you want to test were set just let resharper generate this for you
    {
        public ItemCreated(Item item) 
        {
            this.description = item.Description;
            this.itemId = item.ItemId;
            // etc
        }
        
        public ItemCreated(Guid itemId, string description)  // just the fields we care about
        {
            this.description = description;
            this.itemId = itemId;
            // etc
        }
    }
}

[TestFixture]
public class SomeTest
{
    IList<Event> events = new List<Event>();
    EnterpriseResourcePlanning navision;
    [SetUp]
    public void SetUp() 
    {
        var bus = new Bus();
        
        bus.Register<Event>(events.Add);
        
        navision = new Navision(bus, new FakeItemsPort(), ...);
    }
}
```

Couple of things I want to note here. I'm passing in a delegate to the constructor because I want to test what happens when it throws an exception. I'm also not bothering implementing any of the methods e.g. CreateMultiple I won't ever call.

Then all you need to assert in your tests is that `events.SequenceEqual(TestEvents.ItemCreate(someGuid, "My Description"), ...)` and you are done. Is this more code than setting up a mock? Sure, but for the first test. You will reap the rewards after the second or third test and certainly when you put in all your edge cases.