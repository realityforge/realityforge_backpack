#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Zim # nodoc

  # Contains all the support methods for performing actions in code bases

  class << self

    # Return true if the current working directory has no changes that are not pushed
    def cwd_has_unpushed_changes?
      branch = git_current_branch
      # If there is no target branch to merge to then changes need to be pushed
      if git_has_remote_branch?(branch)
        changes_between_refs?('origin/master', branch)
      else
        changes_between_refs?("origin/#{branch}", branch)
      end
    end

    # Return true if the specified branch has a remote branch
    def git_has_remote_branch?(branch)
      `git config branch.#{branch}.merge`.strip == ''
    end

    def changes_between_refs?(from_branch, to_branch)
      `git log #{from_branch}..#{to_branch} 2>&1`.split.select {|l| l.size != 0}.size > 0
    end

    # Execute a ruby command within the context of rbenv environment.
    # e.g.
    #
    #    rbenv_exec('bundle install')
    #
    def rbenv_exec(command, fail_on_error = true)
      envs = %w(GEM_PATH GEM_HOME BUNDLE_ORIG_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE RBENV_DIR RUBYLIB RBENV_VERSION RBENV_ROOT RBENV_HOOK_PATH RUBYOPT RBENV_SHELL)
      mysystem("#{envs.collect {|e| "unset #{e}"}.join('; ')}; rbenv exec #{command}", fail_on_error)
    end

    # Execute a ruby command within the context of bundle environment.
    # e.g.
    #
    #    bundle_exec('buildr compile')
    #
    def bundle_exec(command, fail_on_error = true)
      rbenv_exec("bundle exec #{command}", fail_on_error)
    end

    # Patch a particular file in block, returning updated contents from block
    # If the file has been modified in the block, then it will be added to the
    # git index and the method will return true.
    # e.g.
    #
    #    patched = patch_file('.ruby-version') do |content|
    #      content.gsub('2.1.2', '2.1.3')
    #    end
    #    if patched
    #      mysystem('git commit -m "Update to the latest version of ruby."')
    #    end
    #
    def patch_file(file, &block)
      filename = "#{Dir.pwd}/#{file}"
      if File.exist?(filename)
        contents = IO.read(filename)
        new_contents = block.call(contents.dup)
        if contents != new_contents
          File.open(filename, 'wb') {|f| f.write new_contents}
          mysystem("git add #{file}")
          return true
        end
      end
      false
    end

    # Update the versions for specified dependencies to a target version.
    # The command assumes that dependencies are stored in build.yaml as per
    # buildr requirements. If the build.yaml has not been modified then the
    # method will return false. Otherwise the updated build.yaml will
    # be committed to repository.
    # e.g.
    #
    #    patched = patch_versions(app, %w(com.icegreen:greenmail:jar), '1.4.0')
    #    if patched
    #      puts "Greenmail was updated!"
    #    end
    #
    def patch_versions(app, dependencies, target_version, options = {})
      dependencies = dependencies.is_a?(Array) ? dependencies : [dependencies]
      source_versions = options[:source_versions]
      skip_apps = options[:skip_apps] || []
      name = options[:name] || get_shortest_group_name(dependencies)

      return if skip_apps.include?(app)

      patched =
        patch_dependencies_in_file('build.yaml', dependencies, source_versions, target_version) ||
          patch_dependencies_in_file('README.md', dependencies, source_versions, target_version)
      if patched
        mysystem("git commit -m \"Update the #{name} dependency.\"")
        puts "Update the #{name} dependency in #{app}"
      end

      patched
    end

    def patch_dependencies_in_file(filename, dependencies, source_versions, target_version)
      patch_file(filename) do |content|
        dependencies.each do |dependency|
          if source_versions
            source_versions.each do |source_version|
              content.gsub!("#{dependency}:#{source_version}", "#{dependency}:#{target_version}")
            end
          else
            content.gsub!(/#{dependency.gsub(':', "\\:").gsub('.', "\\.")}\:[a-zA-Z0-9\-_.]*([ \t\r\n])/m, "#{dependency}:#{target_version}\\1")
          end
        end
        content
      end
    end

    # Update the coordinates of specified dependencies and changed version to a target version.
    # The command assumes that dependencies are stored in build.yaml as per
    # buildr requirements. If the build.yaml has not been modified then the
    # method will return false. Otherwise the updated build.yaml will
    # be committed to repository.
    # e.g.
    #
    #    patch_dependency_coordinates(app,
    #                                 {
    #                                   'iris.calendar:calendar-ux:jar' => 'iris.calendar:calendar-gwt:jar',
    #                                   'iris.calendar:calendar-ux-qa:jar' => 'iris.calendar:calendar-gwt-qa-support:jar',
    #                                   'iris.calendar:calendar-client:jar' => 'iris.calendar:calendar-soap-client:jar',
    #                                   'iris.calendar:calendar-fake:jar' => 'iris.calendar:calendar-soap-qa-support:jar'
    #                                 },
    #                                 '1ae6f3a-546')
    #
    def patch_dependency_coordinates(app, dependencies, target_version, options = {})
      source_versions = options[:source_versions]
      name = options[:name] || dependencies.keys[0].gsub(/\:.*/, '')

      patched = patch_file('build.yaml') do |content|
        dependencies.each do |source_dependency, target_dependency|
          if source_versions
            source_versions.each do |source_version|
              content =
                content.
                  gsub(" #{source_dependency}:#{source_version}", " #{target_dependency}:#{target_version}").
                  gsub(":#{source_dependency}:#{source_version}", ": #{target_dependency}:#{target_version}")
            end
          else
            content =
              content.
                gsub(/ #{Regexp.escape(source_dependency)}\:.*/, " #{target_dependency}:#{target_version}").
                gsub(/:#{Regexp.escape(source_dependency)}\:.*/, ":#{target_dependency}:#{target_version}")
          end
        end
        content
      end
      if patched
        mysystem("git commit -m \"Update the #{name} dependency coordinates.\"")
        puts "Update the #{name} dependency coordinates in #{app}"
      end
    end

    # Patch the Gemfile in block, returning updated contents from block
    # If the Gemfile has not been modified in the block then the method will return false.
    # Otherwise bundler will be invoked to regenerate Gemfile.lock and the updated
    # Gemfile and Gemfile.lock (if checked in) will be committed to repository.
    # e.g.
    #
    #    patched = patch_gemfile('Update to the latest version of Buildr gem.') do |content|
    #      content.
    #        gsub("gem 'buildr', '= 1.4.20'", "gem 'buildr', '= 1.4.22'").
    #        gsub("gem 'buildr', '= 1.4.21'", "gem 'buildr', '= 1.4.22'")
    #    end
    #    if patched
    #      puts "Buildr was updated!"
    #    end
    #
    def patch_gemfile(commit_message, options = {}, &block)
      filename = "#{Dir.pwd}/Gemfile"
      if File.exist?(filename)
        contents = IO.read(filename)
        new_contents = block.call(contents.dup)
        if contents != new_contents
          File.open(filename, 'wb') {|f| f.write new_contents}
          mysystem('rm -f Gemfile.lock')
          rbenv_exec('bundle install')
          mysystem('git add Gemfile')
          begin
            # Not all repos have lock files checked in
            mysystem('git ls-files Gemfile.lock --error-unmatch > /dev/null 2> /dev/null && git add Gemfile.lock')
          rescue
          end
          mysystem("git commit -m \"#{commit_message}\"") unless options[:no_commit]
          return true
        end
      end
      false
    end

    # Add a task to patch the gem specified in Gemfile from a version to a version.
    # e.g.
    #
    #    patch_gem('buildr', '1.4.20', '1.4.22')
    #    patch_gem('buildr', ['1.4.20', '1.4.21'], '1.4.22')
    #
    def patch_gem(gem, from_version, to_version)
      from_version = from_version.is_a?(Array) ? from_version : [from_version]
      desc "Update the version of the #{gem} gem from #{from_version.inspect} to #{to_version}"
      command(:"patch_#{gem}_gem") do |app|
        patch_gemfile("Update the version of the #{gem} gem to #{to_version}.") do |content|
          from_version.each do |v|
            content = content.gsub("gem '#{gem}', '= #{v}'", "gem '#{gem}', '= #{to_version}'")
          end
          content
        end
      end
    end

    # Add a task to patch the .ruby-version file from a version to a version.
    # e.g.
    #
    #    ruby_update('2.1.3', '2.3.1')
    #
    def ruby_update(from_version, to_version)
      desc "Update the ruby version from #{from_version} to #{to_version}"
      command(:"patch_ruby_version_#{from_version}") do |app|
        patched = patch_file('.ruby-version') do |content|
          content.gsub(from_version, to_version)
        end
        if patched
          mysystem("git commit -m \"Update the ruby version from #{from_version} to #{to_version}\"")
        end
      end
    end

    # Add tasks that upgrade ruby and runs required tasks to patch config files.
    # e.g.
    #
    #    ruby_upgrade('2.1.3', '2.3.1')
    #
    def ruby_upgrade(from_version, to_version)
      ruby_update(from_version, to_version)

      desc "Upgrade the ruby version from #{from_version} to #{to_version}, regenerating config files."
      command(:"upgrade_ruby_version_#{from_version}") do |app|
        run(:"patch_ruby_version_#{from_version}", app)

        if Zim.cwd_has_unpushed_changes?
          run(:bundle_install, app) if Zim.command_by_name?(:bundle_install)
          run(:normalize_jenkins, app) if Zim.command_by_name?(:normalize_jenkins)
          run(:normalize_travisci, app) if Zim.command_by_name?(:normalize_jenkins)
        end
      end
    end

    # Execute braid update on path if the path is present.
    # This command assumes rbenv context with braid installed.
    # e.g.
    #
    #    braid_update(app, 'vendor/plugins/dbt')
    #
    def braid_update(app, path)
      if File.exist?(path)
        begin
          bundle_exec("braid update #{path}")
        rescue
          mysystem("git remote rm master/braid/#{path} >/dev/null 2>/dev/null") rescue
            rbenv_exec("braid update #{path}")
        end
        puts "Upgraded #{path} in #{app}"
      end
    end

    # Execute braid diff for path if the path is present.
    # This command assumes rbenv context with braid installed.
    # e.g.
    #
    #    braid_diff(app, 'vendor/plugins/dbt')
    #
    def braid_diff(app, path)
      if File.exist?(path)
        puts "Braid Diff #{path} in #{app}"
        bundle_exec("braid diff #{path}")
      end
    end

    # Execute braid diff if braid is present.
    # e.g.
    #
    #    braid_diff_all()
    #
    def braid_diff_all
      bundle_exec('braid setup 2>&1 > /dev/null', false)
      bundle_exec('braid diff') if 0 == $?.exitstatus
    end

    # Execute braid upgrade-config if braid is present.
    # e.g.
    #
    #    braid_update_config()
    #
    def braid_update_config
      bundle_exec('braid setup 2>&1 > /dev/null', false)
      bundle_exec('braid upgrade-config') if 0 == $?.exitstatus
    end

    # Execute braid update if braid is present.
    # e.g.
    #
    #    braid_update_all()
    #
    def braid_update_all
      bundle_exec('braid setup 2>&1 > /dev/null', false)
      bundle_exec('braid update') if 0 == $?.exitstatus
    end

    # Add a command that updates the version of a dependency family
    # in projects (assuming all dependencies are in build.yaml). This
    # method assumes the standard set of artifacts that are usually shared
    # between projects.
    #
    # e.g. Updating all the acal dependencies
    #
    #    standard_dependency(:acal, 'iris.acal', 'acal', '1.4.0')
    #
    def standard_dependency(code, group, base_artifact, target_version, options = {})
      artifacts = []

      options = options.dup

      standard_suffixes = %w(
        shared:jar
        model:jar model-qa-support:jar
        replicant-shared:jar replicant-qa-support:jar
        gwt:jar gwt-qa-support:jar
        server:war
        server:jar server-qa-support:jar
        db:jar
        integration-qa-support:jar
        sync_model:jar
        soap-client:jar soap-qa-support:jar
      )

      %W(#{group} #{group}.pg).each do |g|
        ((options[:additional_artifacts] || []) + %W(domains-#{base_artifact}:json) + standard_suffixes).
          each do |artifact_suffix|
          artifacts << "#{g}:#{base_artifact}-#{artifact_suffix}"
        end
      end

      desc "Update the #{code} dependencies in build.yaml"
      command(:"patch_#{code}_dep") do |app|
        patch_versions(app, artifacts, target_version, options)
      end
    end

    # Add a command that updates the version of a dependency family
    # in projects (assuming all dependencies are in build.yaml)
    #
    # e.g. Updating a dependency with a single coordinate
    #
    #    dependency(:greenmail, %w(com.icegreen:greenmail:jar), '1.4.0')
    #
    # e.g. Updating multiple dependencies with related coordinates
    #
    #    dependency(:iris, %w(iris:iris-db:jar iris:iris-soap-qa-support:jar iris:iris-soap-client:jar), 'e846707-879')
    #
    def dependency(code, artifacts, target_version, options = {})
      desc "Update the #{code} dependencies in build.yaml"
      command(:"patch_#{code}_dep") do |app|
        patch_versions(app, artifacts, target_version, options)
      end
    end

    # Add a command that updates the version of a dependency family
    # in projects (assuming all dependencies are in build.yaml). A task
    # may also be created if the coordinates need to be updated at the same time.
    # This is a higher-level version of the dependency method that assumes
    # more about the dependency group.
    #
    # e.g. Updating a dependency with a single coordinate
    #
    #    dependency_group(:greenmail, 'com.icegreen', 'greenmail:jar', '1.4.0')
    #
    # e.g. Updating a set of dependencies with the same group coordinate
    #
    #    dependency_group(:iris, 'iris', %w(iris-db:jar iris-soap-qa-support:jar iris-soap-client:jar), 'e846707-879')
    #
    # e.g. Updating a set of dependencies that appear in the multiple groups
    #
    #    dependency_group(:syncrecord,
    #                     %w(iris.syncrecord iris.syncrecord.pg),
    #                     %w(sync-record-db:jar sync-record-server:jar sync-record-model-qa-support:jar sync-record-server-qa-support:jar sync-record-rest-client:jar),
    #                     'b91c2cd-345')
    #
    # e.g. Updating a set of dependencies that appear in the multiple groups, also
    # adding task to update coordinates at the same time.
    #
    #    dependency_group(:syncrecord,
    #                     %w(iris.syncrecord iris.syncrecord.pg),
    #                     %w(sync-record-db:jar sync-record-server:jar sync-record-model-qa-support:jar sync-record-server-qa-support:jar sync-record-rest-client:jar),
    #                     'b91c2cd-345',
    #                     :name_changes =>
    #                       {
    #                         'iris-syncrecord-db:jar' => 'sync-record-db:jar',
    #                         'iris-syncrecord-server:jar' => 'sync-record-server:jar',
    #                         'iris-syncrecord-rest-client:jar' => 'sync-record-rest-client:jar',
    #                         'iris-syncrecord-server-qa-support:jar' => 'sync-record-server-qa-support:jar',
    #                         'iris-syncrecord-model-qa-support:jar' => 'sync-record-model-qa-support:jar'
    #                       })
    #
    def dependency_group(code, groups, names, version, options = {})
      groups = [groups] unless groups.is_a?(Array)
      names = [names] unless names.is_a?(Array)

      artifacts = groups.collect {|g| names.collect {|n| "#{g}:#{n}"}}.flatten

      options = options.dup

      group_changes = options.delete(:group_changes)
      name_changes = options.delete(:name_changes)

      dependency(code, artifacts, version, options)

      if group_changes || name_changes
        desc "Update the #{code} dependencies in build.yaml"
        command(:"patch_#{code}_coords") do |app|
          changes = {}
          if group_changes && name_changes
            group_changes.each_pair do |source_group, target_group|
              name_changes.each_pair do |source_name, target_name|
                changes["#{source_group}:#{source_name}"] = "#{target_group}:#{target_name}"
              end
              names.select {|n| !name_changes.values.include?(n)}.each do |name|
                changes["#{source_group}:#{name}"] = "#{target_group}:#{name}"
              end
            end
          elsif group_changes
            group_changes.each_pair do |source_group, target_group|
              names.each do |name|
                changes["#{source_group}:#{name}"] = "#{target_group}:#{name}"
              end
            end
          else
            groups.each do |group|
              name_changes.each_pair do |source_name, target_name|
                changes["#{group}:#{source_name}"] = "#{group}:#{target_name}"
              end
            end
          end
          patch_dependency_coordinates(app,
                                       changes,
                                       version,
                                       options)
          run(:"patch_#{code}_dep", app)
        end
      end
    end

    # Define braid tasks for supplied mapping of key => path. Also create braid_diff_all and braid_update_all tasks.
    # e.g.
    #
    #    braid_tasks({'dbt' => 'vendor/plugins/dbt', 'domgen' => 'vendor/plugins/domgen'})
    #
    def braid_tasks(braids)
      braids.each_pair do |key, path|
        standard_braid_tasks(key, path)
      end

      desc 'Perform diffs against all braids'
      command(:braid_diff_all) do |app|
        braid_diff_all if File.exist?('.braids.json')
      end

      desc 'Update braid config to the latest version supported by braid'
      command(:braid_update_config) do |app|
        braid_update_config if File.exist?('.braids.json')
      end

      desc 'Perform updates for all braids'
      command(:braid_update_all) do
        braid_update_all if File.exist?('.braids.json')
      end

      desc 'Perform diffs against all braids in braid list'
      command(:braid_diff_all_configured) do |app|
        puts "Braid diffing #{app}\n=================\n"
        braids.keys.each do |key|
          run(:"braid_diff_#{key}", app)
        end
        puts "=================\n\n\n\n"
      end

      desc 'Perform updates for all braids in braid list'
      command(:braid_update_all_configured) do |app|
        braids.keys.each do |key|
          run(:"braid_update_#{key}", app) if File.exist?('.braids.json')
        end
      end
    end

    # Define braid update and diff tasks for single path.
    # e.g.
    #
    #    braid_tasks('dbt', 'vendor/plugins/dbt')
    #
    def standard_braid_tasks(key, path)
      command(:"braid_update_#{key}") do |app|
        braid_update(app, path)
      end
      command(:"braid_diff_#{key}") do |app|
        braid_diff(app, path)
      end
    end

    def git_current_branch
      `git rev-parse --abbrev-ref HEAD`.strip
    end

    # Commit changed files with specified message. Swallow error if fail_on_error is true
    def git_commit(message, fail_on_error = true)
      begin
        mysystem("git commit -m \"#{message}\" 2> /dev/null > /dev/null")
        return true
      rescue Exception => e
        raise e if fail_on_error
        return false
      end
    end

    # Make sure the filesystem matches the contents of git repository
    def git_clean_filesystem
      mysystem('git clean -f -d -x 2> /dev/null > /dev/null')
    end

    def git_fetch
      mysystem('git fetch --prune')
    end

    # Pull from specified remote or origin if unspecified
    def git_pull(remote = '')
      mysystem("git pull #{remote}")
    end

    # Push to specified remote or origin if unspecified
    def git_push(remote = 'origin')
      mysystem("git push --set-upstream #{remote} #{git_current_branch}")
    end

    def git_local_branch_list
      `git branch`.gsub('* ', '').split("\n").collect {|s| s.strip}
    end

    # Diff against a specific branch
    def git_diff(branch = 'origin/master')
      mysystem("git diff #{branch}")
    end

    # Merge in specified branch
    def git_merge(branch = 'origin/master')
      mysystem("git merge #{branch}")
    end

    # Run prune in repository. Needed if there is too much garbage generated
    def git_prune
      mysystem('git prune')
    end

    # Garbage collect repository
    def git_gc
      mysystem('git gc')
    end

    # Reset branch to origin if there is no changes
    def git_reset_if_unchanged(branch = "origin/#{git_current_branch}")
      if git_has_remote_branch?(branch) && Zim.cwd_has_unpushed_changes? && `git diff #{branch} 2>&1`.split("\n").size == 0
        git_reset_branch(branch)
      end
    end

    # Reset the index, local filesystem and potentially branch
    def git_reset_branch(branch = '')
      mysystem("git reset --hard #{branch} 2> /dev/null > /dev/null")
      git_clean_filesystem
    end

    # Reset the index. Don't change the filesystem
    def git_reset_index
      mysystem('git reset 2> /dev/null > /dev/null')
    end

    # Add all files that are part of the checkout
    def git_add_all_files
      files = `git ls-files`.split("\n").collect {|f| "'#{f}'"}
      index = 0
      while index < files.size
        block_size = 100
        to_process = files[index, block_size]
        index += block_size
        mysystem("git add --all --force #{to_process.join(' ')} 2> /dev/null > /dev/null")
      end
    end

    # Checkout specified branch, creating branch if create is enabled
    def git_checkout(branch = 'master', create = false)
      if !create || `git branch -a`.split.collect {|l| l.gsub('remotes/origin/', '')}.sort.uniq.include?(branch)
        mysystem("git checkout #{branch} > /dev/null 2> /dev/null")
      else
        mysystem("git checkout -b #{branch} > /dev/null 2> /dev/null")
      end
    end

    # Historic approach to whitespace cleanup
    def clean_whitespace(app)
      git_clean_filesystem

      # normalize_whitespace has already cleaned up whitespace if buildr_plus present
      unless File.exist?('vendor/tools/buildr_plus')
        extensions = %w(jsp sass scss xsl sql haml less rake xml html gemspec properties yml yaml css rb java xhtml rdoc txt erb gitattributes gitignore xsd textile md wsdl)
        full_filenames = %w(rakefile Rakefile buildfile Buildfile Gemfile LICENSE)

        files_to_dedupe_nl = Dir['etc/checkstyle/*.xml'].flatten + Dir['tasks/*.rake'].flatten + Dir['doc/*.md'].flatten + Dir['*.md'].flatten + Dir['config/*.sh'].flatten + %w(buildfile Gemfile README.md)

        files = full_filenames.collect {|file| Dir["**/#{file}"]}.flatten + extensions.collect {|extension| Dir["**/*.#{extension}"] + Dir["**/.#{extension}"]}.flatten

        files.each do |f|
          next if /^vendor\/.*/ =~ f
          next if /^node_modules\/.*/ =~ f

          content = File.read(f)
          original_content = content.dup
          begin
            puts "Fixing DOS EOL: #{f}" if content.gsub!(/\r\n/, "\n")
            puts "Fixing Trailing whitespace: #{f}" if content.gsub!(/[ \t]+\n/, "\n")
            puts "Fixing Double lines: #{f}" if content.gsub!(/\n\n\n/, "\n\n") if files_to_dedupe_nl.include?(f)
            content.gsub!(/[ \r\t\n]+\Z/, '')
            content += "\n"
          rescue
            puts "Skipping whitespace cleanup: #{f}"
          end
          if content != original_content
            puts "Fixing: #{f}"
            File.open(f, 'wb') do |out|
              out.write content
            end
          end
        end
      end

      git_reset_index
      git_add_all_files
      if git_commit('Cleanup whitespace at EOL and EOF.', false)
        puts "Whitespace cleaned up in #{app}"
      end
    end

    # Helper method that updates a dependency in an automerge branch
    def propose_dependency_update(app, dependencies, target_version)
      dependency_name = get_shortest_group_name(dependencies)
      branch_name = "AM_update_#{dependency_name}"
      merge_origin = git_local_branch_list.include?(branch_name)
      git_checkout(branch_name, true)
      git_merge('origin/master') if merge_origin

      if patch_versions(app, dependencies, target_version)
        git_push
      else
        git_checkout('master')
        mysystem("git branch -D #{branch_name} 2> /dev/null 1> /dev/null")
      end
    end

    # Scan dependencies and find group part of spec that is shortest
    def get_shortest_group_name(dependencies)
      dependencies.collect {|s| s.gsub(/\:.*/, '')}.sort {|a, b| a.length <=> b.length}[0]
    end

    # Add standard set of commands for interacting with git
    # repositories that applicable to all users of zim
    def add_standard_git_tasks
      command(:clone, :in_app_dir => false) do |app|
        url = Zim.current_suite.application_by_name(app).git_url

        app_directory = dir_for_app(app)
        container_directory = File.dirname(app_directory)
        FileUtils.mkdir_p container_directory unless File.exists?(container_directory)
        directory_exists = File.directory?(app_directory)

        if directory_exists
          found = false
          in_app_dir(app) do
            `git remote -v`.split("\n").each do |line|
              elements = line.split(/[ \t]+/)
              if elements[0] == 'origin' && elements[1] == url && elements[2] == '(fetch)'
                found = true
                break
              end
            end
          end
          unless found
            mysystem("rm -rf #{app_directory}")
            directory_exists = false
          end
        end

        mysystem("git clone #{url}") unless directory_exists
      end

      command(:gitk) do
        mysystem('gitk --all &') if Zim.cwd_has_unpushed_changes?
      end

      command(:fetch) do
        git_fetch
      end

      command(:reset) do
        git_reset_branch
      end

      command(:reset_origin) do
        git_reset_branch('origin/master')
      end

      command(:git_reset_if_unchanged) do
        git_reset_if_unchanged
      end

      command(:diff_origin) do
        git_diff
      end

      command(:goto_master) do
        git_checkout
      end

      command(:pull) do
        git_pull
      end

      command(:git_prune) do
        git_prune
      end

      command(:git_gc) do
        git_gc
      end

      command(:push) do |app|
        run(:git_reset_if_unchanged, app)
        git_push if Zim.cwd_has_unpushed_changes?
      end

      command(:remove_local_branches) do |app|
        git_local_branch_list.select {|b| b != 'master'}.each do |branch|
          mysystem("git branch -D #{branch}")
        end
      end

      command(:clean, :in_app_dir => false) do |app|
        run(:clone, app)
        run(:fetch, app)
        run(:reset, app)
        run(:goto_master, app)
        run(:remove_local_branches, app)
        run(:pull, app)
      end

      command(:branch) do |app|
        git_checkout(Zim::Config.parameter_by_name('BRANCH'), true)
      end

      command(:real_clean, :in_app_dir => false) do |app|
        run(:clean, app)
        run(:reset_origin, app)
      end

      command(:ultra_clean, :in_app_dir => false) do |app|
        run(:real_clean, app)
        run(:git_prune, app)
        run(:git_gc, app)
      end
    end

    # Add standard set of commands for interacting with bundler
    def add_standard_bundler_tasks
      desc 'Install all dependencies for application if Gemfile present'
      command(:bundle_install) do
        rbenv_exec('bundle install') if File.exist?('Gemfile')
      end
    end

    # Add standard set of commands for interacting with buildr
    def add_standard_buildr_tasks
      add_standard_bundler_tasks
      desc 'Download all artifacts application if buildfile'
      command(:buildr_artifacts) do
        if File.exist?('buildfile')
          begin
            rbenv_exec('buildr artifacts:sources artifacts clean')
          rescue
            # ignored
          end
        end
      end

      desc 'Propose an update to dependency for all downstream projects in a automerge branch. Specify parameters DEPENDENCIES and VERSION'
      command(:propose_dependency_update, :in_app_dir => false) do |app|
        dependencies = Zim::Config.parameter_by_name('DEPENDENCIES').split(',')
        target_version = Zim::Config.parameter_by_name('VERSION')

        run(:real_clean, app)
        in_app_dir(app) do
          propose_dependency_update(app, dependencies, target_version)
        end
      end
    end

    # Add standard set of commands for interacting with buildr when buildr_plus is present
    def add_standard_buildr_plus_tasks
      add_standard_buildr_tasks

      desc 'Normalize the gitignore file based on buildr_plus rules'
      command(:normalize_gitignore) do |app|
        if File.exist?('vendor/tools/buildr_plus')
          git_clean_filesystem
          bundle_exec('buildr gitignore:fix')
          git_reset_index
          git_add_all_files
          mysystem('git add --all --force .gitignore 2> /dev/null > /dev/null')
          git_commit('Normalize .gitignore', false)
        end
      end

      desc 'Normalize the whitespace in files based on zapwhite rules'
      command(:normalize_whitespace, :in_app_dir => false) do |app|
        unless Zim.current_suite.application_by_name(app).tags.include?('zapwhite=no')
          app_directory = dir_for_app(app)
          if File.exist?("#{app_directory}/vendor/tools/buildr_plus")
            Zim.in_dir(app_directory) do
              git_clean_filesystem
              bundle_exec('buildr zapwhite:fix')
              git_reset_index
              git_add_all_files
              mysystem('git add --all --force .gitattributes 2> /dev/null > /dev/null')
              git_commit('Normalize whitespace', false)
            end
          elsif File.exist?("#{app_directory}")
            Zim.in_dir(app_directory) do
              git_clean_filesystem
            end
            mysystem("bundle exec zapwhite -d #{app_directory}", false)
            Zim.in_dir(app_directory) do
              git_reset_index
              git_add_all_files
              mysystem('git add --all --force .gitattributes 2> /dev/null > /dev/null')
              git_commit('Normalize whitespace', false)
            end
          end
        end
      end

      desc 'Normalize the travis configuration based on buildr_plus rules'
      command(:normalize_travisci) do |app|
        if File.exist?('vendor/tools/buildr_plus') && File.exist?('.travis.yml')
          git_clean_filesystem
          bundle_exec('buildr travis:fix')
          git_reset_index
          git_add_all_files
          mysystem('git add --all --force .travis.yml 2> /dev/null > /dev/null')
          git_commit('Normalize travis configuration', false)
        end
      end

      desc 'Normalize the jenkins configuration based on buildr_plus rules'
      command(:normalize_jenkins) do |app|
        if File.exist?('vendor/tools/buildr_plus') && File.exist?('Jenkinsfile')
          git_clean_filesystem
          bundle_exec('buildr jenkins:fix')
          git_reset_index
          git_add_all_files
          mysystem('git add --all --force Jenkinsfile 2> /dev/null > /dev/null')
          mysystem('git add --all --force .jenkins 2> /dev/null > /dev/null', false)
          git_commit('Normalize jenkins configuration', false)
        end
      end

      desc 'Normalize the Gemfile based on buildr_plus rules'
      command(:normalize_gemfile) do |app|
        if File.exist?('vendor/tools/buildr_plus')
          git_clean_filesystem
          mysystem('rm Gemfile.lock')
          bundle_exec('buildr gems:fix')
          git_reset_index
          git_add_all_files
          mysystem('git add --all --force Gemfile Gemfile.lock 2> /dev/null > /dev/null')
          git_commit('Normalize Gemfile', false)
        end
      end

      desc 'Normalize files using buildr_plus rules'
      command(:normalize_all) do |app|
        run(:normalize_gemfile, app)
        run(:normalize_gitignore, app)
        run(:normalize_whitespace, app)
        run(:normalize_travisci, app)
        run(:normalize_jenkins, app)
      end
    end

    # add tasks that help get info from the zim system
    def add_standard_info_tasks
      desc 'Perform no action other than print the app name and tags unless quiet'
      command(:print, :in_app_dir => false) do |app|
        if Zim::Config.quiet?
          puts app
        else
          puts "#{app}: #{Zim.current_suite.application_by_name(app).tags.inspect}"
        end
      end
    end
  end
end
