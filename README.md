# Hao Wang's Homepage

[https://lyingloong.github.io](https://lyingloong.github.io)

This repo is built from the foundation of [academic-homepage](https://github.com/luost26/academic-homepage).

## Start
```
bundle exec jekyll serve
```

## CV

The CVs share `cv/resume.cls`. The Professional layout uses `cv/main.tex.erb`
and the Education layout uses `cv/education.tex.erb`.

Edit [`cv/education.md`](cv/education.md) or [`cv/professional.md`](cv/professional.md)
to update the corresponding CV. Each file contains the complete copy for its own
PDF. Keep the order of the `##` sections so each keeps its layout. Use `###`
for roles and projects, `date · location or subtitle` for their metadata, and
`-` bullets for details.

Building requires Ruby 3, XeLaTeX, latexmk, TikZ, and the TeX Live Chinese
language and recommended font packages. On Debian or Ubuntu, install them with
`sudo apt install ruby latexmk texlive-xetex texlive-pictures texlive-lang-chinese texlive-fonts-recommended`.

Run this command from the repository root.

```sh
./cv/build.sh
```

Use `./cv/build.sh professional` or `./cv/build.sh education` to build a single
version. Both PDFs go in `assets/cv/` as `CV_wanghao_professional.pdf` and
`CV_wanghao_education.pdf`. The homepage links to the Professional CV.

Jekyll excludes the `cv/` source directory from the published site. Commit
the rebuilt PDFs with their source updates to publish them through GitHub Pages.

## Design

The site uses a compact academic layout with a white background, blue links,
and plain publication and experience lists. Shared styles live in
`assets/css/global.css`; the existing Jekyll data and collections still supply
the content. Edit `_data/profile.yml` for personal information and
`_data/display.yml` for homepage sections and the number of recent news items.
Older news remains available under “Earlier news” on the homepage.
The site intentionally has no footer.

## Projects

Project frontmatter uses `date` only for sorting. Add an optional `display_date`
string, such as `display_date: "2025–present"`, to show a date or range on both
the homepage and Projects page. Omit it or leave it empty to hide the date.

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
