require_relative 'check-content'
require 'fileutils'

module CV
  ROOT = File.expand_path('..', __dir__)
  BUILD = File.join(ROOT, '_cv', 'build')
  ESCAPES = {
    '\\' => '\textbackslash{}', '{' => '\{', '}' => '\}',
    '$' => '\$', '&' => '\&', '#' => '\#', '%' => '\%', '_' => '\_',
    '~' => '\textasciitilde{}', '^' => '\textasciicircum{}',
    'ℓ1' => '\ensuremath{\ell_1}', '‐' => '-', '‑' => '-',
    '–' => '--', '—' => '---'
  }.freeze

  def self.tex(value)
    value.to_s.gsub(/ℓ1|[\\{}$&#%_~^‐‑–—]/) { |character| ESCAPES.fetch(character) }
  end

  def self.byline(value, names)
    tex(value).gsub(Regexp.union(names.map { |name| tex(name) })) { |name| "\\textbf{#{name}}" }
  end

  def self.records(records)
    records.sort_by { |record| [-record.fetch('year'), record.fetch('order', Float::INFINITY)] }
  end

  def self.entry(record, names)
    presentation = record.key?('event')
    title = tex(record.fetch('title'))
    title = "{\\small [#{tex(record.fetch('kind'))}] #{title}}" if presentation
    venue = [record['venue'] || record.fetch('event'), record['location']].compact.join(' · ')
    details = "#{byline(record.fetch('authors'), names)}. \\emph{#{tex(venue)}}."
    details += " #{tex(record['type'])}." if record['category'] == 'book'
    details += " #{byline(record['note'], names)}" if record['note']
    url = record['paper'] || record['abstract']
    details += " \\href{#{tex(url)}}{#{presentation ? 'Abstract' : 'Paper'}}." if url
    year = record.fetch('year').to_s
    badge = record['cv_badge']
    year += "\\\\\\vspace{5bp}\\includegraphics[width=0.75cm]{#{badge}}" if badge
    "\\cventry{#{year}}{#{title}}{{\\normalfont\\footnotesize #{details}}}{}{}{}\n"
  end

  def self.generate
    data = Content.validate!(Content.load(ROOT), ROOT)
    publications = records(data['publications'])
    names = data['profile']['author_names']
    groups = {
      'publications' => publications.select { |record| record['category'] == 'peer_reviewed' },
      'presentations' => records(data['presentations'].reject { |record| ['Invited seminar', 'Invited research-group talk'].include?(record['kind']) }),
      'books' => publications.select { |record| record['category'] == 'book' }
    }
    FileUtils.mkdir_p(BUILD)
    groups.each do |name, records|
      File.write(File.join(BUILD, "#{name}.tex"), "% Generated from website records; do not edit.\n\n" + records.map { |record| entry(record, names) }.join("\n"))
      puts "#{name}: #{records.size} entries"
    end
    mentorship = records(data['mentorship'])
    File.write(File.join(BUILD, 'mentorship.tex'), "% Generated from website records; do not edit.\n\n" + mentorship.map { |record| mentorship_entry(record) }.join("\n"))
    puts "mentorship: #{mentorship.size} entries"
    grants = records(data['grants'])
    File.write(File.join(BUILD, 'grants.tex'), "% Generated from website records; do not edit.\n\n" + grants.map { |record| grant_entry(record) }.join("\n"))
    puts "grants: #{grants.size} entries"
  end

  def self.mentorship_entry(record)
    title = [record.fetch('name'), record['project']].compact.join(' — ')
    details = tex(record['role'])
    links = record.fetch('links', []).map { |link| "\\href{#{tex(link['url'])}}{#{tex(link['label'])}}" }
    details += " #{links.join(' · ')}" unless links.empty?
    "\\cventry{#{record.fetch('year')}}{#{tex(title)}}{#{tex(record.fetch('program'))}}{#{tex(record.fetch('organization'))}}{#{tex(record['location'])}}{#{details.strip}}\n"
  end

  def self.grant_entry(record)
    title = tex(record.fetch('title'))
    title = "\\href{#{tex(record['url'])}}{#{title}}" if record['url']
    details = [record.fetch('organization'), record['role']].compact.map { |value| tex(value) }.join(' · ')
    details += ". \\href{#{tex(record['blog'])}}{Blog post}" if record['blog']
    "\\cventry{#{record.fetch('year')}}{#{tex(record.fetch('program'))}}{#{tex(record.fetch('funder'))}}{}{#{tex(record['amount'])}}{#{title}. #{details}.}\n"
  end
end

CV.generate if $PROGRAM_NAME == __FILE__
