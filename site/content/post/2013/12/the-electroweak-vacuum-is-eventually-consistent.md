+++
date = "2013-12-18T07:24:06.0000000+02:00"
title = "The Electroweak Vacuum is Eventually Consistent"
author = "João P. Bragança"
tags = ["ddd","cqrs","rest"]
+++

The fastest information can ever travel is 3*10^8 m/s - in a vacuum. It's 2/3rds that in a copper wire. In the ideal case.

Imagine two observers in the milky way galaxy, one at Terminus and the other at Star's End. They will observe events from all over the universe at different times - they will not agree on the order of events. What they can agree on is that eventually they will see all of them.

Now, you might say that in real life we don't experience relativistic effects because our scale is too small. While people don't necessarily experience them, *t* is non zero and therefore relevant.

Distance and medium will only indicate the *maximum* speed information can get somewhere. All sorts of things can go wrong. So, I tend to lean towards an architectural style - REST at the top with CQRS for simple / trivial domains and 'CQRS' for more complicated / important ones - to minimize exposure to these sorts of problems. It is a fundamental feature of the universe. Embrace it.
