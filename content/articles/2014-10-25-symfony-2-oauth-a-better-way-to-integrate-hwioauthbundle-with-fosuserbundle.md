---
title: "Symfony 2 + OAuth: a better way to integrate HWIOAuthBundle with FOSUserBundle"
date: "2014-10-25T00:40:22Z"
type: "article"
categories: ["Development"]
tags: ["php", "symfony", "oauth"]
---

Many times we needed to develop a Symfony 2 based application which required OAuth integration. As there is no point in creating custom bundle and we usually use FOSUserBundle. To add support for OAuth based user authentication we can use HWIOAuthBundle. This post will describe a better integration of both bundles that will give your app users possibility to sign in via third party provider, not only to connect accounts.

This post presumes you have both bundles correctly installed and both are working correctly. The installation guides for FOSUserBundle & HWIOAuthBundle are really detailed so there’s no need to re-copy them here. If you still have any issues, please check the documentation, Github issues pages or post a comment here. It also covers just the lacking part of the integration – creating account via social accounts.

First of all, we’ll need a custom user manager that will search for an user with given username or email address: `UserManager::findUserByUsernameAndEmail($username, $email)`. The or conjunction is the key in previous sentence as most of the time, an OAuth resource owner will return an object containing user data (hopefully with username and email) and to avoid duplicated accounts, we need to check if any user (with given username or email address) does exist in the database.

We have custom user manager that extends core UserManager class that’s provided with FOSUserBundle. Now we’ll need custom user provided that will handle the logic (we’ll extend `FOSUBUserProvider` in this case). It’s quite simple piece of code: get user data, get user nickname or real name (`UserResponseInterface::getNickname()` or `UserResponseInterface::getRealName()`) then eventually create an user in database. As we have to store some info about OAuth response we’ll need to add some properties to User entity (to keep database consistent I use oauthService which stores the name of the provider, oauthId which stores user id and oauthAccessToken).

Integration process is almost done. We need to make the stuff working via `security.yml` configuration file.

All files can be found in this [GitHub repository](https://github.com/aosmialowski/FOSUserBundle-HWIOAuthBundle-integration).
