require_relative 'check-content'

original = Content.load
Content.validate!(original)

def rejects(original, expected)
  data = Marshal.load(Marshal.dump(original))
  yield data
  begin
    Content.validate!(data)
  rescue ArgumentError => error
    raise "Wrong error: #{error.message}" unless error.message.include?(expected)
    return
  end
  raise "Expected validation failure: #{expected}"
end

fixture = {'record_key' => 'example', 'year' => 2027, 'category' => 'peer_reviewed',
           'type' => 'Journal article', 'title' => 'Example paper',
           'authors' => 'Alex Researcher and Another Author', 'venue' => 'Example Journal'}
sample = Marshal.load(Marshal.dump(original))
sample['profile']['name'] = 'Alex Researcher'
sample['profile']['author_names'] = ['Alex Researcher']
sample['publications'] = [fixture]
sample['presentations'] = []
sample['mentorship'] = []
sample['projects'] = {}
Content.validate!(sample)

mentorship = Marshal.load(Marshal.dump(sample))
mentorship['mentorship'] = [{'name' => 'Example Student', 'year' => 2027, 'program' => 'SURF', 'organization' => 'Example University'}]
Content.validate!(mentorship)
rejects(mentorship, 'name must be nonempty text') { |d| d['mentorship'][0].delete('name') }
rejects(mentorship, 'year must be an integer') { |d| d['mentorship'][0]['year'] = '2027' }
mentorship['mentorship'][0]['home_affiliation'] = 'Home University, Country'
Content.validate!(mentorship)
rejects(mentorship, 'home_affiliation must be nonempty text') { |d| d['mentorship'][0]['home_affiliation'] = '' }
rejects(mentorship, 'home_affiliation must be nonempty text') { |d| d['mentorship'][0]['home_affiliation'] = [] }
mentorship['mentorship'][0]['organization_logo'] = '/assets/icons/stanford.svg'
Content.validate!(mentorship)
%w[program_logo organization_logo].each do |key|
  rejects(mentorship, 'missing asset') { |d| d['mentorship'][0][key] = '/assets/icons/missing-logo.svg' }
end
rejects(mentorship, 'expected a list') { |d| d['mentorship'] = {} }
mentorship['mentorship'][0]['links'] = [{'label' => 'Blog post', 'url' => 'https://example.org/post'}]
Content.validate!(mentorship)
rejects(mentorship, 'links must be a list') { |d| d['mentorship'][0]['links'] = 'https://example.org/post' }
rejects(mentorship, 'label must be nonempty text') { |d| d['mentorship'][0]['links'][0].delete('label') }
rejects(mentorship, 'url must be an HTTP(S) link') { |d| d['mentorship'][0]['links'][0]['url'] = 'javascript:alert(1)' }

rejects(sample, 'duplicate record_key') { |d| d['publications'] << fixture.dup }
rejects(sample, 'authors must be nonempty text') { |d| d['publications'][0].delete('authors') }
rejects(sample, 'complete author list') { |d| d['publications'][0]['authors'] = 'Alex Researcher et al.' }
rejects(sample, 'category must be one of') { |d| d['publications'][0]['category'] = 'peer_reveiwed' }
rejects(sample, 'year must be an integer') { |d| d['publications'][0]['year'] = '2027' }
rejects(sample, 'order must be an integer') { |d| d['publications'][0]['order'] = 'first' }
dated = Marshal.load(Marshal.dump(sample))
dated['publications'][0].merge!('date' => '2027-05-12', 'date_source' => 'https://publisher.example/paper')
Content.validate!(dated)
rejects(dated, 'quoted ISO date') { |d| d['publications'][0]['date'] = '2027-02-29' }
rejects(dated, 'quoted ISO date') { |d| d['publications'][0]['date'] = '2027-5-12' }
rejects(dated, 'date_source must be nonempty text') { |d| d['publications'][0].delete('date_source') }
rejects(dated, 'publication date must not follow citation year') { |d| d['publications'][0]['date'] = '2028-05-12' }
dated['publications'][0]['date'] = '2026-05-12'
Content.validate!(dated)
dated['publications'][0]['date'] = '2027-05-12'
dated['publications'][0].merge!('event_start' => '2027-05-10', 'event_end' => '2027-05-14')
Content.validate!(dated)
rejects(dated, 'supplied together') { |d| d['publications'][0].delete('event_end') }
rejects(dated, 'must not precede') { |d| d['publications'][0]['event_end'] = '2027-05-09' }
rejects(dated, 'date must fall within') { |d| d['publications'][0]['date'] = '2027-05-15' }
dated['publications'][0].delete('date')
Content.validate!(dated)
talk = Marshal.load(Marshal.dump(sample))
talk['presentations'] = [{'record_key' => 'example-talk', 'year' => 2027, 'category' => 'conference',
                          'kind' => 'Conference talk', 'title' => 'Example talk', 'authors' => 'Alex Researcher',
                          'event' => 'Example Conference 2027', 'date' => '2027-05-12', 'date_source' => 'Speaker confirmation'}]
Content.validate!(talk)
rejects(talk, 'date year must match year') { |d| d['presentations'][0]['date'] = '2026-05-12' }
rejects(sample, 'unresolved abstract_key') { |d| d['publications'][0]['abstract_key'] = 'missing' }
rejects(sample, 'recognitions must be a list') { |d| d['publications'][0]['recognitions'] = 'An award' }
rejects(sample, 'missing asset') { |d| d['profile']['photo'] = '/assets/missing-test-image.png' }
rejects(sample, 'author_names must be a nonempty list') { |d| d['profile']['author_names'] = [] }

project = {'title' => 'Example project', 'area' => 'Computing', 'summary' => 'Example',
           'image' => sample['profile']['photo'], 'image_alt' => 'Example image',
           'related_outputs' => [{'kind' => 'publication', 'key' => 'example'}]}
sample['projects']['example.md'] = project
Content.validate!(sample)
rejects(sample, 'unresolved project reference') { |d| d['projects']['example.md']['related_outputs'][0]['key'] = 'typo' }
rejects(sample, 'unresolved project reference') { |d| d['projects']['example.md']['related_outputs'][0]['kind'] = 'presentation' }
rejects(sample, 'duplicate project reference') { |d| d['projects']['example.md']['related_outputs'] *= 2 }

puts 'Content checks passed, including replacement-profile and invalid-record tests.'
