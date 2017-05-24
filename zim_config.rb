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

patch_gem('buildr', %w(1.4.23 1.4.25 1.5.0 1.5.1 1.5.2), '1.5.3')
patch_gem('braid', %w(1.0.10 1.0.11 1.0.12 1.0.13 1.0.14 1.0.15 1.0.16 1.0.17 1.0.18 1.0.19), '1.0.20')

require File.expand_path('belt_config.rb')

Zim.suite('RF') do |suite|
  Belt.scope_by_name('realityforge').projects.each do |project|
    next if project.tags.include?('historic')
    next if project.tags.include?('external')
    next if project.tags.include?('deprecated')
    next if project.tags.include?('zim=no')
    suite.application(project.name,
                      'git_url' => "https://github.com/realityforge/#{project.name}.git",
                      'tags' => project.tags.dup)
  end
end
