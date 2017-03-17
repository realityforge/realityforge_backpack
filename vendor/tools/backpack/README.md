# Backpack

Backpack is a very simple tool that helps you manage GitHub organizations declaratively.
Using a simplified DSL you describe the GitHub organizational structure and then you run
converge action to make the organization look like the description.

## Configuration

Backpack at this stage is under heavy development and the configuration is via explicit code. In this scenario
it is recommended that you create an executable script that declares the organization(s) and explicitly converges
the organizations. In the future it is likely that there will be additional tooling surrounding this process.
A script should look look like:

    require 'backpack'

    Backpack.organization('my-awesome-organization') do |o|
      o.team('TeamA')
      o.team('TeamB')
      o.team('Tools')

      # Repository only TeamA can push to
      o.repository('repo-1', :description => 'does stuff', :push_teams => ['TeamA'])

      # Repository TeamA can push to and TeamB can read from
      o.repository('repo-2', :push_teams => ['TeamA'], :pull_teams => ['TeamB'])

      # Repository both TeamA and TeamB can write to
      o.repository('repo-3', :push_teams => ['TeamA','TeamB'])

      o.repositories.each do |repository|
        # The tools (i.e. Jenkins and friends) can always read from every repository
        repository.add_pull_team('Tools')
      end
    end

    # Connect to public github using credentials in .netrc
    # Note: auto_paginate is required to be true
    client = Octokit::Client.new(:netrc => true, :auto_paginate => true)
    client.login

    # Actually converge the organization
    Backpack::Driver.converge(client, Backpack.organization_by_name('my-awesome-organization'))

## Development

Backpack uses the underlying [Octokit](http://octokit.github.io/octokit.rb/) library to interact with
the github API. It is reasonably easy to use but does require some reading of API docs and some familiarity
with the [Github V3 API](https://developer.github.com/v3/). Before diving into the code it is best to
review this before hacking on this project.
