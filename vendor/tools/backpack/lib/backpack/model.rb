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

module Backpack
  Reality::Logging.configure(Backpack, ::Logger::WARN)

  Reality::Model::Repository.new(:Backpack, Backpack) do |r|
    r.model_element(:organization)
    r.model_element(:team, :organization)
    r.model_element(:repository, :organization)
    r.model_element(:branch, :repository, :access_method => :branches)
    r.model_element(:repository_hook, :repository, :access_method => :hooks, :inverse_access_method => :hook)
  end

  class Organization
    attr_writer :is_user_account

    def is_user_account?
      @is_user_account.nil? ? false : !!@is_user_account
    end
  end

  class Branch
    def protect?
      required_status_checks?
    end

    attr_writer :required_status_checks

    # Require the branch to have successful status checks before merging?
    def required_status_checks?
      @required_status_checks.nil? ? false : @required_status_checks
    end

    def strict_status_checks=(strict_status_checks)
      self.required_status_checks = true
      @strict_status_checks = strict_status_checks
    end

    # Require branches to be up to date before merging?
    def strict_status_checks?
      @strict_status_checks.nil? ? false : @strict_status_checks
    end

    def status_checks_include_admins=(status_checks_include_admins)
      self.required_status_checks = true
      @status_checks_include_admins = status_checks_include_admins
    end

    # Enforce required status checks for repository administrators.
    def status_checks_include_admins?
      @status_checks_include_admins.nil? ? false : @status_checks_include_admins
    end

    attr_writer :status_check_contexts

    # The list of status checks to require in order to merge into this branch.
    def status_check_contexts
      @status_check_contexts ||= []
    end
  end

  class RepositoryHook
    def pre_init
      @events = ['push']
      @active = true
      @config_key = nil
      @config = {}
    end

    attr_writer :type

    def type
      @type.nil? ? self.name : @type
    end

    attr_writer :active

    def active?
      !!@active
    end

    def singleton?
      @config_key.nil?
    end

    # Key inside config data that uniquely identifies hook
    attr_accessor :config_key

    attr_writer :password_config_keys

    def password_config_keys
      @password_config_keys ||= []
    end

    attr_accessor :events
    attr_accessor :config
  end

  class Repository
    def pre_init
      @tags = []

      @admin_teams = []
      @pull_teams = []
      @push_teams = []
    end

    def qualified_name
      "#{self.organization.name}/#{self.name}"
    end

    def admin_teams=(*admin_teams)
      admin_teams.each do |team|
        add_admin_team(team)
      end
    end

    def push_teams=(*push_teams)
      push_teams.each do |team|
        add_push_team(team)
      end
    end

    def pull_teams=(*pull_teams)
      pull_teams.each do |team|
        add_pull_team(team)
      end
    end

    attr_accessor :tags

    def tag_value(key)
      self.tags.each do |tag|
        if tag =~ /^#{Regexp.escape(key)}=/
          return tag[(key.size + 1)...100000]
        end
      end
      nil
    end

    def tag_values(key)
      values = []
      self.tags.each do |tag|
        if tag =~ /^#{Regexp.escape(key)}=/
          values << tag[(key.size + 1)...100000]
        end
      end
      values
    end

    attr_writer :description

    def description
      @description || ''
    end

    attr_writer :homepage

    def homepage
      @homepage || ''
    end

    attr_writer :private

    def private?
      @private.nil? ? true : !!@private
    end

    attr_writer :issues

    def issues?
      @issues.nil? ? false : !!@issues
    end

    attr_writer :wiki

    def wiki?
      @wiki.nil? ? false : !!@wiki
    end

    attr_writer :downloads

    def downloads?
      @downloads.nil? ? false : !!@downloads
    end

    def admin_teams
      @admin_teams.dup
    end

    def admin_team_by_name?(name)
      @admin_teams.any? { |team| team.name.to_s == name.to_s }
    end

    def add_admin_team(team)
      raise "Unable to add admin team '#{team}' to repository #{self.qualified_name} as it is a personal account" if self.organization.is_user_account?
      team = team.is_a?(Team) ? team : organization.team_by_name(team)
      @admin_teams << team
      team.admin_repositories << self
      team
    end

    def pull_teams
      @pull_teams.dup
    end

    def pull_team_by_name?(name)
      @pull_teams.any? { |team| team.name.to_s == name.to_s }
    end

    def add_pull_team(team)
      raise "Unable to add pull team '#{team}' to repository #{self.qualified_name} as it is a personal account" if self.organization.is_user_account?
      team = team.is_a?(Team) ? team : organization.team_by_name(team)
      @pull_teams << team
      team.pull_repositories << self
      team
    end

    def push_teams
      @push_teams.dup
    end

    def push_team_by_name?(name)
      @push_teams.any? { |team| team.name.to_s == name.to_s }
    end

    def add_push_team(team)
      raise "Unable to add push team '#{team}' to repository #{self.qualified_name} as it is a personal account" if self.organization.is_user_account?
      team = team.is_a?(Team) ? team : organization.team_by_name(team)
      @push_teams << team
      team.push_repositories << self
      team
    end

    def team_by_name?(name)
      admin_team_by_name?(name) || push_team_by_name?(name) || pull_team_by_name?(name)
    end
  end

  class Team
    def pre_init
      @admin_repositories = []
      @pull_repositories = []
      @push_repositories = []
      @permission = 'pull'
      raise "Unable to define team for personal account #{self.organization.name}" if self.organization.is_user_account?
    end

    attr_accessor :permission

    # This id begins null and is populated during converge with the actual github id
    attr_accessor :github_id

    # List of repositories with admin access. Is automatically updated
    def admin_repositories
      @admin_repositories
    end

    # List of repositories with pull access. Is automatically updated
    def pull_repositories
      @pull_repositories
    end

    # List of repositories with push access. Is automatically updated
    def push_repositories
      @push_repositories
    end
  end
end
