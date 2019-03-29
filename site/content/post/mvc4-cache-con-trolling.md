+++
date = "2013-05-28T15:19:37.0000000+02:00"
title = "MVC4 Cache Con-trolling"
author = "João P. Bragança"
tags = ["MVC4"]
+++

All I want to do is cache something for one day. MVC4 is seriously trolling me today:

```csharp
public override void ExecuteResult(ControllerContext context)
{
    context.HttpContext.Response.OutputStream.Write(contents, 0, contents.Length);
    context.HttpContext.Response.ContentType = contentType;
    context.HttpContext.Response.Headers.Set("Cache-Control", "public, max-age=86400");
    context.HttpContext.Response.Headers.Set("Expires", DateTime.UtcNow.AddDays(1).ToString("r"));
}
```

And the response?

```
Cache-Control:private
Content-Length:30262
Content-Type:image
Date:Tue, 28 May 2013 22:18:07 GMT
Expires:Wed, 29 May 2013 22:18:07 GMT
```

ARRRRRGH. I don't know why people who develop on the microsoft default stack put up with crap like this.