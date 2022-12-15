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

    attr_writer :organization_projects

    def organization_projects?
      @organization_projects.nil? ? false : !!@organization_projects
    end

    attr_writer :repository_projects

    def repository_projects?
      @repository_projects.nil? ? false : !!@repository_projects
    end

    attr_writer :skip_updates_on_archived_repositories

    def skip_updates_on_archived_repositories?
      @skip_updates_on_archived_repositories.nil? ? false : !!@skip_updates_on_archived_repositories
    end
  end

  class Branch
    def protect?
      require_status_check? || require_reviews?
    end

    attr_writer :require_reviews

    # Require the branch to have a pull request review before merging?
    def require_reviews?
      @require_reviews.nil? ? false : @require_reviews
    end

    attr_writer :require_status_check

    # Require the branch to have successful status checks before merging?
    def require_status_check?
      @require_status_check.nil? ? false : @require_status_check
    end

    def strict_status_checks=(strict_status_checks)
      self.require_status_check = true
      @strict_status_checks = strict_status_checks
    end

    # Require branches to be up to date before merging?
    def strict_status_checks?
      @strict_status_checks.nil? ? false : @strict_status_checks
    end

    attr_writer :status_check_contexts

    # The list of status checks to require in order to merge into this branch.
    def status_check_contexts
      @status_check_contexts ||= []
    end

    attr_writer :enforce_admins

    def enforce_admins?
      @enforce_admins.nil? ? false : !!@enforce_admins
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
      @password_config_keys ||= [:secret]
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
      @triage_teams = []
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

    def triage_teams=(*triage_teams)
      triage_teams.each do |team|
        add_triage_team(team)
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

    attr_writer :default_branch

    def default_branch
      @default_branch || 'master'
    end

    attr_writer :private

    def private?
      @private.nil? ? true : !!@private
    end

    attr_writer :issues

    def issues?
      @issues.nil? ? false : !!@issues
    end

    attr_writer :projects

    def projects?
      @projects.nil? ? false : !!@projects
    end

    attr_writer :discussions

    def discussions?
      @discussions.nil? ? false : !!@discussions
    end

    attr_writer :archived

    def archived?
      @archived.nil? ? false : !!@archived
    end

    attr_writer :wiki

    def wiki?
      @wiki.nil? ? false : !!@wiki
    end

    attr_writer :allow_squash_merge

    def allow_squash_merge?
      @allow_squash_merge.nil? ? true : !!@allow_squash_merge
    end

    attr_writer :allow_merge_commit

    def allow_merge_commit?
      @allow_merge_commit.nil? ? true : !!@allow_merge_commit
    end

    attr_writer :allow_auto_merge

    def allow_auto_merge?
      @allow_auto_merge.nil? ? false : !!@allow_auto_merge
    end

    # Always suggest updating pull request branches
    # Whenever there are new changes available in the base branch, present an “update branch” option in the pull request.
    attr_writer :allow_update_branch

    def allow_update_branch?
      @allow_update_branch.nil? ? true : !!@allow_update_branch
    end

    attr_writer :allow_rebase_merge

    def allow_rebase_merge?
      @allow_rebase_merge.nil? ? true : !!@allow_rebase_merge
    end

    attr_writer :delete_branch_on_merge

    def delete_branch_on_merge?
      @delete_branch_on_merge.nil? ? true : !!@delete_branch_on_merge
    end

    attr_writer :allow_forking

    # Either true to allow private forks, or false to prevent private forks.
    def allow_forking?
      @allow_forking.nil? ? false : !!@allow_forking
    end

    attr_writer :delete_branch_on_merge

    def delete_branch_on_merge?
      @delete_branch_on_merge.nil? ? true : !!@delete_branch_on_merge
    end

    attr_writer :squash_merge_commit_title

    # The default value for a squash merge commit title:
    #
    # PR_TITLE - default to the pull request's title.
    # COMMIT_OR_PR_TITLE - default to the commit's title (if only one commit) or the pull request's title (when more than one commit).
    def squash_merge_commit_title
      @squash_merge_commit_title.nil? ? 'COMMIT_OR_PR_TITLE' : @squash_merge_commit_title
    end

    attr_writer :squash_merge_commit_message

    # The default value for a squash merge commit message:
    #
    # PR_BODY - default to the pull request's body.
    # COMMIT_MESSAGES - default to the branch's commit messages.
    # BLANK - default to a blank commit message.
    def squash_merge_commit_message
      @squash_merge_commit_message.nil? ? 'COMMIT_MESSAGES' : @squash_merge_commit_message
    end


    attr_writer :merge_commit_title

    # The default value for a merge commit title.
    #
    # PR_TITLE - default to the pull request's title.
    # MERGE_MESSAGE - default to the classic title for a merge message (e.g., Merge pull request #123 from branch-name).
    def merge_commit_title
      @merge_commit_title.nil? ? 'MERGE_MESSAGE' : @merge_commit_title
    end

    attr_writer :merge_commit_message

    # The default value for a merge commit message.
    #
    # PR_TITLE - default to the pull request's title.
    # PR_BODY - default to the pull request's body.
    # BLANK - default to a blank commit message.
    def merge_commit_message
      @merge_commit_message.nil? ? 'PR_TITLE' : @merge_commit_message
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

    def triage_teams
      @triage_teams.dup
    end

    def triage_team_by_name?(name)
      @triage_teams.any? { |team| team.name.to_s == name.to_s }
    end

    def add_triage_team(team)
      raise "Unable to add triage team '#{team}' to repository #{self.qualified_name} as it is a personal account" if self.organization.is_user_account?
      team = team.is_a?(Team) ? team : organization.team_by_name(team)
      @triage_teams << team
      team.triage_repositories << self
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
      admin_team_by_name?(name) || push_team_by_name?(name) || pull_team_by_name?(name) || triage_team_by_name?(name)
    end
  end

  class Team
    def pre_init
      @admin_repositories = []
      @pull_repositories = []
      @push_repositories = []
      @triage_repositories = []
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

    # List of repositories with triage access. Is automatically updated
    def triage_repositories
      @triage_repositories
    end
  end
end
