+++
date = "2013-06-06T11:25:56.0000000+02:00"
title = "Automatic Exception Reporting with YouTrack and Nancy pt. 1: The Skeleton"
author = "João P. Bragança"
tags = ["NancyFx","Youtrack","Project Management"]
+++

Getting the business users to try and recreate a bug is difficult to say the least. They may not remember what it is they did to reproduce. But you can bet that if you don't fix it by yesterday you're gonna get an earful. In fact we just did. This is me doing something about it :)

Turns out this is annoyingly easy with [Nancy](http://www.nancyfx.org) and the [YouTrackSharp library](http://nuget.org/packages/YouTrackSharp), so easy that I'm not going to bother test driving this. Frankly writing this post took longer than the actual code. First, the `Bootstrapper`:

```csharp
public class Bootstrapper : DefaultNancyBootstrapper
{
    protected override void ConfigureApplicationContainer(TinyIoc.TinyIoCContainer container)
    {
        base.ConfigureApplicationContainer(container);

        var connection = new Connection("localhost", port: 8085);
        connection.Authenticate("application", "abc123");

        container.Register<IConnection>(connection);
    }
}
```
I am unsure if a `Connection` is better served by a PerRequest lifestyle. I believe underneath it uses a cookie, which can expire. So maybe.

Next up is the viewmodel. Note the casting operator:

```csharp
public class ReportExceptionViewModel
{
    public string ExceptionDetail { get; set; }
    public string ExceptionType { get; set; }
    public string UserId { get; set; }
    public string Notes { get; set; }
    public Uri Location { get; set; }
    public string RequestEntity { get; set; }
    public string ProjectId { get; set; }

    public static implicit operator Issue(ReportExceptionViewModel viewModel)
    {
        dynamic issue = new Issue();

        issue.Project = viewModel.ProjectId;
        issue.Summary = viewModel.Location + " - " + viewModel.ExceptionType;
        issue.Description = new StringBuilder()
            .Append(viewModel.ExceptionDetail)
            .AppendLine().AppendLine()
            .AppendLine(viewModel.Notes)
            .AppendLine().AppendLine()
            .AppendLine("Environment:")
            .AppendLine(viewModel.UserId)
            .AppendLine(viewModel.RequestEntity)
            .ToString();

        return issue;
    }
}
```

I'll explain more about the casting operator in a second.

What's up with that `dynamic`? Issues in YouTrack are really really flexible. You can attach an arbitrary set of fields to them. `dynamic` is a perfect fit, then.

Finally we have the `NancyModule`:

```csharp
public class IssuesModule : NancyModule
{
    public IssuesModule(IssueManagement issues)
        : base("/issues")
    {
        Get["/report-exception"] = p =>
        {
            var model = this.Bind<ReportExceptionViewModel>();
            return Negotiate.WithModel(model);
        };

        Post["/report-exception"] = p =>
        {
            var model = this.Bind<ReportExceptionViewModel>();

            Issue issue = model;
            
            issues.CreateIssue(issue);

            return 200;
        };
    }
}
```

At this stage the `GET` isn't stricly necessary - we have no view so there's no `form` to display. I mostly have it in there to make sure that nancy properly binds the `ReportExceptionViewModel`. This is easy with the built in conneg - just append `.json` to the url and you are good to go. Nancy will happily take your query string, merge it with your `POST` if it is `application/x-www-form-urlencoded` and turn that into a flat DTO for you, just like PHP.

<figure>
    ![Testing it out with Advanced Rest Client](http://i.imgur.com/jbxujYU.png)
    <figcaption>Testing it out with Advanced Rest Client</figcaption>
</figure>

You'll also notice there's hardly any code in the `Module`. That's why I moved all that ugly object mapping into a casting operator. It'll keep our `Module` nice and clean.

<figure>
    ![The results](http://i.imgur.com/dyzHgzK.png)
    <figcaption>The results</figcaption>
</figure>

That's more or less it! You can easily wire this up in Silverlight, $.ajax, etc. But IMO this is not suitable for a real web application. As a user I'd want a link to check up on this. As a developer I would like to wire this right into Nancy's status code / error handling mechanism. Next time we'll look at making this a bit more RESTful.
