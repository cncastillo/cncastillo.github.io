require 'bundler/setup'
require 'jekyll'
require 'yaml'

Dir.chdir(File.expand_path('..', __dir__))
site = Jekyll::Site.new(Jekyll.configuration('safe' => true, 'quiet' => true))
site.read
page = site.pages.find { |entry| entry.relative_path == 'teaching/bios-214/syllabus.md' }
course = site.data.fetch(page.data.fetch('course_data'))
metadata = course.slice('title', 'subtitle', 'code', 'term', 'institution', 'institution_logo')
metadata['title'] = "#{course.fetch('code')}: #{course.fetch('title')}"
metadata['revision-date'] = course.fetch('last_updated')
payload = site.site_payload
payload['page'] = page.to_liquid
body = Jekyll::Renderer.new(site, page).render_liquid(page.content, payload, {registers: {site: site, page: payload['page']}}, page.path)

puts YAML.dump(metadata)
puts '---'
puts body
