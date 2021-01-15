+++
date = "2013-08-15T10:51:38.0000000-07:00"
title = "Getting RavenDB Profiling Working on Nancy"
author = "João P. Bragança"
tags = ["NancyFx","RavenDB"]
+++

This is my second attempt. :)

About a year ago I made an attempt to wire [Nancy](http://nancyfx.org/) together with [RavenDB](http://ravendb.net/) and [failed miserably](https://github.com/thefringeninja/randy). Needed a break from businessy coding last night so I decided to work on something fun instead.

The ability to see what's going on in your application is so important when it comes to performance tuning. Yes, there's that old adage about [premature optimization](http://c2.com/cgi/wiki?PrematureOptimization). IMO this phrase is taken out of context. To me 97% of the time means 97% of the code in your face, which is doing stuff in memory. The other 3% of your code is doing I/O of some sort. Minimizing the use of I/O will provide the biggest performance gains for most applications.

In fact having the profiler on here has helped me find an unnecessary remote call on this blog, about a third of the total time spent on RavenDB.

To implement this guy, I had two major hurdles to climb: 1) The original [RavenDB MVC Integration](https://github.com/ravendb/ravendb/tree/master/Raven.Client.MvcIntegration) relies on Action Filters and HttpContext.Current, which is the enemy of Nancy's portability. 2) It sends json over the wire and generates html with templates, which I personally loathe. The gist for my solution is [here](https://gist.github.com/thefringeninja/6242976).

To deal with 1) you need to use a bit of event hackery - register new events when the pipeline starts, then unregister them when the pipeline is complete. Warning! I am probably creating a memory leak with this code as I have no idea what I am doing.

```csharp
// call this from your bootstrapper
public static void InitializeFor(DocumentStore documentStore, IPipelines pipelines)
{
    documentStore.Conventions.DisableProfiling = false;
    documentStore.InitializeProfiling();

    pipelines.BeforeRequest.AddItemToStartOfPipeline(
        context =>
        {
            if (documentStore.WasDisposed)
                return null;

            Action<InMemoryDocumentSessionOperations> onSessionCreated =
                operation => SessionCreated(operation, context);

            Action<ProfilingInformation> onInformationCreated =
                information => InformationCreated(information, context);

            if (false == Operations.TryAdd(context, Tuple.Create(onSessionCreated, onInformationCreated)))
                return null;

            documentStore.SessionCreatedInternal += onSessionCreated;

            return null;
        });

    pipelines.AfterRequest.AddItemToEndOfPipeline(
        context =>
        {
            if (documentStore.WasDisposed)
                return;

            //do something here to get the session ids into the rendered view.
            //I use cassette so I will add an inline script with a hook.
            
            Tuple<Action<InMemoryDocumentSessionOperations>, Action<ProfilingInformation>> operation;

            if (false == Operations.TryGetValue(context, out operation))
                return;

            documentStore.SessionCreatedInternal -= operation.Item1;
            ProfilingInformation.OnContextCreated -= operation.Item2;
        });
}
```

To deal with 2) I just leverage Nancy's view + view model conventions. The view model is greatly simplified. I am providing a lot less information than Ayende's profiler (which does not seem to be loading anymore) but I never really used that additional info anyway.

To create the modal, I return an html fragment from the server and insert that into the page. The javascript code for that is running on this blog, I'll let you try to find it :)