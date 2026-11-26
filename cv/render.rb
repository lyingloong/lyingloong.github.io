require "erb"
require "pathname"

CV_DIR = Pathname.new(__dir__)
TEX_ESCAPES = {
  "\\" => '\textbackslash{}',
  "{" => '\{',
  "}" => '\}',
  "$" => '\$',
  "&" => '\&',
  "#" => '\#',
  "_" => '\_',
  "%" => '\%',
  "~" => '\textasciitilde{}',
  "^" => '\textasciicircum{}'
}.freeze

def tex(value)
  value.to_s.gsub(/[\\{}$&#_%~^]/, TEX_ESCAPES)
end

def link(label, url)
  address = url.gsub(/[\\{}%#]/) { |character| "\\#{character}" }
  "\\href{#{address}}{#{tex(label)}}"
end

def inline_tex(value)
  tokens = value.to_s.split(/(\*\*[^*]+\*\*|\*[^*]+\*|\[[^\]\n]+\]\([^\n)]+\))/)
  tokens.map do |token|
    case token
    when /\A\*\*([^*]+)\*\*\z/
      "\\textbf{#{tex(Regexp.last_match(1))}}"
    when /\A\*([^*]+)\*\z/
      "\\textit{#{tex(Regexp.last_match(1))}}"
    when /\A\[([^\]]+)\]\(([^)]+)\)\z/
      link(Regexp.last_match(1), Regexp.last_match(2))
    else
      tex(token)
    end
  end.join
end

def inline_link_group(line, first_separator: " ")
  text, *links = line.split(/ +(?=\[[^\]]+\]\([^)]+\))/)
  formatted_text = inline_tex(text)
  return formatted_text if links.empty?

  formatted_text + first_separator + links.map { |entry| inline_tex(entry) }.join(' \enspace ')
end

def render_template(name, context)
  template = CV_DIR.join("#{name}.tex.erb")
  renderer = ERB.new(template.read(encoding: "UTF-8"), trim_mode: "-")
  renderer.filename = template.to_s
  renderer.result(context)
end

def markdown_sections(source, marker)
  intro, *parts = source.split(/^#{marker}[ \t]+(.+?)\n/, -1)
  sections = parts.each_slice(2).map { |title, body| [title.strip, body.strip] }
  [intro.to_s.strip, sections]
end

def markdown_lines(source)
  source.lines.map(&:strip).reject(&:empty?)
end

def markdown_paragraphs(source)
  source.split(/\n[ \t]*\n/).map { |paragraph| markdown_lines(paragraph) }
end

def markdown_bullets(source)
  intro, *items = source.split(/^-[ \t]+/, -1)
  [intro.to_s.strip, items.map { |item| markdown_lines(item).join(" ") }]
end

def markdown_image(line)
  match = line.match(/\A!\[[^\]]*\]\(([^)]+)\)\z/)
  CV_DIR.join(match[1]).cleanpath if match
end

def markdown_roles(sections)
  sections.map do |title, body|
    metadata, highlights = markdown_bullets(body)
    date, location = metadata.split(" · ", 2)
    { "title" => title, "date" => date.to_s, "location" => location.to_s, "highlights" => highlights }
  end
end

variant = ARGV.fetch(0, "professional")
variant = "professional" if variant == "computer"
abort "Usage: ruby render.rb [professional|education]" unless ARGV.size <= 1 && %w[professional education].include?(variant)

path = CV_DIR.join("#{variant}.md")
source = path.read(encoding: "UTF-8").gsub("\r\n", "\n")
header, sections = markdown_sections(source, "##")
heading, affiliation, *header_lines = markdown_lines(header)
abort "Expected a name heading and an affiliation in #{path}" unless heading&.start_with?("# ") && affiliation

name = heading.delete_prefix("# ")

if variant == "professional"
  abort "Expected seven sections in #{path}" unless sections.length == 7

  education_section, skills_section, publication_section, internship_section, project_section, recent_section, award_section = sections
  contacts = header_lines.join(" · ").split(" ⋄ ")
  education_entries = markdown_paragraphs(education_section.last)
  _, skills_sections = markdown_sections(skills_section.last, "###")
  skill_rows = skills_sections.flat_map do |title, body|
    description, bullets = markdown_bullets(body)
    rows = [description, *bullets].reject(&:empty?)
    rows.each_with_index.map { |row, index| [index.zero? ? title : "", row] }
  end
  publications = markdown_paragraphs(publication_section.last)
  experience_sections = [internship_section, project_section].map do |title, body|
    [title, markdown_roles(markdown_sections(body, "###").last)]
  end
  contributions = markdown_sections(recent_section.last, "###").last.map do |title, body|
    description, links = markdown_bullets(body)
    { "title" => title, "description" => description, "links" => links }
  end
  _, awards = markdown_bullets(award_section.last)

  experience_tex = render_template("experience", binding)
  content = render_template("professional", binding)
  print render_template("main", binding)
else
  abort "Expected three sections in #{path}" unless sections.length == 3

  education_section, gaokao_section, teaching_section = sections
  education_photo = header_lines.filter_map { |line| markdown_image(line) }.first
  education_contacts = header_lines.reject { |line| markdown_image(line) }
  columns = markdown_sections(education_section.last, "###").last.map do |title, body|
    lines = markdown_lines(body)
    logo = lines.filter_map { |line| markdown_image(line) }.first
    { "title" => title, "logo" => logo, "lines" => lines.reject { |line| markdown_image(line) } }
  end
  abort "Expected two education entries in #{path}" unless columns.length == 2

  undergraduate, graduate = columns
  gaokao_summary, gaokao_subjects = markdown_bullets(gaokao_section.last)
  gaokao_caption, total, gaokao_rank = markdown_lines(gaokao_summary)
  gaokao_total, gaokao_max = total.to_s.delete_prefix("**").delete_suffix("**").split("/", 2)
  abort "Expected a Gaokao total in score/max form in #{path}" unless gaokao_max

  teaching_summary, teaching_sections = markdown_sections(teaching_section.last, "###")
  teaching_entries = markdown_roles(teaching_sections)
  print render_template("education", binding)
end
