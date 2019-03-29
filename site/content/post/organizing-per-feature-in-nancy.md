+++
date = "2013-10-03T09:00:00.0000000-07:00"
title = "Organizing Per Feature in Nancy"
author = "João P. Bragança"
tags = ["nancyfx"]
+++

We've all built applications that look like this:

![Typical project structure](http://i.imgur.com/Wr9zcDZ.png "Typical project structure")

There's a bit of a problem here. What does Exception Reporting have to do with Validation? Or the Home Page? Mostly nothing, other than *these classes perform the same kind of function*.

<blockquote class="twitter-tweet"><p>much, much nicer to have views, view models, validators, command/query handlers all adjacent together</p>&mdash; Jimmy Bogard (@jbogard) <a href="https://twitter.com/jbogard/statuses/385406604243255296">October 2, 2013</a></blockquote>

Wouldn't it be easier to organize everything by feature instead? Views, View Models, scripts, stylesheets, everything?

![Better project structure](http://i.imgur.com/yV539vq.png "Better project structure")

This is a cinch in Nancy. First thing you need to do is specify your own view location conventions:

```csharp
protected override void ConfigureConventions(NancyConventions nancyConventions)
{
    base.ConfigureConventions(nancyConventions);

    nancyConventions.ViewLocationConventions.Clear();
    
    nancyConventions.ViewLocationConventions.Add(
        (viewName, model, viewLocationContext) =>
            "features" + viewLocationContext.ModulePath.Underscore().Pascalize() + "/views/" + viewName);

    nancyConventions.ViewLocationConventions.Add(
        (viewName, model, viewLocationContext) => 
            "features/home/views/" + viewName);

    nancyConventions.ViewLocationConventions.Add(
        (viewName, model, viewLocationContext) =>
            "features/" + viewName);
}
```

This tells Nancy that your views are in a sub folder of your feature (which must have the same name as your module path), and fallback to the 'home' feature if it can't find something. This is so you can define a layout once, and override the layout later if you want.

As for assets, I'm personally a fan of Cassette. Unfortunately I haven't figured out how to put scripts and stylesheets in the same folder as the feature:

```csharp
public class CassetteBundleConfiguration : IConfiguration<BundleCollection>
{
    #region IConfiguration<BundleCollection> Members

    public void Configure(BundleCollection bundles)
    {
        bundles.AddPerSubDirectory<StylesheetBundle>("~/content/features", new FileSearch
        {
            Pattern = "bootstrap.less"
        });
        bundles.AddPerSubDirectory<ScriptBundle>("~/scripts/lib");
        bundles.AddPerSubDirectory<ScriptBundle>("~/scripts/features");
    }

    #endregion
}
```

Then it is just a matter of referencing certain scripts and stylesheets from your view that all resources in this 'feature' share.