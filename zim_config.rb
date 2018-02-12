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

patch_gem('buildr', %w(1.5.4), '1.5.5')
patch_gem('braid', %w(1.0.8 1.0.20 1.0.21), '1.0.22')

command(:patch_jsr305) do |app|
  patch_versions(app, %w(com.google.code.findbugs:jsr305:jar), '3.0.1')
end

command(:patch_getopt4j) do |app|
  patch_versions(app, %w(org.realityforge.getopt4j:getopt4j:jar), '1.2')
end

command(:patch_gwt_version) do |app|
  patch_versions(app, %w(com.google.gwt:gwt-user:jar com.google.gwt:gwt-dev:jar com.google.gwt:gwt-servlet:jar), '2.8.2')
end

command(:patch_jsinterop_version) do |app|
  patch_versions(app, %w(com.google.jsinterop:jsinterop-annotations:jar com.google.jsinterop:jsinterop-annotations:jar:sources), '1.0.2')
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

command(:remove_custom_pom) do |app|
  patched = patch_file('buildfile') do |content|
    content.gsub("require 'buildr/custom_pom'\n", '')
  end
  if patched
    mysystem("git commit -m \"Remove obsolete usage of 'custom_pom' addon\"")
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

Zim::Belt.load_suites_from_belt
