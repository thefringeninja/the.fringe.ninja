+++
date = "2013-06-11T10:00:00.0000000-07:00"
title = "Automatic Exception Reporting with YouTrack and Nancy pt. 2: Bouncing Off the Green Monster"
author = "João P. Bragança"
tags = ["Nancyfx","Youtrack","Project Management"]
+++

In [Part 1](/193/automatic-exception-reporting-with-you-track-and-nancy-pt-1-the-skeleton) of this series we looked at putting [NancyFX](http://nancyfx.org) as a simple http wrapper in front of [YouTrack](http://jetbrains.com/youtrack). Now we're going to make it more RESTful - i.e. we will display the error page to the user agent and *include the exception report form* on that page.

We will do this by leveraging Nancy's status code handling features. This will allow us to intercept any status code we want and modify the response. Let's start with the view to collect the bug report:

```html
@inherits NancyRazorViewBase<Nancy.Extras.ExceptionReporting.ViewModels.ReportExceptionViewModel>
<!DOCTYPE html>
<html>
<!-- Views/50x.cshtml -->
<head>
    <title>@((int)RenderContext.Context.Response.StatusCode) @RenderContext.Context.Response.StatusCode</title>
</head>
<body>
    <h1>@((int)RenderContext.Context.Response.StatusCode) @RenderContext.Context.Response.StatusCode</h1>
    <p>A server error occurred.</p>
    <section>
        <h2>Submit Bug Report</h2>
        <p>You may submit a bug report. While you don't have to, it would be super helpful if you did.</p>
        <form action="~/issues/report-exception" method="POST">
            <label>Notes:</label>
            <textarea title="Please include as much detail as you can." name="Notes"></textarea>
            <details>
                <summary>Additional information will be submitted with your request:</summary>
                <ul>
                    <li>Exception Type:
                        <pre>@Model.ExceptionType</pre>
                    </li>
                    <li>Exception Detail:
                        <pre>@Model.ExceptionDetail</pre>
                    </li>
                    <li>User Id:
                        <pre>@Model.UserId</pre>
                    </li>
                    <li>Location:
                        <pre>@Model.Location</pre>
                    </li>
                    <li>Request Entity:
                        <pre>@Model.RequestEntity</pre>
                    </li>
                </ul>
            </details>

            <input type="hidden" name="ExceptionType" value="@Model.ExceptionType" />
            <input type="hidden" name="ExceptionDetail" value="@Model.ExceptionDetail" />
            <input type="hidden" name="UserId" value="@Model.UserId" />
            <input type="hidden" name="Location" value="@Model.Location" />
            <input type="hidden" name="RequestEntity" value="@Model.RequestEntity" />
            <input type="hidden" name="ProjectId" value="AWE" />
            <input type="submit" value="Submit Bug Report"/>
        </form>
    </section>
</body>
</html>
```

Make sure you have your web.config set up properly for Razor. Basically you need to specify both `Nancy.ViewEngines.Razor.RazorConfigurationSection, Nancy.ViewEngines.Razor` and `System.Web.WebPages.Razor.Configuration.RazorPagesSection, System.Web.WebPages.Razor, Version=2.0.0.0, Culture=neutral, PublicKeyToken=31BF3856AD364E35`. Otherwise Nancy's razor engine will blow up as it does not reference the System assembly directly.

Then we need an `IStatusCodeHandler` implementation:

```csharp
public class YouTrackStatusCodeHandler : IStatusCodeHandler
{
    private readonly IViewFactory viewFactory;

    public YouTrackStatusCodeHandler(IViewFactory viewFactory)
    {
        this.viewFactory = viewFactory;
    }

    #region IStatusCodeHandler Members

    public bool HandlesStatusCode(HttpStatusCode statusCode, NancyContext context)
    {
        return (int) statusCode >= 500;
    }

    public void Handle(HttpStatusCode statusCode, NancyContext context)
    {
        var viewModel = GetViewModel(context);

        var originalStatusCode = context.Response.StatusCode;

        context.Response = viewFactory.RenderView("50x", viewModel, new ViewLocationContext
        {
            Context = context
        }).WithStatusCode(originalStatusCode);
    }

    private static string GetRequestEntity(Request request)
    {
        var requestEntityBuilder = new StringBuilder()
            .Append(request.Method).Append(' ').Append(request.Url).AppendLine();
        
        var headers = from header in request.Headers
                         let value = String.Join(", ", header.Value)
                         select new {key = header.Key, value};
        
        headers.Aggregate(requestEntityBuilder,
                             (builder, header) => builder.Append(header.key).Append(": ")
                                                         .Append(header.value)
                                                         .AppendLine());

        return requestEntityBuilder.ToString();
    }

    private static ReportExceptionViewModel GetViewModel(NancyContext context)
    {
        var viewModel = new ReportExceptionViewModel
        {
            Location = context.Request.Url,
            RequestEntity = GetRequestEntity(context.Request),
            UserId = context.CurrentUser == null ? "(anonymous)" : context.CurrentUser.UserName
        };

        var exception = context.Items[NancyEngine.ERROR_EXCEPTION] as Exception;

        if (exception == null) // means we just returned a server error out of our module
        {
            viewModel.ExceptionType = context.Response.StatusCode.ToString();
            return viewModel;
        }

        if (exception is RequestExecutionException && exception.InnerException != null)
        {
            exception = exception.InnerException;
        }

        viewModel.ExceptionDetail = exception.ToString();
        viewModel.ExceptionType = exception.GetType().FullName;

        return viewModel;
    }

    #endregion
}
```

We're only going to respond to [5xx status codes](https://twitter.com/DanaDanger/status/183316183494311936). You should return a 4xx code if you think the client messed up the request, e.g. [bookmarking a link they shouldn't have](http://tools.ietf.org/html/draft-ietf-httpbis-p2-semantics-22#section-6.5.4).

You'll also notice we aren't doing any content negotiation here. Wiring this to an `application/json` based api is outside the scope of this blog post. If you want to see how this could be done, [Paul Stovell](http://paulstovell.com/) has a good blog post [showing how to do content negotiation inside a IStatusCodeHandler](http://paulstovell.com/blog/consistent-error-handling-with-nancy).

The last thing we need to do is patch our `IssuesModule` to do more than return a status code:

```csharp
-			issues.CreateIssue(issue);
+			var issueId = issues.CreateIssue(issue);

-			return 200;
+			return Negotiate.WithModel(new ExceptionReportedViewModel(issueId, Context));
```	

This way we can leverage Nancy's excellent view selection feature.

If you're like me (and lucky enough to use Nancy), you probably have multiple Nancy based apps scattered all over the enterprise. And as much as I am a fan of copy and paste, I certainly wouldn't want to copypasta this all over the place. For the final post in this series, I'm going to show how you can make this composable.