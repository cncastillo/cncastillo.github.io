require_relative 'generate-cv'

def check(condition, message)
  raise message unless condition
end

check(CV.tex('A&B_50% #1 $ {x} ~ ^ \input{bad}') == 'A\&B\_50\% \#1 \$ \{x\} \textasciitilde{} \textasciicircum{} \textbackslash{}input\{bad\}', 'TeX escaping failed')
check(CV.tex('ℓ1‐regularized – test') == '\ensuremath{\ell_1}-regularized -- test', 'Unicode conversion failed')
names = ['Alex Researcher', 'A. Researcher']
names.each do |name|
  check(CV.byline(name, names) == "\\textbf{#{name}}", "Missing emphasis: #{name}")
end
check(CV.byline('Another Author', names) == 'Another Author', 'Incorrect author emphasis')

fixture = {
  'year' => 2027, 'title' => 'Example: MRI & computing', 'category' => 'peer_reviewed',
  'type' => 'Journal article', 'authors' => 'Another Author and Alex Researcher',
  'venue' => 'Example Journal', 'paper' => 'https://doi.org/example', 'record_key' => 'example'
}
entry = CV.entry(fixture, names)
check(entry.include?('Another Author and \textbf{Alex Researcher}'), 'Author order changed')
check(entry.include?('https://doi.org/example'), 'Missing paper URL')
book = fixture.merge('category' => 'book', 'type' => 'Book chapter · In press')
check(CV.entry(book, names).include?('Book chapter · In press'), 'Book status missing')
talk = fixture.reject { |key, _| %w[venue paper type].include?(key) }.merge('category' => 'conference', 'kind' => 'Conference talk', 'event' => 'Example Conference')
check(CV.entry(talk, names).include?('[Conference talk]'), 'Talk classification changed')
ordered = CV.records([fixture, fixture.merge('year' => 2028), fixture.merge('order' => 1000)])
check(ordered.map { |r| [r['year'], r['order']] } == [[2028, nil], [2027, 1000], [2027, nil]], 'Date/tie-break ordering failed')

mentorship = {'name' => 'Example Student', 'year' => 2027, 'program' => 'SURF', 'organization' => 'Example University'}
check(CV.mentorship_entry(mentorship) == "\\cventry{2027}{Example Student}{SURF}{Example University}{}{}\n", 'Mentorship without optional details failed')
mentorship.merge!('project' => 'MRI & computing', 'role' => 'Co-mentor', 'links' => [
  {'label' => 'Project', 'url' => 'https://example.org/project_a'},
  {'label' => 'Blog & tutorial', 'url' => 'https://example.org/post'}
])
mentorship_entry = CV.mentorship_entry(mentorship)
check(mentorship_entry.include?('Example Student --- MRI \\& computing'), 'Mentorship title escaping failed')
check(mentorship_entry.include?('Co-mentor \\href{https://example.org/project\\_a}{Project}'), 'Mentorship role/link missing')
check(mentorship_entry.include?(' · \\href{https://example.org/post}{Blog \\& tutorial}'), 'Mentorship additional link/label escaping failed')

grant = {'year' => 2027, 'title' => 'MRI & computing', 'program' => 'Development Grant', 'funder' => 'Example Foundation', 'organization' => 'Example Project'}
check(CV.grant_entry(grant).include?('{MRI \\& computing. Example Project.}'), 'Grant escaping or optional fields failed')
grant.merge!('amount' => 'USD 10,000', 'role' => 'Co-project lead', 'url' => 'https://example.org/grant_1')
grant_entry = CV.grant_entry(grant)
check(grant_entry.include?('{USD 10,000}'), 'Grant amount missing')
check(grant_entry.include?('\\href{https://example.org/grant\\_1}{MRI \\& computing}'), 'Grant link escaping failed')
check(grant_entry.include?('Example Project · Co-project lead.'), 'Grant role missing')
grant['blog'] = 'https://example.org/blog_post'
check(CV.grant_entry(grant).include?('\\href{https://example.org/blog\\_post}{Blog post}'), 'Grant blog link missing or unescaped')

CV.generate
data = Content.load
names = data['profile']['author_names']
seminars = data['presentations'].select { |r| ['Invited seminar', 'Invited research-group talk'].include?(r['kind']) }
groups = {
  'publications' => data['publications'].select { |r| r['category'] == 'peer_reviewed' },
  'presentations' => data['presentations'] - seminars,
  'books' => data['publications'].select { |r| r['category'] == 'book' }
}
groups.each do |name, records|
  output = File.read(File.join(CV::BUILD, "#{name}.tex"))
  check(output.scan(/\\cventry\{/).size == records.size, "Record count mismatch: #{name}")
  records.each { |r| check(output.include?(CV.byline(r['authors'], names)), "Missing full author list: #{r['title']}") }
  records.each { |r| check(output.include?(CV.entry(r, names)), "Missing CV entry: #{r['title']}") }
  check(!output.include?('et al.'), "Truncated authors: #{name}")
end

presentations_output = File.read(File.join(CV::BUILD, 'presentations.tex'))
seminars.each do |record|
  check(!presentations_output.include?(CV.entry(record, names)), "Non-conference talk in CV conference list: #{record['event']}")
end

mentorship_output = File.read(File.join(CV::BUILD, 'mentorship.tex'))
check(mentorship_output.scan(/\\cventry\{/).size == data['mentorship'].size, 'Mentorship count mismatch')
data['mentorship'].each do |record|
  check(mentorship_output.include?(CV.mentorship_entry(record)), "Missing mentorship: #{record['name']}")
end
check(File.read(File.join(CV::ROOT, '_cv/cv.tex')).include?('\\input{build/mentorship.tex}'), 'CV does not use generated mentorship entries')

grants_output = File.read(File.join(CV::BUILD, 'grants.tex'))
check(grants_output.scan(/\\cventry\{/).size == data['grants'].size, 'Grant count mismatch')
data['grants'].each do |record|
  check(grants_output.include?(CV.grant_entry(record)), "Missing grant: #{record['title']}")
end
check(File.read(File.join(CV::ROOT, '_cv/cv.tex')).include?('\\input{build/grants}'), 'CV does not use generated grant entries')

puts 'CV generation checks passed.'
