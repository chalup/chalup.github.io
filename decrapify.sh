#!/bin/bash

for post in source/_posts/*.markdown; do
  perl -p -e 's`<br ?/>`\n`g' -i'' $post
  perl -p -e 's`</?div.*?>``g' -i'' $post
  perl -p -e 's`&nbsp;` `g' -i'' $post
  perl -p -e 's`&lt;`<`g' -i'' $post
  perl -p -e 's`&gt;`>`g' -i'' $post
  perl -p -e 's`&amp;`&`g' -i'' $post
  perl -p -e 's`&quot;`"`g' -i'' $post
  perl -p -e 's/<pre.*?>/```\n/g' -i'' $post
  perl -p -e 's@</pre>@\n```\n@g' -i'' $post
  perl -p -e 's@<a href="http://.*?.bp.blogspot.com/.*?>(.*?)</a>@\1@g' -i'' $post
  perl -p -e 's@<img .*?src="http://.*?.bp.blogspot.com/.*?/([^/]*?)".*?/>@{% img center /images/\1 %}@g' -i'' $post
  perl -p -e 's@<a .*?href="(.*?)".*?>(.*?)</a>@[\2](\1)@g' -i'' $post
  perl -0777 -p -e 's@<blockquote.*?>(.*?)</blockquote>@{% blockquote %}\n\1\n{% endblockquote %}\n@gs' -i'' $post
  perl -0777 -p -e 's@<h2>Comments</h2>.*@@gsm' -i'' $post
  perl -p -e 's@<li>(.*?)</li>@\1\n@g' -i'' $post
  perl -p -e 's@(</?[uo]l>)@\n\1\n@g' -i'' $post
  perl -p -e 's@</?b>@**@g' -i'' $post
  perl -p -e 's@</?i>@_@g' -i'' $post
done
