# Hao Wang's Homepage

[https://lyingloong.github.io](https://lyingloong.github.io)

This repo is built from the foundation of [academic-homepage](https://github.com/luost26/academic-homepage).

## Start
```
bundle exec jekyll serve
```

## Design

The site uses a compact academic layout with a white background, blue links,
and plain publication and experience lists. Shared styles live in
`assets/css/global.css`; the existing Jekyll data and collections still supply
the content. Edit `_data/profile.yml` for personal information and
`_data/display.yml` for homepage sections and the number of recent news items.
Older news remains available under “Earlier news” on the homepage.

## Blog

The blog index is available at `/blog/`. Add a new Markdown file under `_posts`
using the format `YYYY-MM-DD-slug.md`; Jekyll will publish it automatically and
list it on the blog page. For example:

```markdown
---
layout: post
title: Your post title
description: A short summary shown on the blog index.
tags: [research, notes]
---

Write the post in Markdown here. Inline math such as `$x^2$` and display math
such as `$$x^2$$` are supported.
```
