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

patch_gem('buildr', %w(1.5.4 1.5.5), '1.5.6')
patch_gem('braid', %w(1.0.18 1.0.19 1.0.20 1.0.21 1.0.22 1.0.3 1.1.0), '1.1.0')
patch_gem('zapwhite', %w(2.9.0), '2.10.0')
patch_gem('mcrt', %w(1.9.0 1.10.0 1.11.0), '1.12.0')

command(:upgrade_braid) do |app|
  run(:patch_braid_gem, app)
  run(:braid_update_config, app)
end

command(:patch_idea_codestyle_version) do |app|
  patch_versions(app, %w(au.com.stocksoftware.idea.codestyle:idea-codestyle:xml), '1.13')
end

command(:patch_javax_annotations_version) do |app|
  patch_dependency_coordinates(app,
                               { 'com.google.code.findbugs:jsr305:jar' => 'org.realityforge.javax.annotation:javax.annotation:jar' },
                               '1.0.0')

  if File.exist?('buildfile') && File.exist?('build.yaml')
    patched =
      patch_file('build.yaml') {|content| content.gsub('javax_jsr305', 'javax_annotation')} ||
        patch_file('buildfile') {|content| content.gsub('javax_jsr305', 'javax_annotation')}
    mysystem("git commit -m \"Update the dependency key from javax_jsr305 to javax_annotation to more accurately reflect dependency.\"") if patched
  end
end

command(:change_travis_ci_badges_to_svg) do |app|
  if File.exist?('README.md')
    patched =
      patch_file('README.md') {|content| content.gsub(/https:\/\/secure\.travis-ci\.org\/(.+)\.png\?branch=/, "https://secure.travis-ci.org/\\1.svg?branch=")}
    mysystem("git commit -m \"Change the TravisCI build badge to svg for improved readability ✨.\"") if patched
  end
end

command(:use_https_to_fetch_metadata) do |app|
  if File.exist?('Gemfile')
    patched =
      patch_file('Gemfile') {|content| content.gsub(/http:\/\/rubygems.org/, "https://rubygems.org")}
    mysystem("git commit -m \"Update the Gemfile to use HTTPS to fetch its metadata\"") if patched
  end
end

command(:remove_sudo_from_travis) do |app|
  if File.exist?('.travis.yml')
    patched = patch_file('.travis.yml') do |content|
      content.
        gsub(/\n *sudo: false\n/m, "\n").
        gsub(/\n *sudo: true\n/m, "\n")
    end
    mysystem("git commit -m \"Remove unrecognized sudo configuration section\"") if patched
  end
end

command(:remove_deprecated_gem_config) do |app|
  puts Dir['*.gemspec']
  Dir['*.gemspec'].each do |filename|
    patched =
      patch_file(filename) {|content| content.gsub(/\n *spec\.has_rdoc *=[^\n]*\n/m, "\n").gsub(/\n *s\.has_rdoc *=[^\n]*\n/m, "\n")}
    mysystem("git commit -m \"Remove deprecated gem method\"") if patched
  end
end

command(:patch_braincheck_version) do |app|
  patch_versions(app, %w(org.realityforge.braincheck:braincheck:jar), '1.9.0')
end

command(:patch_gwt_version) do |app|
  patch_versions(app, %w(com.google.gwt:gwt-user:jar com.google.gwt:gwt-dev:jar com.google.gwt:gwt-servlet:jar), '2.8.2')
end

command(:patch_jsinterop_version) do |app|
  patch_versions(app, %w(com.google.jsinterop:jsinterop-annotations:jar), '1.0.2')
end

command(:patch_guiceyloops_version) do |app|
  patch_versions(app, %w(org.realityforge.guiceyloops:guiceyloops:jar), '0.96')
end

command(:patch_jsinterop_base_version) do |app|
  patch_versions(app, %w(com.google.jsinterop:base:jar com.google.jsinterop:base:jar:sources), '1.0.0-RC1')
end

command(:patch_elemental2_version) do |app|
  patch_versions(app, %w(com.google.elemental2:elemental2-core:jar com.google.elemental2:elemental2-dom:jar com.google.elemental2:elemental2-promise:jar), '1.0.0-RC1')
end

command(:remove_travis_java) do |app|
  patched = patch_file('.travis.yml') do |content|
    content.gsub('oraclejdk7', 'oraclejdk8')
  end
  if patched
    mysystem("git commit -m \"Build using Java 8 as Java 7 has been removed from some TravisCI nodes\"")
  end
end

command(:add_code_of_conduct) do |app|
  FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/tmp/code-of-conduct.md", 'CODE_OF_CONDUCT.md'
  mysystem('git add CODE_OF_CONDUCT.md')
  mysystem("git commit -m \"Add a code of conduct\"")
end

command(:update_publish_task) do |app|
  if File.exist?('tasks/publish.rake')
    FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/tmp/publish.rake", 'tasks/publish.rake'
    begin
      patched = patch_file('.travis.yml') do |content|
        content.gsub("  depth: 10\n", "  depth: false\n")
      end
      mysystem('git add .travis.yml') if patched
      mysystem('git add tasks/publish.rake')
      mysystem("git commit -m \"Change the 'publish_if_tagged' task to stop working around shallow git checkouts on TravisCI.\"")
    rescue Exception
      # ignored
    end
  end
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

command(:add_issue_template) do |app|
  if File.exist?('CONTRIBUTING.md')
    FileUtils.mkdir_p '.github'
    FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/tmp/ISSUE_TEMPLATE.md", '.github/ISSUE_TEMPLATE.md'
    begin
      mysystem('git add .github/ISSUE_TEMPLATE.md')
      mysystem("git commit -m \"Add issue template.\"")
    rescue Exception
      # ignored
    end
  end
end

Zim::Belt.load_suites_from_belt
