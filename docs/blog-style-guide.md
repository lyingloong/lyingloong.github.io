# Blog style guide

Every post uses the same layout and styles. Copy `_templates/post.md` to
`_posts/YYYY-MM-DD-slug.md`, write the content in Markdown, and remove
`published: false` when it is ready to publish. The filename supplies the date
and URL. Keep the title and a short description in front matter.

## Front matter

- `title`: the article title; do not repeat it as a Markdown heading.
- `description`: one or two sentences shown below the title and in the blog index.
- `tags`: a short list of relevant topics.
- `summary`: optional Markdown text summarizing the main finding or argument.
- `updated`: optional `YYYY-MM-DD` date for a substantive revision. Set it manually.
- `lang`: defaults to `en`; use `zh-CN` for a Chinese article.
- `toc`: defaults to `true`; set it to `false` for a short note.
- `published: false`: keeps a draft out of the public site.

The defaults already set `layout: post` and `navbar_title: Blog`. The table of
contents is generated from second- and third-level headings when JavaScript is
available. Without JavaScript, the article remains readable and the empty table
of contents stays hidden.

## Structure and prose

Start the body with a brief introduction. Use `##` for major sections and `###`
for subsections; avoid skipping heading levels. Give headings concise,
descriptive names. Keep paragraphs focused on one point and use lists for items
that are easier to compare or follow in sequence.

For an experiment report, a useful order is the research question, method,
results, and limitations. A tutorial, reading note, or essay can use its own
structure. State what the evidence supports and separate observations from
interpretations. Preserve units, experimental settings, and source links.

## Figures and captions

Store figures under `assets/images/blog/`. Use descriptive alt text. A figure
with a caption can use this small HTML block; no inline styles are needed:

```html
<figure>
  <img src="{{ '/assets/images/blog/example.webp' | relative_url }}"
       alt="Describe what the figure shows" width="1200" height="600">
  <figcaption>Explain the figure and link to its source when applicable.</figcaption>
</figure>
```

Use the image's real width and height to reserve the correct aspect ratio.
Keep the caption factual, and credit external figures. Ordinary Markdown image
syntax also works when a caption is unnecessary.

## Tables, code, and equations

Use Markdown tables with a descriptive header row. Include units in the
headers, align numeric columns to the right, and explain abbreviations near the
table. Wide tables should scroll within the article instead of widening the page.

Use fenced code blocks with a language name such as `python`, `bash`, or `json`.
Use inline code for identifiers and commands. Prefer prose or lists over code
blocks when describing an algorithm without executable code.

Inline math uses `$x^2$`. Put display math between separate lines containing
`$$`. Equations, code blocks, and wide tables share the site's responsive
overflow behavior.

Use blockquotes for quotations and link to the source. Use horizontal rules
sparingly. Avoid inline CSS, custom fonts, repeated title banners, and per-post
layout markup; update the shared layout or stylesheet when a reusable pattern
is needed.
