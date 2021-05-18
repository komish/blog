---
title: "An Effective Approach to HTTP API Error Handling"
publishDate: 2021-05-18
categories: [Notes]
tags: [golang, software-development, json, error-handling]
description: "A note for the knowledge base on the subject of error handling for HTTP APIs in Go."
---

I enjoy testing and learning about various different approaches to software
design paradigms.

I'm not really sure where the interest started, but I noticed the interest pique
while reading [Head First: Design
Patterns](https://www.goodreads.com/book/show/58128.Head_First_Design_Patterns).

Perhaps that's where it began.

A majority of my enjoyment in reading **Head First: Design Patterns** stemmed
from finding out that these patterns had names, identifiable concepts, and clear
problems that they solved. Of course, the fact that these patterns solved
various problems in software development was a given, but the reality is that
seeing them in the wild means that you don't always know the problem that they
solve when you encounter them.

But even outside of the common design patterns, seeing various patterns that
developers have cooked up and placed intentionally into their code is very
interesting to me. Even better if it has an explanation!

Now, to the core subject of this particular post - error handling. I've dabbled
with a couple of approaches to error handling in small projects I've built for
myself. With that said, I've never been incredibly happy with )any of them.

The next one I intend to try and use is covered by **Joe Shaw** in his blog post
entitled [Error Handling in Go HTTP
Applications](https://www.joeshaw.org/error-handling-in-go-http-applications/). 

The key idea that I really like is the concept of API-safe errors, which are
those that your service's users should see, and how those can safely include
wrapped user-unfriendly errors without exposing internal details about your
service's functionality. It's an important distinction to draw, and I think the
way Joe implements it is effectively. I can't wait to give it a shot.

Give the post a
[read](https://www.joeshaw.org/error-handling-in-go-http-applications/)! 
