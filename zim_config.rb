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

patch_gem('realityforge-buildr', %w(1.5.9), '1.5.10')
patch_gem('braid', %w(1.0.18 1.0.19 1.0.20 1.0.21 1.0.22 1.0.3 1.1.0), '1.1.0')
patch_gem('zapwhite', %w(2.9.0 2.10.0 2.11.0 2.12.0 2.13.0 2.14.0 2.15.0 2.16.0 2.17.0 2.18.0), '2.19.0')
patch_gem('mcrt', %w(1.9.0 1.10.0 1.11.0 1.12.0 1.13.0 1.14.0), '1.15.0')
patch_gem('reality-mash', %w(1.9.0 1.10.0 1.11.0 1.12.0 1.13.0 1.14.0), '1.1.0')
patch_gem('tiny_tds', %w(1.0.5), '2.1.3')

command(:patch_buildr) do |app|
  # To find candidates
  #find ../../SourceTree/ ! -path '*/stocksoftware/*' -name Gemfile -exec grep "'buildr'" {} \; -print

  unless %w(swung_weave arez react4j arez-persist galdr grim spritz sting).include?(app)
    patched = patch_file('Gemfile') do |content|
      content.gsub("gem 'buildr', '= 1.5.8'\n", "gem 'realityforge-buildr', '= 1.5.9'\n")
    end
    if patched
      mysystem('git rm tasks/gwt_patch.rake') rescue nil
      mysystem('git rm tasks/warn_patch.rake') rescue nil
      mysystem('git rm tasks/transports_patch.rake') rescue nil
      mysystem('git rm tasks/testng_patch.rake') rescue nil
      mysystem('git rm tasks/idea_patch.rake') rescue nil
      mysystem('git rm tasks/gwt_patch.rake') rescue nil
      mysystem('rm -f Gemfile.lock')
      rbenv_exec('bundle install') rescue nil
      mysystem('git ls-files Gemfile.lock --error-unmatch > /dev/null 2> /dev/null && git add Gemfile.lock') rescue nil
      bundle_exec('buildr clean package')
      mysystem("git commit -m \"Update the version of Buildr.\"")
    end
  end
end

command(:patch_travis_ruby) do
  patched = patch_file('.travis.yml') do |content|
    content.
      gsub("- 2.3.1\n", "- 2.6.6\n").
      gsub("- 2.6.6\n", "- 2.7.2\n").
      # Use and install commands should no longer be required as 2.7.2 is supported by TravisCI
      gsub("- rvm use 2.3.1\n", "").
      gsub("- rvm use 2.6.6\n", "").
      gsub("  - rvm use 2.3.1\n", "").
      gsub("  - rvm use 2.6.6\n", "").
      gsub("- rvm install ruby-2.3.1\n", "").
      gsub("- rvm install ruby-2.6.6\n", "").
      gsub("  - rvm install ruby-2.6.6\n", "").
      gsub("  - rvm install ruby-2.3.1\n", "")
  end
  if patched
    mysystem("git commit -m \"Update the version of ruby used to build project in TravisCI.\"")
  end
end

command(:regenerate_Gemfile_lock) do
  patch_gemfile("Regenerate Gemfile.lock", :force => true) do |content|
    content
  end
end

command(:upgrade_braid) do |app|
  run(:patch_braid_gem, app)
  run(:braid_update_config, app)
end

command(:patch_idea_codestyle_version) do |app|
  patch_versions(app, %w(au.com.stocksoftware.idea.codestyle:idea-codestyle:xml), '1.17')
end

command(:patch_braincheck_version) do |app|
  patch_versions(app, %w(org.realityforge.braincheck:braincheck:jar), '1.29.0')
end

command(:patch_javapoet_version) do |app|
  patch_versions(app, %w(com.squareup:javapoet:jar), '1.13.0')
end

command(:patch_gwt_cache_filter_version) do |app|
  patch_versions(app, %w(org.realityforge.gwt.cache-filter:gwt-cache-filter:jar), '0.9')
end

command(:patch_grim_version) do |app|
  patch_versions(app, %w(org.realityforge.grim:grim-annotations:jar org.realityforge.grim:grim-asserts:jar org.realityforge.grim:grim-processor:jar), '0.04')
end

