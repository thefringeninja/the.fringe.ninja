+++
date = "2013-05-23T12:00:00.0000000+02:00"
title = "Why is it so Slow?"
author = "João P. Bragança"
tags = ["REST","HATEOAS","SOAP"]
+++

Recently, a client wanted to know why certain product they had installed was performing so horribly from their overseas office when it worked just fine over here. I [had my suspicions](https://www.google.com/search?q=site:ayende.com+reduce+%22remote+calls%22) but I wanted to confirm it.

So, I had him put in [fiddler](http://fiddler2.com/). If you haven't heard of this tool, _get it now_. It will save you a ton of time when debugging any http issue.

Anyway, my [suspicions](http://ayende.com/blog/151553/expanding-your-horizons) were confirmed:
<figure>
	<img src="http://i.imgur.com/zI46jNt.png" /> <figcaption>This is actually from the IE debugging tools but you get the idea.</figcaption></figure>

Wow! 27 SOAP calls to render a single page. From javascript. Looks like someone forgot to read [The Fallacies of Distributed Computing](http://en.wikipedia.org/wiki/Fallacies_of_Distributed_Computing). As the UI is responsible for making the calls, my recommendation was to fix it there - just slap a new UI on it. I highly doubt more that one or two SOAP calls would be necessary to render a screen to collect some form input.</p>

To understand why this is wrong, we need to understand what SOAP is. It is a RPC protocol that tunnels over HTTP. Because it uses a single URI to handle any number of requests, it is impossible to cache. Inventor of the world wide interwebs Roy Fielding [said as much _back in 2002_](http://lists.w3.org/Archives/Public/www-tag/2002Apr/0181.html):

> The problem with SOAP is that it tries to escape from the Web interface. It deliberately attempts to suck, mostly because it is deliberately trying to supplant CGI-like applications rather than Web-like applications. It is simply a waste of time for folks to say that "HTTP allows this because I've seen it used by this common CGI script." If we thought that sucky CGI scripts were the basis for good Web architectures, then we wouldn't have needed a Gateway Interface to implement them.
> In order for SOAP-ng to succeed as a Web protocol, it needs to start behaving like it is part of the Web. That means, among other things, that it should stop trying to encapsulate all sorts of actions under an object-specific interface. It needs to limit its object-specific behavior to those situations in which object-specific behavior is actually desirable. If it does not do so, then it is not using URI as the basis for resource identification, and therefore it is no more part of the Web than SMTP.

It's really a shame that 10 years later, so many still don't get it. The web scales because you can cache the shit out of it. Stale data is OK in many if not most circumstances. The best remote call is the one that is never made.