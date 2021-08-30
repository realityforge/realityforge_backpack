add_standard_util_tasks
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

ruby_upgrade('2.6.6', '2.7.2')
bazel_update('2.1.1', '2.2.0')

patch_gem('realityforge-buildr', %w(1.5.9 1.5.10 1.5.11 1.5.12 1.5.13 1.5.14 1.5.15 1.5.16), '1.5.17')
patch_gem('braid', %w(1.0.18 1.0.19 1.0.20 1.0.21 1.0.22 1.0.3 1.1.0), '1.1.0')
patch_gem('zapwhite', %w(2.9.0 2.10.0 2.11.0 2.12.0 2.13.0 2.14.0 2.15.0 2.16.0 2.17.0 2.18.0), '2.19.0')
patch_gem('mcrt', %w(1.9.0 1.10.0 1.11.0 1.12.0 1.13.0 1.14.0), '1.15.0')
patch_gem('reality-mash', %w(1.9.0 1.10.0 1.11.0 1.12.0 1.13.0 1.14.0), '1.1.0')
patch_gem('tiny_tds', %w(1.0.5), '2.1.3')

command(:patch_jsinterop_version) do |app|
  version = '2.0.0'
  patch_dependency_coordinates(app, { 'org.realityforge.com.google.jsinterop:jsinterop-annotations:jar' => 'com.google.jsinterop:jsinterop-annotations:jar' }, version)
  patch_versions(app, %w(com.google.jsinterop:jsinterop-annotations:jar), version)
end

patch_artifact(:akasha, %w(org.realityforge.akasha:akasha-gwt:jar org.realityforge.akasha:akasha-j2cl:jar), '0.22')
patch_artifact(:arez, %w(org.realityforge.arez:arez-core:jar org.realityforge.arez:arez-processor:jar), '0.199')
patch_artifact(:braincheck, %w(org.realityforge.braincheck:braincheck-core:jar org.realityforge.braincheck:braincheck-jre:jar org.realityforge.braincheck:braincheck-testng:jar), '1.31.0')
patch_artifact(:compile_testing, %w(com.google.testing.compile:compile-testing:jar), '0.18-rf')
patch_artifact(:galdr, %w(org.realityforge.galdr:galdr-core:jar org.realityforge.galdr:galdr-processor:jar), '0.03')
patch_artifact(:getopt4j, %w(org.realityforge.getopt4j:getopt4j:jar), '1.3')
patch_artifact(:gir, %w(org.realityforge.gir:gir-core:jar), '0.12')
patch_artifact(:grim, %w(org.realityforge.grim:grim-annotations:jar org.realityforge.grim:grim-asserts:jar org.realityforge.grim:grim-processor:jar), '0.05')
patch_artifact(:guava, %w(com.google.guava:guava:jar), '27.1-jre')
patch_artifact(:guiceyloops, %w(org.realityforge.guiceyloops:guiceyloops:jar), '0.106')
patch_artifact(:gwt_cache_filter, %w(org.realityforge.gwt.cache-filter:gwt-cache-filter:jar), '0.9')
patch_artifact(:idea_codestyle, %w(au.com.stocksoftware.idea.codestyle:idea-codestyle:xml), '1.17')
patch_artifact(:javaee_api, %w(javax:javaee-api:jar), '8.0')
patch_artifact(:javapoet, %w(com.squareup:javapoet:jar), '1.13.0')
patch_artifact(:javax_annotation, %w(org.realityforge.javax.annotation:javax.annotation:jar), '1.0.1')
patch_artifact(:jetbrains_annotations, %w(org.realityforge.org.jetbrains.annotations:org.jetbrains.annotations:jar), '1.7.0')
patch_artifact(:proton, %w(org.realityforge.proton:proton-core:jar org.realityforge.proton:proton-qa:jar), '0.51')
patch_artifact(:react4j, %w(org.realityforge.react4j:react4j-core:jar org.realityforge.react4j:react4j-dom:jar org.realityforge.react4j:react4j-processor:jar), '0.183')
patch_artifact(:revapi, %w(org.realityforge.revapi.diff:revapi-diff:jar:all), '0.08')
patch_artifact(:sting, %w(org.realityforge.sting:sting-core:jar org.realityforge.sting:sting-processor:jar), '0.19')
patch_artifact(:symbolmap, %w(org.realityforge.gwt.symbolmap:gwt-symbolmap:jar), '0.09')
patch_artifact(:truth, %w(com.google.truth:truth:jar), '0.45')
patch_artifact(:zemeckis, %w(org.realityforge.zemeckis:zemeckis-core:jar), '0.11')
patch_artifact(:vecmath, %w(org.realityforge.vecmath:vecmath:jar), '0.11')

command(:patch_release_tool) do
  if File.exist?('tasks/release.rake')
    patched = patch_file('tasks/release.rake') do |content|
      content.gsub("require 'buildr/release_tool.rb'", "require 'buildr/release_tool'")
    end
    mysystem("git commit -m \"Fixup release tool require.\"") if patched
  end
end

Zim::Belt.load_suites_from_belt
