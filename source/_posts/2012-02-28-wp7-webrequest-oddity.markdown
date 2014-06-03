---
layout: post
comments: true
title: "WP7 WebRequest oddity"
date: 2012-02-28T09:50:00+01:00
categories:
 - Windows Phone
 - Gotcha
 - C#
---

During testing of a Windows Phone 7 application I write during my day job I noticed strange thing: when I disabled network connection, I received 404 NotFound error. More precisely, the WebRequest threw WebException with Status = UnknownError, Response.Uri = {} and Response.StatusCode = NotFound.

{% img center /images/no+connection.jpg %} 

So you get 404 in two cases: when either connection endpoint is down or when server actually responds with 404 NotFound. It would be nice to separate those two cases though, for example to display to the user the message that actually helps them fix the problem.

{% img center /images/wrong+url.jpg %}

Fortunately you can tell those two situations apart by checking WebException.Response.ResponseUri - in case of connection failure it contains empty Uri object (not null, just empty). Here's the extension method I use to convert the exception to the one that makes more sense to me:

``` c#
public static WebResponse SaneEndGetResponse(this WebRequest request, IAsyncResult asyncResult)
{
    try
    {
        return request.EndGetResponse(asyncResult);
    }
    catch (WebException wex)
    {
        if (wex.Response != null &&
            ((HttpWebResponse)wex.Response).StatusCode == HttpStatusCode.NotFound &&
            wex.Response.ResponseUri != null &&
            String.IsNullOrEmpty(wex.Response.ResponseUri.ToString()))
        {
            throw new WebException("Network error", WebExceptionStatus.ConnectFailure);
        }
        throw;
    }
}
```
