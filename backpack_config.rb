BackpackPlus::TravisHook.enable

Backpack.organization('realityforge') do |o|
  o.is_user_account = true

  require File.expand_path('belt_config.rb')

  Belt.scope_by_name(o.name).projects.each do |project|
    tags = project.tags.dup
    issues = project.tags.include?('issues')
    homepage = project.tag_value('homepage')
    o.repository(project.name,
                 :description => project.description,
                 :homepage => homepage,
                 :issues => issues,
                 :tags => tags)
  end

  o.repositories.each do |repository|
    repository.private = false

    repository.email_hook('dse-iris-scm@stocksoftware.com.au') if repository.tags.include?('notify:stock')
    repository.docker_hook if repository.tags.include?('docker-hub')
    # GITHUB_TOKEN is an environment variable that should be defined in `_backpack.rb` file
    repository.travis_hook('realityforge', ENV['GITHUB_TOKEN']) if repository.tags.include?('travis')

    repository.tag_values('protect').each do |branch|
      repository.branch(branch, :require_reviews => true)
    end
  end
end
