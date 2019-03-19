add_standard_info_tasks
add_standard_git_tasks
add_standard_buildr_plus_tasks

command(:standard_update) do |app|
  run(:braid_update_all, app)
  run(:normalize_all, app)
  run(:clean_whitespace, app)
end

braid_tasks('way_of_stock' => 'vendor/docs/way_of_stock',
            'dbt' => 'vendor/tools/dbt',
            'buildr_plus' => 'vendor/tools/buildr_plus',
            'redfish' => 'vendor/tools/redfish',
            'zim' => 'vendor/tools/zim',
            'backpack' => 'vendor/tools/backpack',
            'noft' => 'vendor/tools/noft',
            'domgen' => 'vendor/tools/domgen',
            'resgen' => 'vendor/tools/resgen',
            'kinjen' => 'vendor/tools/kinjen',
            'rptman' => 'vendor/tools/rptman')

ruby_upgrade('2.1.3', '2.3.1')

patch_gem('buildr', %w(1.5.4 1.5.5 1.5.6), '1.5.7')
patch_gem('braid', %w(1.0.18 1.0.19 1.0.20 1.0.21 1.0.22 1.0.3 1.1.0), '1.1.0')
patch_gem('zapwhite', %w(2.9.0 2.10.0 2.11.0), '2.12.0')
patch_gem('mcrt', %w(1.9.0 1.10.0 1.11.0 1.12.0), '1.13.0')

command(:upgrade_braid) do |app|
  run(:patch_braid_gem, app)
  run(:braid_update_config, app)
end

command(:patch_idea_codestyle_version) do |app|
  patch_versions(app, %w(au.com.stocksoftware.idea.codestyle:idea-codestyle:xml), '1.13')
end

command(:patch_braincheck_version) do |app|
  patch_versions(app, %w(org.realityforge.braincheck:braincheck:jar), '1.13.0')
end

command(:patch_gwt_version) do |app|
  patch_versions(app, %w(com.google.gwt:gwt-user:jar com.google.gwt:gwt-dev:jar com.google.gwt:gwt-servlet:jar), '2.8.2')
end

command(:patch_arez_spytools_version) do |app|
  patch_versions(app, %w(org.realityforge.arez.spytools:arez-spytools:jar), '0.56')
end

command(:patch_jsinterop_version) do |app|
  patch_versions(app, %w(com.google.jsinterop:jsinterop-annotations:jar), '1.0.2')
end

command(:patch_guiceyloops_version) do |app|
  patch_versions(app, %w(org.realityforge.guiceyloops:guiceyloops:jar), '0.98')
end

desc 'Move to org.realityforge variants of jsinterop-base and upgrade version'
command(:upgrade_jsinterop_base) do |app|
  version = '1.0.0-b2-e6d791f'
  patch_dependency_coordinates(app, { 'com.google.jsinterop:base:jar' => 'org.realityforge.com.google.jsinterop:base:jar' }, version)
  patch_versions(app, %w(org.realityforge.com.google.jsinterop:base:jar), version)
end

desc 'Move to org.realityforge variants of elemental and upgrade version'
command(:upgrade_elemental2) do |app|
  patch_versions(app, %w(
    org.realityforge.com.google.elemental2:elemental2-core:jar
    org.realityforge.com.google.elemental2:elemental2-dom:jar
    org.realityforge.com.google.elemental2:elemental2-promise:jar
    org.realityforge.com.google.elemental2:elemental2-media:jar
    org.realityforge.com.google.elemental2:elemental2-indexeddb:jar
    org.realityforge.com.google.elemental2:elemental2-svg:jar
    org.realityforge.com.google.elemental2:elemental2-webgl:jar
    org.realityforge.com.google.elemental2:elemental2-webstorage:jar
    org.realityforge.com.google.elemental2:elemental2-webassembly:jar
  ), '1.0.0-b20-bfe6e22')
end

command(:upgrade_arez) do |app|
  patch_versions(app, %w(
    org.realityforge.arez:arez-core:jar
    org.realityforge.arez:arez-processor:jar
    org.realityforge.arez:arez-gwt-output-qa:jar
  ), '0.133')
end

command(:fix_tags) do |app|
  bad_tags = `git tag | grep -v -- v`.strip.split("\n").select {|t| t =~ /^[0-9\.]+$/}
  if !bad_tags.empty? && !(app =~ /^chef-.*/) && app != 'knife-cookbook-doc'
    puts "#{app}: Contains #{bad_tags.size} malformed tags: #{bad_tags.inspect}"
    if true
      bad_tags.each do |tag|
        mysystem("git checkout #{tag}")
        mysystem("git tag -f v#{tag}")
        mysystem("git checkout v#{tag}")
        mysystem("git tag -d #{tag}")
        mysystem("git push origin :#{tag}")
      end
      mysystem('git push --tags')
    end
  end
end

command(:update_contributing) do |app|
  if File.exist?('CONTRIBUTING.md')
    FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/tmp/CONTRIBUTING.md", 'CONTRIBUTING.md'
    begin
      mysystem('git add CONTRIBUTING.md')
      mysystem("git commit -m \"Improve the notes on contributing.\"")
    rescue Exception
      # ignored
    end
  end
end

Zim::Belt.load_suites_from_belt
