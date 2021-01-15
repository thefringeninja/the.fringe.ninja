+++
date = "2013-07-10T21:42:12.0000000-07:00"
title = "CQRS - erm OOP and Validations"
author = "João P. Bragança"
tags = ["CQRS","OOP"]
+++

A discussion came up recently on the DDD/CQRS forums recently, that got sidetracked into 'where do the validations go' (along with a lot of weird nonsense about async command queues, http status code pedantry, etc, but we'll leave that for some other time). A large minority of developers - perhaps even a majority - seem to think that validations belong somewhere in the 'trusted' client.

I find this conclusion strange, as none of the .net framework code we work with on a daily basis actually works this way.

<blockquote class="twitter-tweet"><p>digging in tons of framework code. For all the crap people talk about <a href="https://twitter.com/Microsoft">@microsoft</a> a lot of the code is high quality and there is a ton of it.</p>&mdash; gregyoung (@gregyoung) <a href="https://twitter.com/gregyoung/statuses/352579523822354433">July 4, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Let's take a look at a [class](https://github.com/mono/mono/blob/master/mcs/class/corlib/System.Collections.Generic/Dictionary.cs#L407) we use every day, `System.Collections.Generic.Dictionary[of TKey, TValue]` (I know this is mono, but github supports linking to a line of code so whatever):

```csharp
public void Add (TKey key, TValue value)
{
    if (key == null)
        throw new ArgumentNullException ("key");

    // get first item of linked list corresponding to given key
    int hashCode = hcp.GetHashCode (key) | HASH_FLAG;
    int index = (hashCode & int.MaxValue) % table.Length;
    int cur = table [index] - 1;

    // walk linked list until end is reached (throw an exception if a
    // existing slot is found having an equivalent key)
    while (cur != NO_SLOT) {
        // The ordering is important for compatibility with MS and strange
        // Object.Equals () implementations
        if (linkSlots [cur].HashCode == hashCode && hcp.Equals (keySlots [cur], key))
            throw new ArgumentException ("An element with the same key already exists in the dictionary.");
        cur = linkSlots [cur].Next;
    }
}
```

Does this code rely on a trusted client? Of course not! It blows up in your face if you try to add a null key or a duplicate key.

This is not to say that a trusted client isn't a nice thing to have. But at the end of the day your objects can only trust one thing: themselves. QED.
