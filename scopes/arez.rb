Belt.scope('arez') do |o|
  o.project('arez', :description => 'Fast, easy, reactive state', :tags => %w(codecov travis issues homepage=https://arez.github.io))
  # TODO: arez.github.io has several custom deploy keys. Figure out a way to automate this?
  o.project('arez.github.io', :description => 'Arez website', :tags => %w(pages homepage=https://arez.github.io zim=no))
  o.project('arez-dom', :description => 'Arez browser components that make DOM properties observable', :tags => %w(travis issues homepage=https://arez.github.io/dom))
  o.project('arez-promise', :description => 'Arez component that wraps a Promise and makes it observable', :tags => %w(travis issues homepage=https://arez.github.io/promise))
  o.project('arez-spytools', :description => 'Arez utilities that enhance the spy capabilities', :tags => %w(travis issues homepage=https://arez.github.io/spytools))
  o.project('arez-devtools', :description => 'Browser-based Arez DevTools', :tags => %w(travis issues))

  # Historic projects
  o.project('arez-browserlocation', :description => 'Arez component for the browser' 's location hash', :tags => %w(historic))
  o.project('arez-idlestatus', :description => 'Arez Browser component that tracks when the user is idle', :tags => %w(historic))
  o.project('arez-mediaquery', :description => 'Arez browser component that exposes when a CSS media query is matched', :tags => %w(historic))
  o.project('arez-networkstatus', :description => 'Arez Browser component that tracks when the user is online', :tags => %w(historic))
  o.project('arez-ticker', :description => 'Arez component that ticks at a specified interval', :tags => %w(historic))
  o.project('arez-timeddisposer', :description => 'Arez utility that will dispose specified node after a delay', :tags => %w(historic))
  o.project('arez-when', :description => 'Arez component that waits until a condition is true and then runs an effect action', :tags => %w(historic))

  o.projects.each do |project|
    project.tags << "name=#{project.name}"
  end
end