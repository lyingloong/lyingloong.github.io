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
The site intentionally has no footer.

## Blog

The blog index is available at `/blog/`. Copy `_templates/post.md` to `_posts`
using the filename `YYYY-MM-DD-slug.md`. All posts inherit the shared layout,
navigation, typography, and optional table of contents from the site defaults.
Write the article in Markdown; no page-specific styling is needed. For example:

```markdown
---
title: Your post title
description: A short summary shown on the blog index.
tags: [research, notes]
---

Write the post in Markdown here. Inline math such as `$x^2$` and display math
such as `$$x^2$$` are supported.
```

Optional fields include `summary`, `updated`, `lang`, and `toc: false`.
Use `published: false` for drafts. See [the blog style guide](docs/blog-style-guide.md)
for headings, figures, tables, code, and equations. The guide and starter template
are excluded from the published site.
