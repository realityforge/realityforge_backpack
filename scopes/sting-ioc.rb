Belt.scope('sting-ioc') do |o|
  o.project('sting', :description => 'A fast, easy to use, compile-time dependency injection toolkit', :tags => %w(codecov travis issues homepage=https://sting.github.io))
  # TODO: sting.github.io has several custom deploy keys. Figure out a way to automate this?
  o.project('sting.github.io', :description => 'Arez website', :tags => %w(pages homepage=https://sting.github.io zim=no))

  o.projects.each do |project|
    project.tags << "name=#{project.name}"
  end
end
