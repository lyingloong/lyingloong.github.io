require "cgi"
require "date"
require "erb"
require "pathname"
require "yaml"

ROOT = Pathname.new(__dir__).parent
TEX_ESCAPES = {
  "\\" => '\\textbackslash{}',
  "{" => '\\{',
  "}" => '\\}',
  "$" => '\\$',
  "&" => '\\&',
  "#" => '\\#',
  "_" => '\\_',
  "%" => '\\%',
  "~" => '\\textasciitilde{}',
  "^" => '\\textasciicircum{}'
}.freeze

def read_yaml(path, source = path.read(encoding: "UTF-8"))
  YAML.safe_load(source, permitted_classes: [Date, Time], aliases: true, filename: path.to_s)
end

def collection(name)
  ROOT.glob("_#{name}/**/*.{md,markdown}").filter_map do |path|
    front_matter = path.read(encoding: "UTF-8")[/\A---\r?\n(.*?)^---[ \t]*\r?$/m, 1]
    next unless front_matter

    item = read_yaml(path, front_matter)
    next if item.fetch("published", true) == false

    item.merge("id" => path.basename(path.extname).to_s)
  end.sort_by { |item| [item.fetch("date").to_s, item.fetch("id")] }.reverse
end

def tex(value)
  value.to_s.gsub(/[\\{}$&\#_%~^]/, TEX_ESCAPES)
end

def text(html)
  CGI.unescapeHTML(html.to_s.gsub(/<br\s*\/?>/i, " ").gsub(/<[^>]+>/, ""))
end

def link(label, url)
  address = url.to_s.gsub(/[\\{}%#]/) { |character| "\\#{character}" }
  "\\href{#{address}}{#{tex(label)}}"
end

def links(items)
  items.map do |label, url|
    link(label, url.is_a?(Hash) ? url.fetch("url") : url)
  end.join(' \\enspace ')
end

def year(date)
  date.respond_to?(:year) ? date.year : Date.parse(date.to_s).year
end

def cv_date(value, variant)
  return value unless variant == "education"

  value.to_s
       .sub(/\bPresent\z/, "今")
       .gsub(/\b([A-Z][a-z]+)\.?\s+(\d{4})\b/) do |part|
         month = Date::ABBR_MONTHNAMES.index(Regexp.last_match(1)[0, 3])
         month ? "#{Regexp.last_match(2)} 年 #{month} 月" : part
       end
       .gsub(/\s+[–—-]\s+/, "至")
end

def experience_entry(entry)
  details = entry.fetch("cv", {})
  {
    "title" => details.fetch("title") { entry.fetch("name") },
    "date" => entry.fetch("date"),
    "location" => details.fetch("location", ""),
    "highlights" => details.fetch("highlights") { [text(entry.fetch("position"))] }
  }
end

def render_template(name, context)
  template = ROOT.join("cv/#{name}.tex.erb")
  renderer = ERB.new(template.read(encoding: "UTF-8"), trim_mode: "-")
  renderer.filename = template.to_s
  renderer.result(context)
end

variant = ARGV.fetch(0, "professional")
variant = "professional" if variant == "computer"
abort "Usage: ruby render.rb [professional|education]" unless ARGV.size <= 1 && %w[professional education].include?(variant)

profile = read_yaml(ROOT.join("_data/profile.yml"))
cv = read_yaml(ROOT.join("_data/cv.yml"))
graduate = profile.fetch("graduate_study")
visible_experience = profile.fetch("experience").reverse.reject { |entry| entry.dig("cv", "show") == false }
experience, teaching = visible_experience.partition do |entry|
  entry.dig("cv", "section") != "teaching"
end

if variant == "professional"
  research = profile.fetch("research")
  experience_sections = { "Internship/Trainings" => experience.map { |entry| experience_entry(entry) } }
  publications = collection("publications")
  projects = collection("projects").select { |item| item["show"] && item["selected"] }

  honor_labels = cv.fetch("honors")
  honors = collection("honors").group_by { |item| item.fetch("title") }.map do |title, entries|
    details = entries.filter_map { |entry| honor_labels[entry.fetch("id")] }.first || {}
    years = entries.map { |entry| year(entry.fetch("date")) }.uniq.sort.join("、")
    school_years = details["school_years"]
    {
      "title" => details.fetch("title", title),
      "date" => school_years ? "#{years} 获奖，#{school_years} 学年" : years
    }
  end
  honors.concat(cv.fetch("additional_honors"))

  experience_tex = render_template("experience", binding)
  content = render_template(variant, binding)
  print render_template("main", binding)
else
  education_details = read_yaml(ROOT.join("cv/education.yml"))
  gaokao = education_details.fetch("gaokao", {})
  education_emails = [profile.fetch("email"), *education_details.fetch("additional_emails", [])]
  education_photo = ROOT.join(education_details.fetch("photo"))
  teaching_entries = (teaching + education_details.fetch("teaching", [])).map { |entry| experience_entry(entry) }
  teaching_entries.concat(education_details.fetch("tutoring", []))
  print render_template("education", binding)
end
