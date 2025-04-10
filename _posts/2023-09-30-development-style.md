---
layout: post
title: Collaborative Development Style
---

No man walks alone. Nowhere is that truer than for a developer. From the most prominent organizations to the smallest startups, standardization is a key tool in ensuring code quality and maintainability. Even if you're a solo developer, the future you will still have to deal with the choice present you make. Every developer has experienced a time where they had to unravel their past coding choices when revisiting old codebases and projects. Code style, code smells, and development styles measurably increase bug-catch rates and help with workflow [[1]](#1). This truth translates to the environment surrounding your code base. 

1. 
{:toc}

## Why be in Style?

Even if you are a solo developer, having a consistent style to easily search, understand, and reference what is happening is critical as you build your portfolio. Understanding someone else's codebase (or simply relearning your old one) is hard enough; don't add to the confusion by making commit messages inconsistent, pipelines untracable, or documentation hard to find. A logical and well-defined workflow will make you and your team more productive.

## Each Team's Fashion Sense

There are too many styles, practices, guidelines, and philosophies to list and present. If I were to try to include them all to explain, this would be under **[Research]({{ site.baseurl }}{% link research.md %})**, or I would tell you to go read [Agile](https://www.agilealliance.org/agile101/). Instead, I want to present a starting point for your team's exploration, research, and evolution. I will explain my rationale for each choice and how it has helped my team in our development. This style is based around [Git](https://git-scm.com/) and [GitHub](https://github.com/) but can be adapted to any version control system or ecosystem.

If you've never tried to follow a style, I encourage you to start here. I find it flexible enough to introduce you to some concepts while not limiting you to a rigid set of rules.

## Commiting to the Style

We will start with the most basic item: commit messages. It goes without saying that all commits should be small and incremental. Hopefully, they are atomic enough for the codebase to utilize the true power of Git. Yet, when it is time to go and commit, you need to explain to someone what you changed without them having to look at the code. In this style, we use [Conventional Commits (CC)](https://www.conventionalcommits.org/) as the foundation for our commit messages. Its website has a great *FAQ* about why you should use it. TLDR: It helps with automation, documentation, and understanding. For someone with no previous preferences in their messages, this ensures a versatile beginning to be adapted wherever your journey takes you. While the specification isn't too long, I will summarize the important parts here.

### Overall Format

The overall format of a commit message is:

~~~sh
<type>[optional (scope)][optional !]: <description>

[optional body]

[optional footer(s)]
~~~

Let's go through each part one by one.

#### Type

This is the "category" of your change. It really can be any set that your team agrees on. However, as per *CC*, the two most common ones are `feat` (adding new code) and `fix` (fixing old code).

Some more common types that are defined are:
- `docs`: Changes in documentation or comments
- `style`: Everything related to styling (of code and not application)
- `refactor`: Changes that neither fix a bug nor add a feature
- `test`: Everything related to testing (i.e., when creating a test suite and not modifying a file to pass tests)
- `chore`: Everything related to maintaining the code (e.g., updating build tasks, package manager configs, etc)

#### Scope

This is an *optional* field that can be useful when your codebase is large. It defines the area of impact for your change. For example, if you are working on a full-stack application, you might have `client`, `server`, `database`, etc. You can also make it more granular. Say your app has multiple microservices, you could have `auth`, `payment`, `notification`, etc. Just remember that the scope will be in parentheses, i.e., `(auth)`.

#### Exclamation

This is an *optional* character that helps denote a breaking change. It is most commonly used when moving from version 1 to version 2 or when an external dependency changes.

#### Commit Message Description

This is the "title" of your commit. It should inform the reader broadly of what you've changed. As a general rule, it should be less than 25 words; any more than that, and it should be in the body. 

Do not end it with a punctuation mark, as it is not a sentence. Plus, it's an extra character that will forever be in your history. Over time, they add up. 

Start your title with an imperative tense word (e.g., `add` and not `added` or `adds`). This makes it neutral and easier to understand. In addition, capitalize only the first word to denote the start of the description sentence (e.g., `feat:Compute ray render`). This wording style may seem picky at first, but when someone is reading through hundreds of commit histories, it makes the process easier to scan and digest.

Some may find it helpful to think of the description as completing the sentence: *“After this commit, the application will…”*. Contrast that with *“In this commit, I will…”*. At the end of the day, you are simply the medium through which the code is changed. Your actions and process are not important; the code is. You will not perform the application functions; the code will, so make the message about the code (e.g., not `feat:Add database handler` but `feat:Openfacing database api`).

#### Body and Footer

These are both *optional* fields. I slightly discourage using these fields as we have integrated better ways of expressing these fields through *Github*. However, if your team is on a pure *Git* workflow, I recommend reading more about them on *CC*'s website.

#### Owner

In today's day and age, computer security is more important than ever[[2]](#2)[[3]](#3). As such, each person should have all their commits signed with their [GPG key](https://gnupg.org/). That isn't to say that these referenced CVE cases could've been solved by this. Rather, *GPG* is another layer of security to lock down any potential leaks in your codebase. Plus, it just looks cool. Thus, you should utilize the tools Github offers you and [add your GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification).

For those environments where code change attribution is necessary, add the initials of programmers at the end of the description to give credit to the authors when group programming (e.g., `feat:describe a description-(ds/jz/pm)`). Note the hyphen, lack of spaces, and parentheses between the description and initials. If group members' initials are the same, utilize the hierarchy below until there is no ambiguity (e.g., `(dos/jz/pm/dss)`):
1. Middle name initial
2. Middle name letters
3. Last name letters
4. First name letters

## Coding in Style

Okay, I know this post is about everything around the code, but I would be remiss if I didn't mention a few overarching items that apply broadly. Don't forget, there are too many code linters, formatters, plugins, and tools to help you with this section. However, here are some basics that I believe in.

### LCC (Lower Camel Case) Supremacy

In line with the "punctuations add unnecessary characters" theme, I believe underscores do the same. One can easily read a variable name through LCC, and it saves on character count and finger strokes. Is there a place for underscores? Maybe, but it is definitely not in your variable names.

### Bracket Brakes

The first bracket should be on the same line. I don't know why you would have a bracket on its own line. That's not how to extend your lines-of-code-written stat. It takes up a useless line and, in my personal opinion, looks a little dumb and incomplete.

~~~c++
// file: `correct.cpp`
for(int 0; i <= streetLength; i++) {
  walkTheDog();
}
~~~

~~~c++
// file: `bad.cpp`
for(int 0; i < sillyModeMax; i++) 
{
  beBad();
}
~~~

### Unused Imports Need to Go

While I may be a hoarder in real life, there's no need to hoard your dependencies in your codebase. It will still be there the next time you need to use it. Unused imports bloat your code, make it harder to understand, and create gaps for security vulnerabilities. REMOVE. UNUSED. IMPORTS. Better yet, minimize your imports. You don't need the [`is-thirteen`](https://github.com/jezen/is-thirteen) library.

## Fashionable Issues

Issues are the main reason why we collaborate on code. If we all wrote perfect code, who would want to deal with another person? As such, issues need to be documented and transferable between members. Here, we define two categories of issues: **small** and **large**. 

Both categories incorporate all types of issues (i.e., bugs, vulnerabilities, etc.).
{:.note title="Note"}

### Small Issues

These small issues can be solved within 10 minutes and can be described within 100 words. 

Both of these conditions must be met for it to be considered a small issue. If it can be described in less than 100 words but cannot be fixed within 10 minutes, then it is not a small issue. Likewise, if it can be fixed within 10 minutes but is so nuanced that 100 words cannot tell the whole story, then it is not a small issue.
{:.note title="Be Careful!"}

Such small issues should be relayed across team members through non-codebase channels (e.g., Slack, Discord, etc.). This will prevent clustering of issues, say on Github, and preserve such places for more critical, team-wide considerations. That is not to say that these small issues are any less important. Never should an issue in an existing codebase be fixed by a single person. You never know when and where it will be called, and if your fix breaks compatibility, it will be a nightmare domino effect.

### Large Issues

These issues encompass anything that small issues cannot. More literally, if you need to write documentation on the issue, or even *issue* a press release, then it is a large issue. These issues should be documented on *Github* through the Issues tab and need to be more thoroughly described. This way, the entire team can work on the issue and be on the same page. Below is a very minimal but adaptable template. Because there are an infinite number of ways an issue can arise, I have chosen to include only the bones. Feel free to adapt and modify this template for your codebase.

### Issue Template Explanation

#### Issue Title

This is the summary of the issue. It should be descriptive but no more than 10 words. Think of this like the [description in a commit message](#commit-message-description).

#### Issue Title Description

This is the actual details of the issue. It should include all relevant details of the issue and why it is not working as expected. Some people also include `expected behavior` and `actual behavior` subsections. If you get a colleague to read nothing else but this section, and they have no idea what the issue is, then you did it wrong. While detailed, it should also be brief, no more than three paragraphs. Any more than this, and you have multiple issues on your hands.

#### Replication

This is where you document how to reproduce the issue. Think of this almost as a copy-and-paste installation section on *Github*. I should be able to run everything you've described here without thinking and reproduce the problem. 

#### Other Information*

This is where you include everything else related to the issue. It has an asterisk because it is the most adaptable part of this template. Add subsections, links, and anything else you deem fit. I personally would include platform and system versions, screenshots, and maybe even videos.

### Issue Template

~~~markdown
<!--file: `.github/ISSUE_TEMPLATE/basic.md`-->
## Description
<!--A paragraph explaining the issue.-->
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

## Replication
<!--What steps are needed to reproduce this issue?-->
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

## Other Information
<!--Any other related information that someone trying to debug this issue needs to know.-->
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi
~~~

## Perfect Pull Requests

Pull requests are the backbone of *Git* collaboration. It is how code is accepted into the application, it is how work is measured, it is how progress is completed. There really aren't (or shouldn't be) that many types of pull request varieties. With it being so universal across all projects, this template is a little more thorough compared to issues. Regardless, feel free to adapt it to your needs.

### Pull Request Template Explanation

#### Pull Request Title

Again, this is like the [description of a commit message](#commit-message-description), with 10 words or less. Can someone familiar with the project understand precisely what is being added?

#### Overview 

This should summarize all the commits in the pull request and should also follow the 3-paragraph rule. Not only does this limit encourage brevity, but it also helps as a sanity check that the one pull request is not trying to add too much to the codebase. You shouldn't be doubling the codebase in one pull request. You should also go into more detail about the specific changes made in the pull request so that someone familiar with the project can understand all the changes exactly. It should include details from the programmer, admin, and user perspectives. If there is a working instance (e.g., a dev branch or a demo), link it here as well.

#### Screenshots (Optional)

If the change has a visual component, include a screenshot. This allows for reviewer to quickly glance at the proposed addition without the need to spin up their own instance. If needed, flex those markdown skills and add captions to the images for clarity. I will also add that if you are committing frontend visual changes, then you should treat this section as non-optional.

#### Feedback Request (Optional)

If the pull request is a work in progress or if there are code sections that a reviewer should pay attention to, mention it here. Don't be shy and egotistic; ask for help if you need it. If there is a specific person who should pay attention, add them here to get their attention. You should be specific about the types of feedback you are looking for and not just general feedback. (e.g., "*I am looking for feedback on the new API calls and if we need more granular control*" or "*Dave, please help me review my implementation of the matching algorithm and its speed*"). You should be competent enough not to require a classroom-level review.


#### Future Possibilities (Optional)

This section is a somewhat pathos section of approving this merge. Talk about the big picture or reiterate the necessity of this change to remind people of its big-picture purpose. Be as comprehensible as required, but do not put your grandeur dreams first. This is not a place to pitch your next big idea.

#### Validation (Optional)

If there isn't a demo instance, what steps are necessary to reproduce your feature to check that it works? Start by checking out your branch and then interacting with the app. It doesn't have to be complicated, but like the [replication section of the issues template](#replication), it should be easy to follow mindlessly. If nothing else, treat this section as if you were talking with your end user.

#### Tests

This is a checklist-style of all the standard tests your pull request has passed. They should not include any CD/CI tests that will run (e.g., github workflows). Instead, they should be manual tests that must be passed before the pull request can be merged. This suite of tests should be standardized by the team. If there are additional one-off tests, make sure they are clearly marked. If there are any failed tests, call them out and, if necessary, explain why they are necessarily failing.

#### Linked Issues

Most, if not all, pull requests should be linked to an issue. This is a feature of *Github*, but regardless, the issue prompting this pull request should be referenced somewhere. This is a great way to keep track of progress and automatically remove completed issues during CD/CI. That said, try to limit each pull request to one issue. This ensures your request is not too large and heavy on the codebase. If you need to link multiple issues, link one issue per line for readability. On *Github*, you can link an issue by using any of the following magic words plus `#issueNo`:

- close
- closes
- closed
- fix
- fixes
- fixed
- resolve
- resolves
- resolved

### Pull Request Template

~~~markdown
<!--file: `.github/PULL_REQUEST_TEMPLATE/basic.md`-->
## Overview
<!--A paragraph of the PR and related content-->
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

## Screenshots (Optional)
<!--Necessary screenshots and any necessary captions here. Delete if not needed.-->
![Generic placeholder image](https://picsum.photos/640/480)

## Feedback Request (Optional)
<!--Anywhere specific you want reviewers to take a look at and give suggestions. Delete if not needed.-->
None needed. I am the best.

## Future Possibilities (Optional)
<!--What do you think this project could become? Delete if not needed.-->
This will go to the moon if we invest all our life savings into this concept!!!

## Validation (Optional)
<!--Steps that someone else could take to make sure everything is working-->
Just trust me, bro. :)

## Tests
<!--Add any additional tests or required tests-->
- [ ] Unit tests pass
- [ ] Test coverage is at 100%
- [ ] Mutation tests show a rate of 100% 

## Linked Issues
<!--Issues related to the PR-->
Closes #0
~~~

## Code Reviews

A simple *"LGTM!"* is **NOT A CODE REVIEW**! It is a sign of laziness and, in my experience, one of the leading ways issues get leaked to production. Instead, the reviewer should pay attention to the code changes and not rely automatically on the CD/CI environment.

Below is a checklist to help guide you with some starting questions to consider when doing a code review. It is not an exhaustive list, but it should be mostly included in any review.

Write any issues or suggestions that you may have to the requestor and have those issues changed before approving. Remember to be constructive and respectful with your review. They took the time to code everything, after all. We are all learning, so have open discussions about your suggestions and provide guidance if necessary. Make sure your suggestions and criteria are straightforward for the requestor to go and fix. Your code review is not done until you approve of the PR, so respond to any changes and updates within a reasonable time frame!

### Responding to a Code Review

Be positive and open a discussion. You do not have to implement or agree with other people's decisions. Respond from a point of gratitude- they took the time to look over your code, after all. If you agree, write something to acknowledge their feedback(e.g., “good call, fixed” or “thanks for catching that, fixed”). If you don't, open a discussion with them and see how to resolve the issue; don't just dismiss the comment (e.g., “Hmm, I see it differently; let’s discuss” or “I’m not sure I understand your perspective; can you explain further?” or “I see where you are coming from, but i/we think it should be like this…”).

### Code Review Checklist

- [ ] Is the PR conforming to the standards described within this document?
- [ ] Are there relevant sections (e.g., screenshots for frontend, test coverage,e and mutation for all)
- [ ] Is the purpose of the PR well explained, not just the what, but also the why?
- [ ] If there is a linked issue, is the assigned issue coder in the loop with this PR (i.e., the PR requestor or approves the PR)?
- [ ] Does the PR pass all of the CI/CD tests?
- [ ] When applicable, is there a deployed dev instance to test, and does it work?
- [ ] If the issue(s) this PR addresses have acceptance criteria, are all of those met? And if so, are they checked off?
- [ ] Commented out code; typically, this should be removed before merging into the default branch.
- [ ] Quickly look at the file changes and see if any stand out and should be removed (e.g., .DS_Store from Mac users or *~ from emacs users or package.json and package-lock.json at the top level of the repo (they should only be in the frontend directory)

## Conclusion

That wasn't so bad, was it? The simplified documentation on our discussion can be found [here](https://gist.github.com/dscpsyl/8b9ae7454ed38e81db67715479dce5e8). Now, go on and explore, adapt, and break all the rules you deem fit. Just remember to document your changes.

## References
<a id='1'>[1]</a>
A. Cairo, G. Carneiro, and M. Monteiro, “The Impact of Code Smells on Software Bugs: A Systematic Literature Review,” Information, vol. 9, no. 11, p. 273, Nov. 2018, doi: https://doi.org/10.3390/info9110273.

<a id='1'>[2]</a>
CVE-2021-44228 (Log4j2). https://nvd.nist.gov/vuln/detail/cve-2021-44228

<a id='1'>[3]</a>
CVE-2024-3094 (xz). https://nvd.nist.gov/vuln/detail/cve-2024-3094