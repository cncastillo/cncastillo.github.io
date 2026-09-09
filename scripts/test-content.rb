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
sample['projects'] = {}
Content.validate!(sample)

rejects(sample, 'duplicate record_key') { |d| d['publications'] << fixture.dup }
rejects(sample, 'authors must be nonempty text') { |d| d['publications'][0].delete('authors') }
rejects(sample, 'complete author list') { |d| d['publications'][0]['authors'] = 'Alex Researcher et al.' }
rejects(sample, 'category must be one of') { |d| d['publications'][0]['category'] = 'peer_reveiwed' }
rejects(sample, 'year must be an integer') { |d| d['publications'][0]['year'] = '2027' }
rejects(sample, 'order must be an integer') { |d| d['publications'][0]['order'] = 'first' }
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
