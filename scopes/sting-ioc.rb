Belt.scope('sting-ioc') do |o|
  o.project('sting', :description => 'A fast, easy to use, compile-time dependency injection toolkit', :tags => %w(codecov travis issues homepage=homepage=https://sting-ioc.github.io))
  # TODO: sting-ioc.github.io has several custom deploy keys. Figure out a way to automate this?
  o.project('sting-ioc.github.io', :description => 'Sting website', :tags => %w(pages homepage=https://sting-ioc.github.io zim=no))

  o.projects.each do |project|
    project.tags << "name=#{project.name}"
  end
end
