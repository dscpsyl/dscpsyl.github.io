# Notes to Myself

## You will Forget
You will forget how this site works after a few days so here is something for future me to take a look at. You are using the [`Hydejack`](hydejack.com) theme for [`Jekyll`](https://jekyllrb.com/), pro version. The documentation for this theme is located in the `docs` folder of the repo. While not listed directly on the webpage, you can still access this via `/docs` on the website directly.

- All `.folder` folders in this repo are for development so they can be ignored in production. 
- If you need to start adding external scripts, please take a look at `/docs/scripts/`.
- If you need to add a new social medai icon, please take a look at `/docs/advanced/#adding-a-custom-social-media-icon` for more details.

As a reference, frontmatter specification is located [here](https://jekyllrb.com/docs/frontmatter/).

## How to Update the About Me Homepage

The homepage is located in the `index.md` file in the root directory.

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

## How to Add a Post
Take a look at the basics [here](https://jekyllrb.com/docs/posts/).

TLDR: Just add a new `post.md` to the `_posts` folder for a post with some front matter. An example front matter is shown below:

```markdown
layout: post
title: Example Content
image:
    path: /assets/img/blog/example.png
categories: [example, content]
tags: [example, content]
```

The name of the file is in the format `YEAR-MONTH-DAY-title.MARKUP`.

See `/docs/writing/` for specific details about writting for this theme.

> **Note**: We also have a way to natively embed *pdfs* and *ppts* into the site. See the [pdf plugin](https://github.com/MihajloNesic/jekyll-pdf-embed) for more details.

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

> **Note**: While the above is the native way for the theme to use images, you can also use the [picture plugin](https://rbuchberger.github.io/jekyll_picture_tag/) instead.

The name of the file can be whaever you want it to be, but it is recommended to use the title of the project.

## How to Add a Research Paper

Research is added the same as *Projects*. There is a custom layout `research.html` that is added to the themepack for the main overview page. The only difference is that in the overview, they are presented as a list instead of the grid. In addition, all papers are put in the `_research` folder and `research` collection.

## How to Update the Resume

The resume is defined under the `_data` folder in the `resume.yml` file. Edit and update as needed. You can see the details at `/docs/basics/#adding-a-resume`.
