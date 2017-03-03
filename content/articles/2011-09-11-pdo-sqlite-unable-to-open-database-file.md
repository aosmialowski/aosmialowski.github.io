---
title: "PDO + SQLite = Unable to open database file"
date: "2011-09-11T13:25:00Z"
type: "article"
categories: ["Development"]
tags: ["php", "sqlite"]
---

Recently I was working on a system where SQLite database was used as data storage engine. There were some problems with the development version of the application but was resolved very quickly. However I faced one problem that took over 20 minutes to get resolved.

Important notice: system was using PDO to connect with SQLite database. On one page a PDOException was thrown:

```
(...)
SQLSTATE[HY000]: General error: 14 unable to open database file
(...)
```

I double checked all .sqlite file permissions – of course everything was set up correctly. SELinux was not the problem in this case as it was completely disabled on my development box. As the all system was prepared by another programmer I was more than sure that the problem is caused by wrong permissions.

### Solution

After analysing the permissions of the database file, I checked data folder permissions. While using PDO you need to remember that PDO SQLite driver **must have the write permissions** while performing write operations.

Small thing, only one terminal command may help you save 20 minutes while working with PDO + SQLite.
