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

  # Class used to run the command line tool
  class Driver
    class << self

      def process(args)
        initial_args = args.dup

        customization_file = "#{Dir.pwd}/_zim.rb"
        require customization_file if File.exist?(customization_file)

        ::Zim.context do
          filename = File.expand_path('zim_config.rb')
          if File.exist?(filename)
            instance_eval IO.read(filename), filename
          else
            puts "Expected to find configuration file #{filename} to drive Zim."
            puts 'Please create such a file before re-running the zim command.'
            exit 1
          end
        end

        optparse = OptionParser.new do |opts|
          opts.on('-s', '--suite SUITE', 'Specify the suite of applications to process') do |suite_key|
            unless Zim.suite_by_name?(suite_key)
              puts "Bad suite set #{suite_key} specified. Specify one of:\n#{Zim.suite_names.collect { |c| "  * #{c}" }.join("\n")}"
              exit
            end
            Zim.current_suite = Zim.suite_by_name(suite_key)
          end

          opts.on('--first-app APP_NAME', 'The first app to process actions for') do |app_key|
            Zim::Config.first_app = app_key
          end

          opts.on('-p PARAMETER', '--parameter PARAMETER', 'Arbitrary parameters that can be used by commands') do |parameter|
            index = parameter.index('=')
            if index.nil?
              puts "Parameter '#{parameter}' can not be split with = character. Make sure it is of the form key=value"
              exit
            end
            key = parameter[0, index]
            value = parameter[index + 1, parameter.size]
            Zim::Config.parameters[key] = value
          end

          opts.on('-c', '--changed', 'Only run commands if application is already modified.') do
            Zim::Config.only_modify_changed!
          end

          opts.on('-u', '--unchanged', 'Only run commands if application is not modified.') do
            Zim::Config.only_modify_unchanged!
          end

          opts.on('-v', '--verbose', 'More verbose logging') do
            Zim::Config.log_level = :verbose
          end

          opts.on('-d', '--base-directory DIR', 'Base directory in which source for applications is stored') do |dir|
            Zim::Config.base_directory = dir
          end

          opts.on('-q', '--quiet', 'Be very very quiet, we are hunting wabbits') do
            Zim::Config.log_level = :quiet
          end

          opts.on('-k', '--no-remove-unknown', 'Do not remove unknown directories in in source directory') do
            Zim::Config.keep_unknown = true
          end

          opts.on('-i', '--include TAG', 'Specify application tags that must appear when selecting applications') do |tag|
            Zim::Config.include_tags << tag
          end

          opts.on('-e', '--exclude TAG', 'Specify application tags that must not appear when selecting applications') do |tag|
            Zim::Config.exclude_tags << tag
          end

          opts.on('-f', '--filter CMD', 'Specify command that must return success to include application') do |filter|
            Zim::Config.filters << filter
          end

          opts.on('-h', '--help', 'Display this screen') do
            puts opts
            exit
          end
        end

        optparse.parse!(args)

        begin
          Zim::Config.base_directory
        rescue
          puts 'No base directory defined. Set Zim::Config.base_directory in _zim.rb or on the command line via: --base-directory DIR'
          exit
        end

        if 0 == args.size
          puts "No commands specified. Specify one of:\n#{Zim.commands.sort.collect { |c| "  * #{c.help_text}" }.join("\n")}"
          exit
        end

        unless Zim.current_suite?
          puts 'No suite set. Set one by passing parameters: -s SET'
          exit
        end

        args.each do |command|
          unless Zim.command_by_name?(command)
            puts "Unknown command specified: #{command}"
            exit
          end
        end

        if Zim::Config.verbose?
          puts "Application Suite: #{Zim::Config.suite_directory}"
          puts "Commands specified: #{args.collect { |c| c.to_s }.join(', ')}"
        end

        FileUtils.mkdir_p Zim::Config.suite_directory

        expected_dirs = []

        skip_apps = !Zim::Config.first_app.nil?
        Zim.context do
          Zim.current_suite.applications.each do |app|
            expected_dirs << Zim.dir_for_app(app.name)
            skip_apps = false if !Zim::Config.first_app.nil? && Zim::Config.first_app == app.name
            if skip_apps
              puts "Skipping #{app.name}" if Zim::Config.verbose?
            else
              if Zim::Config.include_tags.size > 0 || Zim::Config.exclude_tags.size > 0
                if Zim::Config.include_tags.size > 0
                  next unless Zim::Config.include_tags.all? { |t| app.tags.include?(t) }
                end
                if Zim::Config.exclude_tags.size > 0
                  next if Zim::Config.exclude_tags.any? { |t| app.tags.include?(t) }
                end
              end
              if Zim::Config.filters.size > 0
                matched = true
                in_app_dir(app.name) do
                  Zim::Config.filters.each do |t|
                    `#{t} 2>&1`
                    matched = false unless $?.exitstatus == 0
                  end
                end
                next unless matched
              end
              if run?(app)
                puts "Processing #{app.name}" unless Zim::Config.quiet?
                in_base_dir do
                  args.each do |key|
                    begin
                      run(key, app.name)
                    rescue Exception => e
                      Zim::Driver.print_command_error(app.name, initial_args, "Error processing stage #{key} on application '#{app.name}'.")
                      raise e
                    end
                  end
                end
              end
            end
          end

          unless Zim::Config.keep_unknown?
            actual_dirs = Dir["#{Zim::Config.suite_directory}/*"]
            unknown_dirs = (actual_dirs - expected_dirs)
            unless unknown_dirs.empty?
              unless Zim::Config.quiet?
                puts 'Removing unknown files/directories in source directory:'
                puts unknown_dirs.collect { |d| "  * #{File.basename(d)}" }.join("\n")
                puts "\n\n"
              end
              unknown_dirs.each do |d|
                puts "Removing #{File.basename(d)}." unless Zim::Config.quiet?
                FileUtils.rm_rf(d)
                puts "Remove completed for #{File.basename(d)}." unless Zim::Config.quiet?
              end
            end
          end
        end
      end

      def print_command_error(app, initial_args, message)
        puts message
        puts 'Fix the problem and rerun the command via:'

        args = []
        skip_next = false
        initial_args.each do |arg|
          if skip_next
            skip_next = false
            next
          end
          if arg == '--first-app'
            skip_next = true
          else
            args << arg
          end
        end

        puts " #{$0} --first-app #{app} #{args.join(' ')} "
      end
    end
  end
end
