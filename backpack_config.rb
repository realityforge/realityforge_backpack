BackpackPlus::TravisHook.enable

Backpack::Belt.load_organizations_from_belt

Backpack.organizations.each do |o|
  o.is_user_account = true

  o.repositories.each do |repository|
    repository.private = false

    repository.email_hook('dse-iris-scm@stocksoftware.com.au') if repository.tags.include?('notify:stock')
    repository.docker_hook if repository.tags.include?('docker-hub')
    # GITHUB_TOKEN is an environment variable that should be defined in `_backpack.rb` file
    repository.travis_hook('realityforge', ENV['GITHUB_TOKEN']) if repository.tags.include?('travis')

    if repository.tags.include?('codecov')
      token = ENV["CODECOV_#{repository.name}"]
      raise "Unable to locate CODECOV token for repository #{repository.name}" unless token
      repository.codecov_hook(token)
    end

    repository.tag_values('protect').each do |branch|
      repository.branch(branch, :require_reviews => true)
    end
  end
end
