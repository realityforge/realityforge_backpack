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

module Backpack #nodoc
  class Driver
    class << self
      def converge(context, organization)
        run_hook(context, :pre_organization, organization)
        converge_organization(context, organization) unless organization.is_user_account?
        converge_repositories(context, organization)
        converge_subscriptions(context, organization)
        converge_hooks(context, organization)
        run_hook(context, :post_organization, organization)
      end

      def converge_organization(context, organization)
        remote_organization = context.client.organization(organization.name)

        update = false
        update = true if remote_organization['has_organization_projects'].to_s != organization.organization_projects?.to_s
        update = true if remote_organization['has_repository_projects'].to_s != organization.repository_projects?.to_s

        if update
          puts "Updating organization #{organization.name}"
          context.client.update_organization(organization.name,
                                             :has_organization_projects => organization.organization_projects?,
                                             :has_repository_projects => organization.repository_projects?)
        end

        converge_teams(context, organization)
      end

      def converge_teams(context, organization)
        remote_teams = context.client.organization_teams(organization.name)
        remote_teams.each do |remote_team|
          name = remote_team['name']
          if organization.team_by_name?(name)
            team = organization.team_by_name(name)
            team.github_id = remote_team['id']
            converge_team(context, team, remote_team)
          else
            puts "Removing team named #{name}"
            context.client.delete_team(remote_team['id'])
          end
        end
        organization.teams.each do |team|
          unless remote_teams.any? {|r| r['name'] == team.name}
            puts "Creating team #{team.name}"
            remote_team = context.client.create_team(organization.name, :name => team.name, :permission => team.permission)
            team.github_id = remote_team['id']
          end
        end
      end

      def converge_team(context, team, remote_team)
        update = false
        update = true if remote_team['permission'] != team.permission

        if update
          puts "Updating team #{team.name}"
          context.client.update_team(team.github_id, :permission => team.permission)
        end
      end

      def converge_repositories(context, organization)
        remote_repositories =
          organization.is_user_account? ?
            (
              context.client.login == organization.name ?
                context.client.repositories.select{|r| r[:full_name] == "#{organization.name}/#{r[:name]}"} :
                context.client.repositories(organization.name)
            ) :
            context.client.organization_repositories(organization.name)
        remote_repositories.each do |remote_repository|
          name = remote_repository['name']
          if organization.repository_by_name?(name)
            repository = organization.repository_by_name(name)
            run_hook(context, :pre_repository, repository)
            converge_repository(context.client, repository, context.client.repository(remote_repository['full_name']))
            run_hook(context, :post_repository, repository)
          else
            puts "WARNING: Unmanaged repository detected named '#{name}'"
          end
        end
        organization.repositories.each do |repository|
          unless remote_repositories.any? {|r| r['name'] == repository.name}
            run_hook(context, :pre_repository, repository)
            puts "Creating repository #{repository.name}"
            config = {
              :description => repository.description,
              :homepage => repository.homepage,
              :private => repository.private?,
              :has_issues => repository.issues?,
              :has_projects => repository.projects?,
              :archived => repository.archived?,
              :allow_squash_merge => repository.allow_squash_merge?,
              :allow_merge_commit => repository.allow_merge_commit?,
              :allow_rebase_merge => repository.allow_rebase_merge?,
              :delete_branch_on_merge => repository.delete_branch_on_merge?,
              :has_wiki => repository.wiki?
            }
            config[:organization] = repository.organization.name unless organization.is_user_account?
            remote_repositories << context.client.create_repository(repository.name, config)
            run_hook(context, :post_repository, repository)
          end
        end
        unless organization.is_user_account?
          team_map = {}
          context.client.organization_teams(organization.name).each do |remote_team|
            id = remote_team['id']
            team_map[id] = context.client.team_repositories(id)
          end

          remote_repositories.each do |remote_repository|
            repository_name = remote_repository['name']
            repository = organization.repository_by_name?(repository_name) ? organization.repository_by_name(repository_name) : nil

            repository_full_name = "#{organization.name}/#{repository_name}"
            remote_teams =
              begin
                context.client.repository_teams(repository_full_name, :accept => 'application/vnd.github.hellcat-preview+json')
              rescue Octokit::NotFound
                []
              end
            remote_teams.each do |remote_team|
              name = remote_team['name']
              if repository && repository.team_by_name?(name)
                permission =
                  repository.admin_team_by_name?(name) ? 'admin' :
                    repository.push_team_by_name?(name) ? 'push' :
                      repository.pull_team_by_name?(name) ? 'pull' : 'triage'

                team = organization.team_by_name(name)
                update = false

                permissions = team_map[team.github_id].select {|t| t['name'] == repository.name}[0]['permissions']

                update = true if (permission == 'admin' && !(permissions[:pull] && permissions[:push] && permissions[:admin]))
                update = true if (permission == 'push' && !(permissions[:pull] && permissions[:push] && !permissions[:admin]))
                update = true if (permission == 'pull' && !(permissions[:pull] && !permissions[:push] && !permissions[:admin]))
                update = true if (permission == 'triage' && !(permissions[:triage]))

                if update
                  puts "Updating repository team #{team.name} on #{repository_full_name}"
                  context.client.add_team_repository(team.github_id, repository_full_name, :permission => permission)
                end
              else
                puts "Removing repository team #{remote_team['name']} from #{repository_full_name}"
                context.client.remove_team_repository(remote_team['id'], repository_full_name)
                remote_teams.delete(remote_team)
              end
            end
            %w(admin pull push triage).each do |permission|
              repository.send(:"#{permission}_teams").each do |team|
                unless remote_teams.any? {|remote_team| remote_team['name'] == team.name}
                  puts "Adding #{permission} repository team #{team.name} to #{repository.name}"
                  context.client.add_team_repository(team.github_id, repository_full_name, :permission => permission)
                end
              end if repository
            end
          end
        end
      end

      def converge_repository(client, repository, remote_repository)
        if 'true' == remote_repository['archived'].to_s && repository.organization.skip_updates_on_archived_repositories?
          return
        end

        update = false
        update = true if remote_repository['description'].to_s != repository.description.to_s
        update = true if remote_repository['homepage'].to_s != repository.homepage.to_s
        update = true if remote_repository['private'].to_s != repository.private?.to_s
        update = true if remote_repository['has_issues'].to_s != repository.issues?.to_s
        update = true if remote_repository['has_discussions'].to_s != repository.discussions?.to_s
        update = true if repository.organization.repository_projects? && remote_repository['has_projects'].to_s != repository.projects?.to_s
        update = true if remote_repository['has_wiki'].to_s != repository.wiki?.to_s
        update = true if remote_repository['default_branch'].to_s != repository.default_branch.to_s
        update = true if remote_repository['allow_squash_merge'].to_s != repository.allow_squash_merge?.to_s
        update = true if remote_repository['allow_merge_commit'].to_s != repository.allow_merge_commit?.to_s
        update = true if remote_repository['allow_rebase_merge'].to_s != repository.allow_rebase_merge?.to_s
        update = true if remote_repository['allow_update_branch'].to_s != repository.allow_update_branch?.to_s
        update = true if remote_repository['allow_auto_merge'].to_s != repository.allow_auto_merge?.to_s
        update = true if remote_repository['delete_branch_on_merge'].to_s != repository.delete_branch_on_merge?.to_s
        if remote_repository['archived'].to_s != repository.archived?.to_s
          if 'true' == remote_repository['archived'].to_s
            raise "Can not un-archive repository #{repository.name} via the API"
          end
          update = true
        end

        if update
          if 'true' == remote_repository['archived'].to_s
            raise "Can not modify repository #{repository.name} as it is archived."
          end

          puts "Updating repository #{repository.name}"
          repository_options = { :description => repository.description,
                                 :homepage => repository.homepage,
                                 :default_branch => repository.default_branch,
                                 :private => repository.private?,
                                 :has_issues => repository.issues?,
                                 :has_projects => repository.projects?,
                                 :has_discussions => repository.discussions?,
                                 :archived => repository.archived?,
                                 :allow_squash_merge => repository.allow_squash_merge?,
                                 :allow_merge_commit => repository.allow_merge_commit?,
                                 :allow_auto_merge => repository.allow_auto_merge?,
                                 :allow_rebase_merge => repository.allow_rebase_merge?,
                                 :allow_update_branch => repository.allow_update_branch?,
                                 :delete_branch_on_merge => repository.delete_branch_on_merge?,
                                 :has_wiki => repository.wiki? }
          # Can not specify has_projects option if repository projects are disabled, even if setting it to false
          repository_options[:has_projects] = repository.projects? unless repository.organization.repository_projects?
          client.edit_repository(remote_repository['full_name'], repository_options)
        end
        remote_branches = client.branches(repository.qualified_name)
        remote_branches.each do |remote_branch|
          branch_name = remote_branch['name']
          branch = repository.branch_by_name?(branch_name) ? repository.branch_by_name(branch_name) : nil

          protection =
            begin
              client.branch_protection(repository.qualified_name, branch_name, :accept => 'application/vnd.github.luke-cage-preview+json')
            rescue Octokit::BranchNotProtected
              nil
            rescue Octokit::Forbidden
              nil
            rescue Octokit::NotFound
              nil
            end
          if branch&.protect?
            protect = false
            if branch.require_status_check?
              protect = true if protection.nil?
              if protection
                protect = true unless protection[:required_status_checks]
                if protection[:required_status_checks]
                  checks = protection[:required_status_checks]
                  protect = true if checks[:strict] != branch.strict_status_checks?
                  protect = true if checks[:contexts].sort != branch.status_check_contexts.sort
                end
              end
            end
            if branch.require_reviews?
              protect = true if protection.nil?
              if protection
                protect = true unless protection[:required_pull_request_reviews]
              end
            end
            protect = true if (protection && protection[:enforce_admins] && protection[:enforce_admins][:enabled]) != branch.enforce_admins?

            if protect
              puts "Updating protection on branch #{branch.name} in repository #{repository.qualified_name}"
              config = { :accept => 'application/vnd.github.luke-cage-preview+json' }
              config[:required_status_checks] = { :strict => branch.strict_status_checks?, :contexts => branch.status_check_contexts } if branch.require_status_check?
              config[:required_pull_request_reviews] = branch.require_reviews? ? {} : nil
              config[:enforce_admins] = branch.enforce_admins?
              client.protect_branch(repository.qualified_name, branch.name, config)
            end
          elsif protection
            puts "Un-protecting branch #{branch_name} in repository #{repository.qualified_name}"
            client.unprotect_branch(repository.qualified_name, branch_name, :accept => Octokit::Preview::PREVIEW_TYPES[:branch_protection])
          end
        end
      end

      def converge_subscriptions(context, organization)
        organization.repositories.select(&:archived?).each do |repository|
          begin
            context.client.subscription(repository.qualified_name)
            puts "Removing subscription from archived repository #{repository.qualified_name}"
            context.client.delete_subscription(repository.qualified_name)
          rescue Octokit::NotFound
            # ignored
          end
          begin
            if context.client.starred?(repository.qualified_name) && context.client.unstar(repository.qualified_name)
              puts "Removed star from archived repository #{repository.qualified_name}"
            end
          rescue Octokit::NotFound
            # ignored
          end
        end
      end

      def converge_hooks(context, organization)
        organization.repositories.each do |repository|
          remote_hooks = context.client.hooks(repository.qualified_name)
          repository.hooks.each do |hook|
            candidate_hooks = remote_hooks.select do |r|
              if hook.singleton?
                r['name'] == hook.name
              else
                r['name'] == hook.type && r['config'][hook.config_key] == hook.config[hook.config_key]
              end
            end
            if candidate_hooks.size > 1
              raise "Multiple existing hooks matched hook #{hook.name}. #{candidate_hooks.inspect}"
            end
            if candidate_hooks.empty?
              puts "Creating #{hook.name} hook on repository #{repository.qualified_name}"
              context.client.create_hook(repository.qualified_name,
                                         hook.type,
                                         hook.config,
                                         :events => hook.events,
                                         :active => hook.active?)
            else
              remote_hook = candidate_hooks[0]

              update = false

              if remote_hook[:active] != hook.active?
                update = true
                puts "Updating #{hook.name} hook on repository #{repository.qualified_name} to update active status to #{hook.active?}"
              end

              if remote_hook[:events].sort != hook.events.sort
                update = true
                puts "Updating #{hook.name} hook on repository #{repository.qualified_name} to update events from #{remote_hook[:events].sort.inspect} to #{hook.events.sort.inspect}"
              end
              unless hash_same(remote_hook[:config].to_h, hook.config, hook.password_config_keys)
                update = true
                puts "Updating #{hook.name} hook on repository #{repository.qualified_name} to update config from #{remote_hook[:config].to_h.inspect} to #{hook.config.inspect} (Password keys #{hook.password_config_keys.inspect})"
              end

              if update
                context.client.edit_hook(repository.qualified_name,
                                         remote_hook[:id],
                                         hook.type,
                                         hook.config,
                                         :events => hook.events,
                                         :active => hook.active?)
              end
              remote_hooks.delete(remote_hook)
            end
          end
          remote_hooks.each do |remote_hook|
            puts "Removing #{remote_hook['name']}:#{remote_hook['id']} hook on repository #{repository.qualified_name}. Config: #{remote_hook.inspect}"
            context.client.remove_hook(repository.qualified_name, remote_hook['id'])
          end
        end
      end

      def hash_same(hash1, hash2, skip_keys)
        return false if hash1.size != hash2.size
        hash1.keys.each do |key|
          next if skip_keys.include?(key.to_s)
          return false if hash1[key] != hash2[key]
        end
        true
      end

      def run_hook(context, hook_key, element)
        context.hooks.each do |hook|
          hook.send(hook_key, element)
        end
      end
    end
  end
end
