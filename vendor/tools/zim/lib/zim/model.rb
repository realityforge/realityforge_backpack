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
  Reality::Logging.configure(Zim, ::Logger::WARN)

  Reality::Model::Repository.new(:Zim, Zim) do |r|
    r.model_element(:command, nil, :custom_initialize => true)
    r.model_element(:suite)
    r.model_element(:application, :suite)
  end

  def self.command(name, options = {}, &block)
    Command.new(name, options, &block)
  end

  # Class used to represent commands within zim
  class Command
    attr_accessor :description
    attr_accessor :action

    def initialize(name, options = {}, &block)
      options = options.dup
      options[:in_app_dir] = true if options[:in_app_dir].nil?
      options[:description] = Zim.pop_description
      options[:action] = block

      perform_init(name, options)
    end

    def help_text
      @description.nil? ? self.name.to_s : "#{name} : #{@description}"
    end

    attr_writer :in_app_dir

    def in_app_dir?
      @in_app_dir.nil? ? true : !!@in_app_dir
    end

    def run(app)
      if in_app_dir?
        Zim.in_app_dir(app) do
          action.call(app)
        end
      else
        Zim.in_base_dir do
          action.call(app)
        end
      end
    end
  end

  class Suite
    def pre_init
      @directory = self.name
      @base_git_url = nil
    end

    attr_accessor :directory

    attr_writer :base_git_url

    def base_git_url
      Zim.error('Attempted to invoke base_git_url without out setting value.') if @base_git_url.nil?
      @base_git_url
    end
  end

  class Application
    attr_writer :git_url

    attr_writer :tags

    def tags
      @tags ||= []
    end

    def git_url
      git_url = @git_url || self.key.to_s
      git_url = "#{source_tree.base_git_url}/#{git_url}.git" unless git_url.include?(':')
      git_url
    end
  end
end
