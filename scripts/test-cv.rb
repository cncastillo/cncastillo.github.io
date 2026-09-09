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

CV.generate
data = Content.load
names = data['profile']['author_names']
groups = {
  'publications' => data['publications'].select { |r| r['category'] == 'peer_reviewed' },
  'presentations' => data['presentations'],
  'books' => data['publications'].select { |r| r['category'] == 'book' }
}
groups.each do |name, records|
  output = File.read(File.join(CV::BUILD, "#{name}.tex"))
  check(output.scan(/\\cventry\{/).size == records.size, "Record count mismatch: #{name}")
  records.each { |r| check(output.include?(CV.byline(r['authors'], names)), "Missing full author list: #{r['title']}") }
  check(!output.include?('et al.'), "Truncated authors: #{name}")
end

puts 'CV generation checks passed.'
