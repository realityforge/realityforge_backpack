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

patch_gem('buildr', %w(1.5.3), '1.5.4')
patch_gem('braid', %w(1.0.8 1.0.20), '1.0.21')

command(:patch_jsr305) do |app|
  patch_versions(app, %w(com.google.code.findbugs:jsr305:jar), '3.0.1')
end

command(:patch_getopt4j) do |app|
  patch_versions(app, %w(org.realityforge.getopt4j:getopt4j:jar), '1.2')
end

command(:patch_gwt_version) do |app|
  patch_versions(app, %w(com.google.gwt:gwt-user:jar com.google.gwt:gwt-dev:jar com.google.gwt:gwt-servlet:jar), '2.8.1')
end

command(:remove_custom_pom) do |app|
  patched = patch_file('buildfile') do |content|
    content.gsub("require 'buildr/custom_pom'\n", '')
  end
  if patched
    mysystem("git commit -m \"Remove obsolete usage of 'custom_pom' addon\"")
  end
end

Zim::Belt.load_suites_from_belt
