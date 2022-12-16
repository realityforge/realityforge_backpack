Backpack::Belt.load_organizations_from_belt

Backpack.organizations.each do |o|
  o.is_user_account = o.name == 'realityforge'
  o.skip_updates_on_archived_repositories = true
  o.private_forks = false

  o.repositories.each do |repository|
    repository.private = repository.tags.include?('private')
    repository.archived = true if repository.tags.include?('historic')

    if repository.tags.include?('notify:stock')
      #TODO: As of Feb 06 2019 there is no way to automate email notifications, we just need to configure via Web UI :(
      #repository.notifications << 'dse-iris-scm@stocksoftware.com.au'
    end

    repository.tag_values('protect').each do |branch|
      repository.branch(branch, :require_reviews => true)
    end
  end
end
