+++
date = "2013-06-05T14:56:05.0000000+02:00"
title = "Displaying the Current Sprint in YouTrack for Your Boss"
author = "João P. Bragança"
tags = ["Project Management","Youtrack"]
+++

Here where I work we use YouTrack for issue tracking. We have a small team, it's easy to use and free.

We're also trying to get the business side more involved with what we're doing - to know that we're not just talking to ourselves / the keyboard all day. Unfortunately the default search leaves much to be desired.

Really what I want to show is all current features without subtasks (too noisy) AND any 'orphaned' tasks, bugs etc. Took a bit of messing around but I found an (undocumented) query that worked - `Fix versions: {Sprint Name} has: -{Subtask of}`.

Nice! We can also tack on #Resolved for last week's sprint to show what we actually completed.
