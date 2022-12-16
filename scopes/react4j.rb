Belt.scope('react4j') do |o|
  o.project('react4j', :description => 'An opinionated react java binding', :tags => %w(travis topics=frontend-framework,gwt,java,react issues homepage=https://react4j.github.io))
  o.project('react4j.github.io', :description => 'React4j website', :tags => %w(pages homepage=https://react4j.github.io zim=no))
  o.project('react4j-todomvc', :description => 'React4j TodoMVC implementation', :tags => %w(travis homepage=https://react4j.github.io/docs/todomvc.html zim:branches=raw,arez,dagger,sting,spritz,sting_bazel,raw_bazel_j2cl,sting_maven,sting_maven_j2cl))
  o.project('react4j-flux-challenge', :description => 'React4j Flux Challenge implementation', :tags => %w(travis))
  o.project('react4j-drumloop', :description => 'A React4j experimental drum machine', :tags => %w(travis homepage=https://react4j.github.io/drumloop))
  o.project('react4j-webspeechdemo', :description => 'React4j WebSpeech Demo', :tags => %w(travis homepage=https://react4j.github.io/webspeechdemo))
  o.project('react4j-heart-rate-monitor', :description => 'React4j Heart Rate Monitor', :tags => %w(travis homepage=https://react4j.github.io/heart-rate-monitor))
  o.project('react4j-vchat', :description => 'React4j Video Chat Demo', :tags => %w(travis homepage=https://react4j.github.io/vchat))

  # Historic projects
  o.project('react4j-widget', :description => 'React4j interoperability with GWT Widget API', :tags => %w(historic))
  o.project('react4j-windowportal', :description => 'React4j portal that renders into a Window', :tags => %w(historic))
end
