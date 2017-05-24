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

  # Class used to integrate with belt
  module Belt
    class << self
      def load_suites_from_belt(filename = 'belt_config.rb')
        require File.expand_path(filename)
        copy_suites_from_belt_scopes
      end

      def copy_suites_from_belt_scopes
        ::Belt.scopes.each do |scope|
          copy_suite_from_belt_scope(scope)
        end
      end

      # Copy all the applications defined in belt scope and
      # define them as applications.
      #
      # Belt projects are omitted if they have a tag such as;
      # * historic
      # * external
      # * deprecated
      # * zim=no
      def copy_suite_from_belt_scope(scope)
        ::Zim.suite(scope.name) do |suite|
          scope.projects.each do |project|
            next if project.tags.include?('historic')
            next if project.tags.include?('external')
            next if project.tags.include?('deprecated')
            next if project.tags.include?('zim=no')
            git_url = project.tag_value('git_url') || "https://github.com/#{scope.name}/#{project.name}.git"
            suite.application(project.name, 'git_url' => git_url, 'tags' => project.tags.dup)
          end
        end
      end
    end
  end
end
