Belt.scope('react4j') do |o|
  o.project('react4j', :description => 'An opinionated react java binding', :tags => %w(travis issues homepage=https://react4j.github.io))
  # TODO: react4j.github.io has several custom deploy keys. Figure out a way to automate this?
  o.project('react4j.github.io', :description => 'React4j website', :tags => %w(pages homepage=https://react4j.github.io zim=no))
  o.project('react4j-todomvc', :description => 'React4j TodoMVC implementation', :tags => %w(travis homepage=https://react4j.github.io/docs/todomvc.html zim:branches=raw,arez,dagger,sting,spritz,raw_bazel,sting_bazel,raw_bazel_j2cl,sting_maven,sting_maven_j2cl))
  o.project('react4j-flux-challenge', :description => 'React4j Flux Challenge implementation', :tags => %w(travis))
  o.project('react4j-drumloop', :description => 'A React4j experimental drum machine', :tags => %w(travis))

  # Historic projects
  o.project('react4j-widget', :description => 'React4j interoperability with GWT Widget API', :tags => %w(historic))
  o.project('react4j-windowportal', :description => 'React4j portal that renders into a Window', :tags => %w(historic))

  o.projects.each do |project|
    project.tags << "name=#{project.name}"
  end
end
