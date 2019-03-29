+++
date = "2014-05-02T08:00:00.0000000-07:00"
title = "What Business are You In?"
author = "João P. Bragança"
tags = ["random","rant"]
+++

Apologies in advance if the title is totally unoriginal.

[Nathaniel Jones](http://www.nathanaeljones.com/) recently posted a blog on his [experiences with Azure](http://www.nathanaeljones.com/blog/2014/azure). Unfortunately he had a pretty bad experience.

> I checked, and all of my azure sites were down. I logged into the portal, and discovered that all of my databases, backups, instances, and websites had been terminated and deleted. There was nothing left. In fact, everything had been deleted at midnight, 8 hours prior to the first (and only) notification of the action taken.

He then goes on to detail a pretty lousy but all too typical customer service experience, where the help on the other end seems to be reading from a script.

> Kindly be informed by design when a subscription is cancelled or disabled, all deployments are deleted leaving only the SQL database and Storage account which will be available for 90 days from the date of cancellation.

Real people in real life never talk to you this way. *Kindly be **past participle*** is just a really nice way of telling you to GFYS.

To be fair though I don't believe there's anything that tech-support guy can do. He has no restore account button because that functionality *likely doesn't exist*. Why not? They don't understand what their core business is. 

Azure seems like an awesome platform - clearly they have the whole "developer experience" and "add cpu cycles" stories down pat. But to see them completely drop the ball on payments and billing is just heart breaking.

## Flashback

My first real job back in 2001 was half programming, half asterisk. The place was an import-export business, a kind of one man operation. Its *raison d'être* was to cut out as many middle men as possible by becoming the only middle man.

After a few years of working there, the Patron and a friend of his got the great idea of importing consumer products and selling them online via eBay. My job was to photograph, describe and list these items.

Many of the items were similar, differing only by size and color. The programmer nerd in me said "let's automate this!" and so I did. This allowed us to put up a wider variety of items up faster and the business took off.

After that happened, a flood of email was not far behind. We were totally unprepared. Most of it was "stupid" questions that could have been answered by reading the listing. Another portion of it was people lying about not getting it (we could track the package and see it was delivered), not what they ordered, etc. Very little of it was actual legitimate complaints.

No one else wanted to answer all this email, so naturally it fell on me. I didn't want to do it. It was overwhelming. Being an arrogant little prick, I thought I was above it. I deleted as much of it as I could, trying to focus on what I felt were the real complaints.

## The Software Business

If you asked the Azure team what their core business, I imagine you'd get answers like Cloud Computing, Platform as a Service or Delivering Software. If you asked me what our core business was I'd probably tell you it was to sell stuff on eBay.

That is the wrong answer.

How many DBAs have you come across who thought it was their job to protect the company's data? Or developers who thought it was their job to write code, apparently not caring about performance and how that would impact the user? Or project managers who think they only need to meet deadlines?

Wrong answer!

As people that ship software, we're in the **customer service** business. It shouldn't matter if those customers are large corporations, small potato ISVs or cubicle slaves. It should not matter if the account was $0.000001 over or $5,000 over. You want to keep those customers and to do that you have to keep them happy.

Without customers, we have no business.
