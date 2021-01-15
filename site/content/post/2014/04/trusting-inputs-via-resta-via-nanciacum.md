+++
date = "2014-04-21T13:52:37.0000000-07:00"
title = "Trusting Inputs, Via RESTa Via Nanciacum"
author = "João P. Bragança"
tags = ["nancyfx","rest","hateoas"]
+++

All too often, security is treated as an afterthought in our models. I'm as guilty of this as anyone. :) Now that HTTP is becoming the most popular protocol inside the enterprise, sending bad data across the wire becomes much easier. A hidden input field is not all that hidden.

Let's take everyone's second favorite fake business problem: Enrolling Students in Classes. Let's take it further and say we want to develop this as a SaaS product. It'll need to be a multi tenant application. There are lots of independent community colleges (`Institutions`) out there and we don't want to run a VM or process per `Institution`.

Obviously, we will need to prevent cross contamination between tenants. Imagine the horror if a student changed the `institution-id` on his HTML form and we blindly let it through. 

Sure, we could load the `Institution` from persistent storage and ensure the `Enrollee` is actually enrolled there and that the `Class` is offered. But you can imagine how large that collection would be. We can get better performance if we sign these requests.

Let's fix this problem by applying the principles of REST.

## RESTful Interactions

Often times when we talk about REST, we assume it has something to do with HTTP verbs and JSON. I hear it in job interviews all the time:

> Them: "Can you explain REST?"

> Me: "Sure! REST is REpresentational State Transfer. The client may only do (manipulate resources) what the server tells it to (via representations of those resources). Simply put, a RESTful client starts at the bookmark URL and..."

> Them: "No, I mean explain what some HTTP verbs are and what they do."

> Me: "..."

Don't misunderstand me - JSON over HTTP is a huge improvement over SOAP and all the baggage that comes with. But, this is not how humans typically interact with resources - we don't load up Fiddler2 and start POSTing data to random URLs. We type in a root url, click links, submit forms and click more links.

Also, you can now see the problem of the client knowing too much here. We'd have to distribute these secret keys to all clients. They'd also have to know how to sign the request. If we want to change this logic, we either have to a) maintain separate URL hierarchies for each version b) maintain separate media types for each version or c) redeploy every phone app and break backwards compatibility. REST shines by skipping this problem entirely.

Instead, the server and the server alone should contain this logic.

``html
GET /my-awesome-party-school/classes?q=american%20history HTTP/1.1 
Authorize: [token]

HTTP/1.1 200 OK

<html>
    <body>
        <ul>
            <li><a href="/my-awesome-party-school/enroll?institution-id=1&class-id=2&student-id=3&title=American%20History%20X&**token=somehash**">Enroll</a></li>
        </ul>
    </body>
</html>
```

```html
GET /my-awesome-party-school/enroll?institution-id=1&class-id=2&student-id=3&title=American%20History%20X&**token=somehash**
Authorize: [token]

HTTP/1.1 200 OK

<html>
    <body>
        <form action="/my-awesome-party-school/enroll" method="POST">
            <input type="hidden" name="institution-id" value="1" />
            <input type="hidden" name="class-id" value="2" />
            <input type="hidden" name="student-id" value="3" />
            **<input type="hidden" name="token" value="somehash" />**
            Reason for taking this class: <input type="text" name="reason" /> <!-- does not take part in hash -->
        </form>
    </body>
</html>
```
	
And then of course we `POST` the form back. If anyone tries to tamper with the request, we'll know.

## The Nancy Bits

Behold, the power of NANCY! This is pretty trivial to do with a little help from our friend [Nancy.Validation.FluentValidation](https://www.nuget.org/packages/Nancy.Validation.FluentValidation):

```csharp
public interface Secured {
    public string Token { get; set; }
}

public delegate string CalculateToken<T>(T input);

public abstract class CommandValidator<T> : AbstractValidator<T> where T: Secured {
    protected CommandValidator(CalculateToken<T> calculateToken) {
        Func<T, string, bool> match = (dto, token) => calculateToken(dto).Equals(token);
        
        RuleFor(x => x.Token).Must(match).WithMessage("Nice try hacker");
    }
}

public class EnrollValidator : CommandValidator<EnrollBuilder> {
    public EnrollValidator() {
        RuleFor(x => x.Reason).Must(NotContainBadWords);
    }
    
    private static bool NotContainBadWords(string s) {
        // use your imagination
    }
}

// module code
Get["/{institution}/enroll"] = _ => {
    var builder = this.Bind<EnrollBuilder>();
    return Negotiate.WithModel(builder);
}
Post["/{institution}/enroll"] = _ => {
    Enroll command = this.BindAndValidate<EnrollBuilder>(); // use two classes here to keep Token concept out of command
    if (false == ModelValidationResult.IsValid)
    {
        return Negotiate.WithModel(
            new ValidationErrorsViewModel(ModelValidationResult))
                        .WithStatusCode(400);
    }
    
    bus.Send(command);
}
// Application Registrations
public class Registrations : IApplicationRegistrations
{
    public IEnumerable<TypeRegistration> TypeRegistrations { get; private set; }
    public IEnumerable<CollectionTypeRegistration> CollectionTypeRegistrations { get; private set; }

    public IEnumerable<InstanceRegistration> InstanceRegistrations
    {
        get
        {
               // where Statically.CalculateHash takes a params object[] hashes with your super secret key from config, database, hard coded, whatever and returns a string
            yield return new InstanceRegistration(
                typeof (CalculateToken<EnrollBuilder>), new CalculateToken<EnrollBuilder>(dto => Statically.CalculateHash(dto.InstitutionId, dto.StudentId, dto.ClassId)));
                
        }
    }
}
```