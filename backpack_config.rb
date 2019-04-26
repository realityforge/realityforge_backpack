BackpackPlus::TravisHook.enable(:access_token => ENV['TRAVIS_ACCESS_TOKEN'])

Backpack::Belt.load_organizations_from_belt

Backpack.organizations.each do |o|
  o.is_user_account = o.name == 'realityforge'

  o.repositories.each do |repository|
    repository.private = repository.tags.include?('private')
    repository.archived = true if repository.tags.include?('historic')
    repository.wiki = true if repository.tags.include?('wiki')

    if repository.tags.include?('notify:stock')
      #TODO: As of Feb 06 2019 there is no way to automate email notifications, we just need to configure via Web UI :(
      #repository.notifications << 'dse-iris-scm@stocksoftware.com.au'
    end
    # TODO: Replace docker hook with ... something?
    #repository.docker_hook if repository.tags.include?('docker-hub')
    # GITHUB_TOKEN is an environment variable that should be defined in `_backpack.rb` file
    repository.travis_hook('realityforge', ENV['GITHUB_TOKEN']) if repository.tags.include?('travis')

    if repository.tags.include?('codecov')
      token = ENV["CODECOV_#{repository.name}"]
      if token
        repository.codecov_hook(token)
      else
        puts "Unable to locate CODECOV token for repository #{repository.name}. Skipping Codecov setup."
        repository.codecov_hook('00000000-0000-0000-0000-000000000000')
      end
    end

    repository.tag_values('protect').each do |branch|
      repository.branch(branch, :require_reviews => true)
    end
  end
end
