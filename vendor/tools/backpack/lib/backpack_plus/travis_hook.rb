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
    class << self
      def enable(options = {})
        if options[:access_token]
          Travis.access_token = options[:access_token]
        else
          configure_travis_token
        end
        Backpack.context.add_hook(TravisHook.new)
      end

      # Try to authenticate against travis using github credentials
      # and retrieve the TravisCI Token from travis using these mechanisms
      def configure_travis_token
        info = Netrc.read Octokit::Default.netrc_file
        endpoint_url = 'github.com'
        creds = info[endpoint_url]
        if creds.nil?
          Backpack.error("Error loading credentials from netrc file for #{endpoint_url}")
        else
          require 'travis/tools/github'

          creds = creds.to_a
          login = creds.shift
          password = creds.shift

          # drop_token will make the token a temporary one
          github = Travis::Tools::Github.new(drop_token: true) do |g|
            g.ask_login = -> { login }
            g.ask_password = -> { password }
            g.ask_otp = -> { nil }
          end

          github.with_token do |token|
            Travis.github_auth(token)
          end
        end
      end
    end

    def post_repository(repository)
      if Travis.access_token && !repository.private?
        r =
          begin
            Travis::Repository.find(repository.qualified_name)
          rescue Travis::Client::NotFound
            Travis.user.sync unless Travis.user.is_syncing
            while Travis.user.is_syncing
              sleep 2
              Travis.user.reload
            end
            begin
              Travis::Repository.find(repository.qualified_name)
            rescue Travis::Client::NotFound
              raise "Failed to locate repository #{repository.qualified_name} after syncing. This probably means you need to authorize access of the TravisCI application to the organization"
            end
          end
        should_be_enabled = repository.tags.include?('travis')
        active = !!r.attributes['active']
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
