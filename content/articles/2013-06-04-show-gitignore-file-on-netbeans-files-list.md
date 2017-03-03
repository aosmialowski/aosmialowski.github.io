---
title: "Show .gitignore file on Netbeans files list"
date: "2013-06-04T11:22:00Z"
type: "article"
categories: ["Development"]
tags: ["netbeans", "git"]
---

By default, Netbeans is hiding all files with names starting with a dot excluding .htaccess file. If you are using Git you’ll problably face an issue here.

The solution is quite simple. Go to Tools => Options, select Miscellaneous tab and the Files subtab. All you need to do is to change Ignored Files Pattern into the following string:

```
^(CVS|SCCS|vssver.?.scc|#.*#|%.*%|_svn)$|~$|^.(?!(htaccess|gitignore)$).*$
```

If you screw something out, there’s a Default button on the right-hand side which will restore the original pattern `^(CVS|SCCS|vssver.?.scc|#.*#|%.*%|_svn)$|~$|^.(?!htaccess$).*$`.

Hope this would help you saving few minutes.
