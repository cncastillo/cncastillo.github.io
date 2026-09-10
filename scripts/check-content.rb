require 'yaml'
require 'date'

module Content
  ROOT = File.expand_path('..', __dir__)

  def self.yaml(path)
    YAML.safe_load(File.read(path))
  rescue Psych::Exception => error
    raise ArgumentError, "#{path}: #{error.message}"
  end

  def self.load(root = ROOT)
    data = %w[profile publications presentations mentorship grants].to_h { |name| [name, yaml(File.join(root, '_data', "#{name}.yml"))] }
    data['projects'] = Dir[File.join(root, '_highlights', '*.md')].to_h do |path|
      [path, YAML.safe_load(File.read(path).split(/^---\s*$\n/, 3).fetch(1))]
    end
    data
  end

  def self.check(condition, where, message)
    raise ArgumentError, "#{where}: #{message}" unless condition
  end

  def self.fields(record, names, where)
    check(record.is_a?(Hash), where, 'expected a record with named fields')
    names.each { |name| check(record[name].is_a?(String) && !record[name].strip.empty?, where, "#{name} must be nonempty text") }
  end

  def self.asset(path, root, where)
    check(path.is_a?(String) && path.start_with?('/assets/') && File.file?(File.join(root, path)), where, "missing asset: #{path.inspect}")
  end

  def self.validate!(data, root = ROOT)
    profile = data.fetch('profile')
    fields(profile, %w[name role institution email description photo photo_alt favicon], '_data/profile.yml')
    %w[bio author_names].each do |key|
      value = profile[key]
      check(value.is_a?(Array) && !value.empty? && value.all? { |v| v.is_a?(String) && !v.strip.empty? }, '_data/profile.yml', "#{key} must be a nonempty list of text")
    end
    %w[photo favicon].each { |key| asset(profile[key], root, '_data/profile.yml') }

    mentorship = data.fetch('mentorship')
    check(mentorship.is_a?(Array), '_data/mentorship.yml', 'expected a list; use [] for an empty list')
    mentorship.each_with_index do |record, i|
      where = "_data/mentorship.yml entry #{i + 1}"
      fields(record, %w[name program organization], where)
      check(record['year'].is_a?(Integer), where, 'year must be an integer')
      check(!record.key?('order') || record['order'].is_a?(Integer), where, 'order must be an integer or omitted')
      %w[project location role home_affiliation].each { |key| fields(record, [key], where) if record.key?(key) }
      %w[program_logo organization_logo].each { |key| asset(record[key], root, where) if record.key?(key) }
      if record.key?('links')
        check(record['links'].is_a?(Array), where, 'links must be a list')
        record['links'].each do |link|
          fields(link, %w[label url], where)
          check(link['url'].match?(/\Ahttps?:\/\/\S+\z/), where, 'url must be an HTTP(S) link')
        end
      end
    end

    ids = {}
    grants = data.fetch('grants')
    check(grants.is_a?(Array), '_data/grants.yml', 'expected a list; use [] for an empty list')
    grants.each_with_index do |record, i|
      where = "_data/grants.yml entry #{i + 1}"
      fields(record, %w[record_key title funder program organization], where)
      check(!ids.key?(record['record_key']), where, 'duplicate record_key')
      ids[record['record_key']] = 'grants'
      check(record['year'].is_a?(Integer), where, 'year must be an integer')
      check(!record.key?('order') || record['order'].is_a?(Integer), where, 'order must be an integer or omitted')
      %w[amount role url blog].each { |key| fields(record, [key], where) if record.key?(key) }
      %w[url blog].each do |key|
        check(!record[key] || record[key].match?(/\Ahttps?:\/\/\S+\z/), where, "#{key} must be an HTTP(S) link")
      end
      if record.key?('date')
        date = record['date']
        valid = date.is_a?(String) && date.match?(/\A\d{4}-\d{2}-\d{2}\z/) && Date.valid_date?(*date.split('-').map(&:to_i))
        check(valid, where, 'date must be a quoted ISO date (YYYY-MM-DD)')
        check(Date.iso8601(date).year == record['year'], where, 'date year must match year')
        fields(record, %w[date_source], where)
      end
    end

    %w[publications presentations].each do |collection|
      records = data.fetch(collection)
      check(records.is_a?(Array), "_data/#{collection}.yml", 'expected a list; use [] for an empty list')
      records.each_with_index do |record, i|
        where = "_data/#{collection}.yml entry #{i + 1}"
        fields(record, %w[record_key category title authors], where)
        where += " (#{record['record_key']})"
        categories = collection == 'publications' ? %w[peer_reviewed book] : %w[abstract conference invited]
        check(categories.include?(record['category']), where, "category must be one of: #{categories.join(', ')}")
        fields(record, collection == 'publications' ? %w[type venue] : %w[kind event], where)
        check(record['year'].is_a?(Integer), where, 'year must be an integer')
        check(!record.key?('order') || record['order'].is_a?(Integer), where, 'order must be an integer or omitted')
        dates = %w[date event_start event_end].to_h do |key|
          next [key, nil] unless record.key?(key)
          value = record[key]
          valid = value.is_a?(String) && value.match?(/\A\d{4}-\d{2}-\d{2}\z/) && Date.valid_date?(*value.split('-').map(&:to_i))
          check(valid, where, "#{key} must be a quoted ISO date (YYYY-MM-DD)")
          [key, Date.iso8601(value)]
        end
        if dates.values.any?
          fields(record, %w[date_source], where)
          date_year = (dates['date'] || dates['event_start'] || dates['event_end']).year
          if collection == 'publications'
            check(date_year <= record['year'], where, 'publication date must not follow citation year')
          else
            check(date_year == record['year'], where, 'date year must match year')
          end
          check(dates['event_start'].nil? == dates['event_end'].nil?, where, 'event_start and event_end must be supplied together')
          if dates['event_start']
            check(dates['event_start'] <= dates['event_end'], where, 'event_end must not precede event_start')
            check(!dates['date'] || (dates['event_start']..dates['event_end']).cover?(dates['date']), where, 'date must fall within the event range')
          end
        end
        check(!record['authors'].match?(/\bet al\.?/i), where, 'include the complete author list, not et al.')
        check(!ids.key?(record['record_key']), where, 'duplicate record_key')
        ids[record['record_key']] = collection
        %w[paper abstract code slides].each { |key| fields(record, [key], where) if record.key?(key) }
        if record.key?('image')
          fields(record, %w[image image_alt], where)
          asset(record['image'], root, where)
        end
        if record.key?('recognitions')
          check(record['recognitions'].is_a?(Array), where, 'recognitions must be a list')
          record['recognitions'].each do |award|
            fields(award, %w[label], where)
            check(!award.key?('year') || award['year'].is_a?(Integer), where, 'recognition year must be an integer or omitted')
          end
        end
        if record['cv_badge']
          badge = record['cv_badge']
          check(badge.is_a?(String) && File.basename(badge) == badge && File.file?(File.join(root, '_cv/assets', badge)), where, 'cv_badge must name a file in _cv/assets/')
        end
      end
    end

    (data['publications'] + data['presentations']).each do |record|
      {'publication_key' => 'publications', 'abstract_key' => 'presentations'}.each do |key, collection|
        check(ids[record[key]] == collection, record['record_key'], "unresolved #{key}: #{record[key]}") if record.key?(key)
      end
    end
    data.fetch('projects').each do |path, project|
      fields(project, %w[title area summary image image_alt], path)
      asset(project['image'], root, path)
      relations = project.fetch('related_outputs', [])
      check(relations.is_a?(Array), path, 'related_outputs must be a list')
      seen = []
      relations.each do |relation|
        fields(relation, %w[kind key], path)
        collection = {'publication' => 'publications', 'presentation' => 'presentations'}[relation['kind']]
        check(collection && ids[relation['key']] == collection, path, "unresolved project reference: #{relation['kind']} / #{relation['key']}")
        check(!seen.include?(relation['key']), path, "duplicate project reference: #{relation['key']}")
        seen << relation['key']
      end
    end
    data
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    data = Content.validate!(Content.load)
    puts "Content valid: #{data['publications'].size} publications/book chapters, #{data['presentations'].size} presentations, #{data['projects'].size} projects, #{data['mentorship'].size} mentorship entries, #{data['grants'].size} grants."
  rescue ArgumentError, KeyError => error
    abort error.message
  end
end