command(:patch_galdr_version) do |app|
  patch_versions(app, %w(org.realityforge.galdr:galdr-core:jar org.realityforge.galdr:galdr-processor:jar), '0.03')
end

command(:patch_sting_version) do |app|
  patch_versions(app, %w(org.realityforge.sting:sting-core:jar org.realityforge.sting:sting-processor:jar), '0.16')
end

command(:patch_symbolmap_version) do |app|
  patch_versions(app, %w(org.realityforge.gwt.symbolmap:gwt-symbolmap:jar), '0.09')
end

command(:patch_dagger_gwt_lite_version) do |app|
  patch_versions(app, %w(org.realityforge.dagger:dagger-gwt-lite:jar), '2.25.2-rf1')
end

command(:patch_revapi_version) do |app|
  patch_versions(app, %w(org.realityforge.revapi.diff:revapi-diff:jar:all), '0.08')
end

command(:patch_jsinterop_version) do |app|
  version = '2.0.0'
  patch_dependency_coordinates(app, { 'org.realityforge.com.google.jsinterop:jsinterop-annotations:jar' => 'com.google.jsinterop:jsinterop-annotations:jar' }, version)
  patch_versions(app, %w(com.google.jsinterop:jsinterop-annotations:jar), version)
end

command(:patch_jetbrains_annotations_version) do |app|
  patch_versions(app, %w(org.realityforge.org.jetbrains.annotations:org.jetbrains.annotations:jar), '1.7.0')
end

command(:patch_zemeckis_version) do |app|
  patch_versions(app, %w(org.realityforge.zemeckis:zemeckis-core:jar), '0.08')
end

command(:patch_guiceyloops_version) do |app|
  patch_versions(app, %w(org.realityforge.guiceyloops:guiceyloops:jar), '0.106')
end

command(:patch_gir_version) do |app|
  patch_versions(app, %w(org.realityforge.gir:gir-core:jar), '0.11')
end

command(:patch_getopt4j_version) do |app|
  patch_versions(app, %w(org.realityforge.getopt4j:getopt4j:jar), '1.3')
end

command(:patch_proton_version) do |app|
  patch_versions(app, %w(org.realityforge.proton:proton-core:jar org.realityforge.proton:proton-qa:jar), '0.51')
end

command(:patch_compile_testing_version) do |app|
  patch_versions(app, %w(com.google.testing.compile:compile-testing:jar), '0.18-rf')
end

command(:patch_truth_version) do |app|
  patch_versions(app, %w(com.google.truth:truth:jar), '0.45')
end

command(:patch_guava_version) do |app|
  patch_versions(app, %w(com.google.guava:guava:jar), '27.1-jre')
end

command(:patch_repository_urls) do
  patched = patch_file('build.yaml') do |content|
    content.
      gsub('https://repo.maven.apache.org/maven2/', 'https://repo.maven.apache.org/maven2').
      gsub('http://repo1.maven.org/maven2', 'https://repo.maven.apache.org/maven2').
      gsub('http://central.maven.org/maven2', 'https://repo.maven.apache.org/maven2').
      gsub('https://repo1.maven.org/maven2', 'https://repo.maven.apache.org/maven2')
  end
  if patched
    mysystem("git commit -m \"Use the canonical url to access maven central repository.\"")
  end
end

command(:patch_jfrog_repository_urls) do
  patched = patch_file('build.yaml') do |content|
    content.gsub('stocksoftware.artifactoryonline.com', 'stocksoftware.jfrog.io')
  end
  if patched
    mysystem("git commit -m \"Use the canonical url to access stocksoftware jfrog repositories.\"")
  end
end

command(:reorder_repository_urls) do
  patched = patch_file('build.yaml') do |content|
    content.gsub("   - https://repo.maven.apache.org/maven2\n   - https://stocksoftware.jfrog.io/stocksoftware/maven2\n",
                 "   - https://stocksoftware.jfrog.io/stocksoftware/maven2\n   - https://repo.maven.apache.org/maven2\n")
  end
  if patched
    mysystem("git commit -m \"Reorder repositories so the jfrog cache is accessed first to avoid intermittent Central failures.\"")
  end
end

