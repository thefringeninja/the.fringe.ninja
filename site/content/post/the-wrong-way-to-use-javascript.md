+++
date = "2013-12-27T11:06:21.0000000-08:00"
title = "The Wrong Way to Use Javascript"
author = "João P. Bragança"
tags = ["rest","ux","rant"]
+++

I've been taking a bit of a coding vacation. Before I jump back into things, I decided to do a little housekeeping and clean the cobwebs from my interwebs. Specifically, reducing the level of annoying coming out of Facebook.

Look at this nonsense right here:

![](http://i.imgur.com/GgSSJin.png "ಠ\_ಠ Facebook sucks and so does their code. ಠ\_ಠ")

Wow, what a great user experience! Having to un-check 60-odd check-boxes _individually_ is just great. I'm sure the team of 15 out of 1,000 Facebook engineers that built this page thought this was really clever. We're using javascript to enhance the page! Weeeee!

```html
<form rel="async" action="/ajax/settings/notifications/update_app" method="post" onsubmit="return window.Event &amp;&amp; Event.__inlineSubmit &amp;&amp; Event.__inlineSubmit(this,event)" id="u_o_e">
    <input type="hidden" name="fb_dtsg" value="...." autocomplete="off">
    <img class="uiLoadingIndicatorAsync img" src="https://fbstatic-a.akamaihd.net/rsrc.php/v2/yb/r/GsNJNwuI-UM.gif" alt="" width="16" height="11">
    <input type="checkbox" name="checked" checked="1" id="u_o_f">
    <input type="hidden" autocomplete="off" name="id" value="12345">
</form>
```

(26 Javascript resources out of 86 total to render this simple page by the way).

The javascript on this page apparently exists to allow the user to turn application feed notifications on and off individually. Can we apply REST principles and provide the user with a better experience? Yes, we can!

The REST style is a document based style. It tends to favor _coarse-grained_ resources over fine-grained ones, if only for the cache-ability.

```html
GET /user/12345/application-notifications
Accept: text/html
Authorization: ...


200 Ok
Content-Type: text/html
Cache-control: private

<html>
    <body>
        <form action="/user/12345/application-notifications" method="POST" id="application-notifications">
            <!-- each value here represents an application id -->
            <input type="checkbox" name="id" value="12345" checked >
            <input type="checkbox" name="id" value="67890" >
            
            <input type="Submit" value=" Submit " >
        </form>
    </body>
</html>
```

Admittedly, the user experience has not improved over what Facebook is currently providing us. However, there are two improvements. 1) Only one remote call to set all preferences at once. 2) A lot less complicated than putting an ajax form around each checkbox and having to wire that up.

What about the enhancement? We can (and should) use javascript here to enhance the user experience.

```html
<script type="text/javascript">
    (function(document){
        var form = document.getElementById("application-notifications");
        var checkboxes = form.querySelectorAll('input[type="checkbox"]');
        
        var setCheckState = function(value) {
            for (var i=0; i<checkboxes.length; i++) {
                checkboxes[i].checked = value;
            }
        }
        
        // use your imagination on how to wire this up to some buttons.
    })(document);
</script>
```
	
There. We just replaced a whole bunch of overly complicated ajax-y nonsense with 10 lines of javascript. And provided IMO the user with a better experience.