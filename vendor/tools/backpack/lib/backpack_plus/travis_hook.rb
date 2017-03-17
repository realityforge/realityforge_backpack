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

module BackpackPlus
  class TravisHook < Backpack::BaseHook

    def post_repository(repository)
      if Travis.access_token

        r =
          begin
            Travis::Repository.find(repository.qualified_name)
          rescue Travis::Client::NotFound
            Travis.user.sync
            Travis::Repository.find(repository.qualified_name)
          end
        should_be_enabled = repository.tags.include?('travis')
        active = r.attributes['active']
        if should_be_enabled != active
          if should_be_enabled
            puts "Enabling hook on travis for repository #{repository.qualified_name}"
            r.enable
          else
            puts "Disabling hook on travis for repository #{repository.qualified_name}"
            r.disable
          end
        end
      end
    end
  end
end
