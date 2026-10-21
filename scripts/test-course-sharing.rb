require 'bundler/setup'
require 'jekyll'

Dir.chdir(File.expand_path('..', __dir__))
site = Jekyll::Site.new(Jekyll.configuration('safe' => true, 'quiet' => true))
site.read
course = site.data.fetch('bios-214')
course['title'] = 'SHARED_TITLE_CHECK'
course['lecture_time'] = 'SHARED_TIME_CHECK'
course['classroom']['name'] = 'SHARED_ROOM_CHECK'
course['weeks'][0]['days'][0]['lecture'] = 'SHARED_SCHEDULE_CHECK'

pages = %w[teaching/bios-214/index.md teaching/bios-214/syllabus.md teaching/index.md]
documents = pages.map do |path|
  page = site.pages.find { |entry| entry.relative_path == path }
  html = Jekyll::Renderer.new(site, page).run
  raise "#{path}: shared title missing" unless html.include?('SHARED_TITLE_CHECK')
  html
end
website, syllabus = documents
%w[SHARED_TIME_CHECK SHARED_ROOM_CHECK SHARED_SCHEDULE_CHECK].each do |marker|
  [website, syllabus].each do |document|
    raise "Shared data edit did not propagate: #{marker}" unless document.include?(marker)
  end
end

def section_content(document, id)
  document.match(/<h2 id="#{id}">[^<]*<\/h2>([\s\S]*?)(?=<\/section>|<h2)/)[1].gsub(/\s+/, ' ').strip
end

%w[overview learning-goals].each do |id|
  raise "#{id} differs between outputs" unless section_content(website, id) == section_content(syllabus, id)
end
days = course['weeks'].flat_map { |week| week['days'] || [] }
missing_materials = days.sum { |day| %w[lecture_url lab_url].count { |key| day[key].to_s.strip.empty? } }
raise 'Keep placeholders for missing materials' unless website.scan('aria-disabled="true"').size == missing_materials
raise 'Keep all nine class days' unless website.scan('class="course-day-header"').size == 9
raise 'Keep the merged break row' unless website.include?('<td colspan="3" class="course-break">')

page = site.pages.find { |entry| entry.relative_path == 'teaching/bios-214/index.md' }
renderer = Jekyll::Renderer.new(site, page)
payload = site.site_payload
payload['page'] = page.to_liquid
day = days.first.dup
render_materials = lambda do
  payload['material_day'] = day
  renderer.render_liquid('{% include bios-214-schedule-day.md day=material_day materials=true %}', payload,
                         {registers: {site: site, page: payload['page']}}, page.path)
end
[nil, '', '  '].each do |blank|
  day.merge!('lecture_url' => blank, 'lab_url' => blank)
  raise 'Blank URLs must keep both placeholders' unless render_materials.call.scan('aria-disabled="true"').size == 2
end
day.merge!('lecture_url' => 'https://example.org/lecture.pdf?x=1&y=2', 'lab_url' => nil)
linked = render_materials.call
raise 'Lecture URL must be escaped and linked' unless linked.include?('href="https://example.org/lecture.pdf?x=1&amp;y=2"')
raise 'An unlinked lab must retain its placeholder' unless linked.scan('aria-disabled="true"').size == 1
day['lab_url'] = '/assets/teaching/lab.html'
linked = render_materials.call
raise 'Lab URL must support site paths' unless linked.include?('href="/assets/teaching/lab.html"')
raise 'Linked materials must replace the placeholders' unless linked.scan('>Materials</a>').size == 2 && !linked.include?('aria-disabled="true"')

puts 'Course sharing checks passed: shared edits reach both layouts; overview/goals match; schedule links remain.'