command(:use_aggregate_repository_url) do
  patched = patch_file('build.yaml') do |content|

    if content.include?('   - https://stocksoftware.jfrog.io/stocksoftware/public')
      content.
        gsub("   - https://stocksoftware.jfrog.io/stocksoftware/public\n", "   - https://stocksoftware.jfrog.io/stocksoftware/maven2\n").
        gsub("    - https://stocksoftware.jfrog.io/stocksoftware/oss\n", "").
        gsub("   - https://stocksoftware.jfrog.io/stocksoftware/oss\n", "")
    elsif content.include?('   - https://stocksoftware.jfrog.io/stocksoftware/oss')
      content.
        gsub("   - https://stocksoftware.jfrog.io/stocksoftware/oss\n", "   - https://stocksoftware.jfrog.io/stocksoftware/maven2\n").
        gsub("    - https://stocksoftware.jfrog.io/stocksoftware/public\n", "").
        gsub("   - https://stocksoftware.jfrog.io/stocksoftware/public\n", "")
    else
      content
    end
  end
  if patched
    mysystem("git commit -m \"Use a single stocksoftware jfrog repository that also mirrors maven central. This works around rate limiting issues on TravisCI.\"")
  end
end

command(:remove_thirdparty_local_repository) do
  patched = patch_file('build.yaml') do |content|
    content.
      gsub("   # TODO: Remove thirdparty-local once payara is no longer version 5.192-rf\n", '').
      gsub("  # TODO: Remove thirdparty-local repository once payara is no longer version 5.192-rf\n", '').
      gsub("   - https://stocksoftware.artifactoryonline.com/stocksoftware/thirdparty-local\n", '').
      gsub("   - https://stocksoftware.jfrog.io/stocksoftware/thirdparty-local\n", '')
  end
  if patched
    mysystem("git commit -m \"Remove thirdparty-local repository as it is now included in aggregate repository list\"")
  end
end

command(:update_travisci_dist) do
  patched = patch_file('.travis.yml') do |content|
    content =~ /oraclejdk8/ && !(content =~ /^dist: /) ? "# Lock down dist to ensure that builds run on a distribution that supports oraclejdk8\ndist: trusty\n" + content : content
  end
  if patched
    mysystem("git commit -m \"Lock down dist to ensure that builds run on a distribution that supports oraclejdk8\"")
  end
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
    org.realityforge.com.google.elemental2:elemental2-webgl2:jar
    org.realityforge.com.google.elemental2:elemental2-webstorage:jar
    org.realityforge.com.google.elemental2:elemental2-webassembly:jar
  ), '2.27')
end

command(:patch_arez_version) do |app|
  patch_versions(app, %w(
    org.realityforge.arez:arez-core:jar
    org.realityforge.arez:arez-processor:jar
  ), '0.183')
end

command(:patch_arez_spytools_version) do |app|
  patch_versions(app, %w(org.realityforge.arez.spytools:arez-spytools:jar), '0.110')
end

command(:patch_arez_testng_version) do |app|
  patch_versions(app, %w(org.realityforge.arez.testng:arez-testng:jar), '0.15')
end

command(:patch_arez_dom_version) do |app|
  patch_versions(app, %w(org.realityforge.arez.dom:arez-dom:jar), '0.70')
end

command(:patch_react4j_version) do |app|
  patch_versions(app, %w(
    org.realityforge.react4j:react4j-core:jar
    org.realityforge.react4j:react4j-dom:jar
    org.realityforge.react4j:react4j-processor:jar
  ), '0.167')
end

command(:upgrade_javaee_api) do |app|
  patch_versions(app, %w(javax:javaee-api:jar), '8.0')
end

command(:upgrade_javax_annotation) do |app|
  patch_versions(app, %w(org.realityforge.javax.annotation:javax.annotation:jar), '1.0.1')
end

command(:fix_tags) do |app|
  bad_tags = `git tag | grep -v -- v`.strip.split("\n").select { |t| t =~ /^[0-9.]+$/ }
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

command(:condense_changelog) do
  patched = patch_file('CHANGELOG.md') do |content|
    content.gsub(")\n[Full", ") · [Full")
  end
  if patched
    patch_file('tasks/release.rake') do |content|
      content.gsub(")\n[Full", ") · [Full")
    end
  end
  if patched
    mysystem("git commit -m \"Condense the format of the CHANGELOG.\"")
  end
end

command(:update_contributing) do
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

