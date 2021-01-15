+++
date = "2013-06-03T00:02:31.0000000+02:00"
title = "Empty Project - Nancy vs MVC4"
author = "João P. Bragança"
tags = ["NancyFx"]
+++

I just installed the [Nancy Templates for Visual Studio](http://visualstudiogallery.msdn.microsoft.com/f1e29f61-4dff-4b1e-a14b-6bd0d307611a) for Visual Studio. Before this, creating a project for Nancy has always been a bit of a pain - adding a mvc project and then removing a whole bunch of crap you don't need. Way too much fiddlery required.

What really got me was the minimalistic set of dependencies:
<figure>![Nancy FTW](http://i.imgur.com/TNOuEgd.png)<figcaption>Nine is a good number.</figcaption></figure>

Compare that to an <q>empty</q> MVC4 project:<figure>![Imgur](http://i.imgur.com/2BOoWmQ.png)<figcaption>Seventeen is very inauspicious.</figcaption></figure>

A Nancy.Hosting.SelfHost project would have even less dependencies. I think this is the key to true RAD - less cruft to get in your way.
