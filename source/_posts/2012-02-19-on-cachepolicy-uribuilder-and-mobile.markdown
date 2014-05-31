---
layout: post
title: "On CachePolicy, UriBuilder and mobile .NET"
date: 2012-02-19T11:00:00+01:00
categories:
 - Windows Phone
 - Rant
---

In the Windows Phone 7 application I was working on there was a problem with some WebRequest caching. I'm not sure if it should have been fixed on the client side or server side, but since it's just a matter of setting proper CachePolicy property of WebRequest I was going to add it to mobile application.

Imagine my surprise when I found out that CachePolicy is not supported on Windows Phone 7. The obvious workaround is adding an URI param `no-cache=MS_FROM_EPOCH` or something like that.

Now, if you'd ask me what is the cardinal example of stuff that shouldn't be done using string concatenation, but is notoriously done that way, I'd answer: URI building. It's highly structured string with [RFC](http://tools.ietf.org/html/rfc3986), so it stands to reason to create and use a dedicated builder and parsers API to make sure everything is well-formed.

Let's take a look at UriBuilder class and URIs in general. All the stuff between ? and # (VERIFY) is called query string, which contains key-value pairs separated by &s. What kind of API for query string would make sense? An IDictionary<String, String>! What API is presented by UriBuilder? A string! Take a look at the [documentation](http://msdn.microsoft.com/en-us/library/system.uribuilder.query.aspx). Here's the best part:

{% blockquote %}
<b>NOTE</b> Do not append a string directly to this property. If the length of Query is greater than 1, retrieve the property value as a string, remove the leading question mark, append the new query string, and set the property with the combined string. 
{% endblockquote %}

Ridiculous. Seriously, MS, I don't care it's transformed to a string, it's a key-value dictionary, so let me treat it as such!

Fortunately C# has this nice feature called extension methods, meaning we can "add" a method to a class. There are no extension properties, but we can have a method like this:

``` c#
UriBuilder WithQueryParam(this UriBuilder uri, String key, String value)
```

But now we need to check for duplicate keys and for that we have to parse existing query string. Fortunately there is a method for this: [HttpUtility.ParseQueryString](http://msdn.microsoft.com/en-us/library/system.web.httputility.parsequerystring.aspx).

Except it's not available on mobile .NET. Again. But why?

The same thing irritate me when I worked on Blackberry apps and I had to put up with Java ME no String.format, no date handling methods, no generics and sane collections. But I understand that Java ME is supposed to work on wider range of devices, some of them with very limited CPU and RAM resources, so every cycle and every byte of memory matters.

Now let's take a look at Windows Phone 7 [hardware requirements for manufacturers](http://en.wikipedia.org/wiki/Windows_Phone#System_requirements): 256MB of RAM and 800MHz CPU. I'm not an .NET expert, but I'd hazard a guess that supporting  full desktop .NET would not make any difference on those powerhouses. Hell, you should be able to send a man to the Moon using this hardware, so please, can I have a query string parser?

Is it some kind of Windows Mobile 6 legacy, or just a very bad MS joke that non-MS people don't get?