command(:update_processor_path_script) do
  if File.exist?('tasks/processor_path.rake')
    FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/tmp/processor_path.rake", 'tasks/processor_path.rake'
    begin
      mysystem('git add tasks/processor_path.rake')
      mysystem("git commit -m \"Patch the processor to avoid potential null error.\"")
    rescue Exception
      # ignored
    end
  end
end

command(:patch_buildr_testng_addon) do
  if File.exist?('buildfile') && IO.read('buildfile') =~ /:testng/
    FileUtils.mkdir_p 'tasks'
    FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/tmp/testng_patch.rake", 'tasks/testng_patch.rake'
    begin
      mysystem('git add tasks/testng_patch.rake')
      mysystem("git commit -m \"Patch the TestNG addon to ensure that test failures result in a failed build.\"")
    rescue Exception
      # ignored
    end
  end
end

command(:patch_gwt_addons) do
  if File.exist?('tasks/gwt.rake')
    FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/tmp/gwt.rake", 'tasks/gwt.rake'
    mysystem('git add tasks/gwt.rake')
    begin
      mysystem("git commit -m \"Fix the GWT addon to work with generated source code.\"")
    rescue Exception
      # ignored
    end
  end
end

command(:patch_transport) do
  if File.exist?('buildfile')
    FileUtils.mkdir_p 'tasks'
    FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/tmp/transports_patch.rake", 'tasks/transports_patch.rake'
    mysystem('git add tasks/transports_patch.rake')
    begin
      mysystem("git commit -m \"Avoid the use of deprecated URI.unescape.\"")
    rescue Exception
      # ignored
    end
  end
end

command(:patch_warn) do
  if File.exist?('buildfile')
    FileUtils.mkdir_p 'tasks'
    FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/tmp/warn_patch.rake", 'tasks/warn_patch.rake'
    mysystem('git add tasks/warn_patch.rake')
    begin
      mysystem("git commit -m \"Fix the monkey-patching of warn to work with the latest version of ruby.\"")
    rescue Exception
      # ignored
    end
  end
end

command(:patch_gwt_patch) do
  if File.exist?('tasks/gwt_patch.rake')
    FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/tmp/gwt_patch.rake", 'tasks/gwt_patch.rake'
    mysystem('git add tasks/gwt_patch.rake')
    begin
      mysystem("git commit -m \"Patch gwt_patch addon to move to released version of jsinterop-annotations.\"")
    rescue Exception
      # ignored
    end
  end
end

command(:patch_gwt_version) do |app|
  patch_dependency_coordinates(app, {
    'org.realityforge.com.google.gwt:gwt-user:jar' => 'com.google.gwt:gwt-user:jar',
    'org.realityforge.com.google.gwt:gwt-dev:jar' => 'com.google.gwt:gwt-dev:jar'
  }, '2.9.0')
end

command(:edit_buildfile_when_changed) do
  if File.exist?('buildfile') && IO.read('buildfile') =~ /add_gwt_configuration/
    begin
      mysystem("git commit -a -m \"Update to support the latest GWT addon.\"")
    rescue
      # ignored
    end
  end
end

command(:remove_historic_ignore) do
  patched = patch_file('.gitignore') do |content|
    content.gsub("/.bundle\n", '')
  end
  if patched
    mysystem("git commit -m \"Remove historic ignore no longer required\"")
  end
end

command(:patch_TODO) do
  patched = patch_file('TODO.md') do |content|
    content.gsub("This document is essentially a list of shorthand notes describing work yet to completed.", "This document is essentially a list of shorthand notes describing work yet to be completed.")
  end
  if patched
    mysystem("git commit -m \"Improve grammar in TODO description\"")
  end
end

command(:zapwhite_if_configured) do |app|
  if File.exist?('Gemfile') && IO.read('Gemfile') =~ /zapwhite/
    run(:normalize_whitespace, app)
  end
end

command(:patch_travis_url) do
  patched = patch_file('README.md') do |content|
    content.
      gsub('https://secure.travis-ci.org/', 'https://api.travis-ci.com/').
      gsub('http://travis-ci.org/', 'http://travis-ci.com/')
  end
  if patched
    mysystem("git commit -m \"Update the TravisCI urls to point at .com version\"")
  end
end

Zim::Belt.load_suites_from_belt
