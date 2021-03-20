require 'belt'

Dir["#{File.expand_path('.')}/scopes/*.rb"].each(&method(:require))

Belt.scopes.each do |o|
  o.projects.each do |project|
    project.tags << "name=#{project.name}"
  end
end
