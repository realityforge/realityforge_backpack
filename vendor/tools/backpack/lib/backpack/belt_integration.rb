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

module Backpack # nodoc

  # Class used to integrate with belt
  module Belt
    class << self
      def load_organizations_from_belt(filename = 'belt_config.rb')
        require File.expand_path(filename)
        copy_organizations_from_belt_scopes
      end

      def copy_organizations_from_belt_scopes
        ::Belt.scopes.each do |scope|
          copy_organization_from_belt_scope(scope)
        end
      end

      # Copy all the applications defined in belt scope and
      # define them as repositories.
      #
      # Belt projects are omitted if they have a tag such as;
      # * backpack=no
      def copy_organization_from_belt_scope(scope)
        ::Backpack.organization(scope.name) do |o|
          scope.projects.each do |project|
            next if project.tags.include?('backpack=no')
            tags = project.tags.dup
            private = project.tags.include?('private')
            issues = project.tags.include?('issues')
            homepage = project.tag_value('homepage')
            o.repository(project.name,
                         :description => project.description,
                         :private => private,
                         :homepage => homepage,
                         :issues => issues,
                         :tags => tags)
          end
        end
      end
    end
  end
end
