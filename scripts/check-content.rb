require 'yaml'

module Content
  ROOT = File.expand_path('..', __dir__)

  def self.yaml(path)
    YAML.safe_load(File.read(path))
  rescue Psych::Exception => error
    raise ArgumentError, "#{path}: #{error.message}"
  end

  def self.load(root = ROOT)
    data = %w[profile publications presentations].to_h { |name| [name, yaml(File.join(root, '_data', "#{name}.yml"))] }
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

    ids = {}
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
    puts "Content valid: #{data['publications'].size} publications/book chapters, #{data['presentations'].size} presentations, #{data['projects'].size} projects."
  rescue ArgumentError, KeyError => error
    abort error.message
  end
end
