# Notes to Myself

## You will Forget
You will forget how this site works after a few days so here is something for future me to take a look at. You are using the [`Hydejack`](hydejack.com) theme for [`Jekyll`](https://jekyllrb.com/), pro version. The documentation for this theme is located in the `docs` folder of the repo. While not listed directly on the webpage, you can still access this via `/docs` on the website directly.

All `.folder` folders in this repo are for development so they can be ignored in production.

As a reference, frontmatter specification is located [here](https://jekyllrb.com/docs/frontmatter/).

## How to Update the About Me Homepage

## How to Add a Page
Take a look at the basics [here](https://jekyllrb.com/docs/pages/).

TLDR: Just add a new `page.md` to the root of this repo for a page with some front matter. An example front matter is shown below:

```markdown
---
title: Documentation
description: >
  Here you should be able to find everything you need to know to accomplish the most common tasks when blogging with Hydejack.
hide_description: true
sitemap: false
permalink: /docs/
---
```

Or, if you have a bunch of items for one page, you can add a folder to the root of the repo and add an `index.md` file to that folder. This will make all the pages have the folder name permalink.

In addition, if you want, you can set the `permalink` frontmatter (as shown in the example) to fully control the URL.

## How to Add a Research Paper

## How to Add a Post
Take a look at the basics [here](https://jekyllrb.com/docs/posts/).

TLDR: Just add a new `post.md` to the `_posts` folder for a post with some front matter. An example front matter is shown below:

```markdown
layout: post
title: Example Content
description: >
  Howdy! This is an example blog post that shows several types of HTML content supported in this theme.
image:
    path: /assets/img/blog/example.png
categories: [example, content]
tags: [example, content]
```

The name of the file is in the format `YEAR-MONTH-DAY-title.MARKUP`.

## How to Add a Project
Projects are made the same as *Posts*, but just under a different collection (under the `_projects` folder). An example front matter is shown below:

```markdown
layout: project
title: '@qwtel'
caption: How I use Hydejack on my personal site.
description: >
  This is how I use Hydejack on my personal site. 
  Much of the development is informed from my experience of using it myself, creating a tight feedback loop.
date: 1 Jun 2020
image: 
  path: /assets/img/projects/qwtel.jpg
  srcset: 
    1920w: /assets/img/projects/qwtel.jpg
    960w:  /assets/img/projects/qwtel@0,5x.jpg
    480w:  /assets/img/projects/qwtel@0,25x.jpg
links:
  - title: Link
    url: https://qwtel.com/
accent_color: '#4fb1ba'
accent_image:
  background: '#193747'
theme_color: '#193747'
sitemap: false
```

The name of the file can be whaever you want it to be, but it is recommended to use the title of the project.

## How to Update the Resume

## How to Update the CV
