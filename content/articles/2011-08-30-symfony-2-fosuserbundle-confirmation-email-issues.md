---
title: "Symfony 2 + FOSUserBundle: confirmation email issues"
slug: "symfony2-fosuserbundle-confirmation-email-issues"
date: "2011-08-30T00:35:00Z"
type: "article"
categories: ["Development"]
tags: ["php", "symfony"]
---

On Stack Overflow & Symfony forums I recently saw questions about FOSUserBundle confirmation issues. Basically emails are not being sent. This post will help you solve that “issue”.

First of all, it is not an issue at all. It is caused by misunderstanding of the bundle documentation. Every configuration attribute can be found in FOSUserBundle configuration reference.

### Solution

To enable email confirmation in your application you just need to enable it via your application config file (app/config/config.yml in this example):

```
fos_user:
  registration:
    confirmation:
      enabled: true
```

That's all. Confirmation emails will be sent now. Quite easy, isn't it?
