Belt.scope('arez') do |o|
  o.project('arez', :description => 'Fast, easy, reactive state', :tags => %w(codecov travis issues homepage=https://arez.github.io))
  o.project('arez.github.io', :description => 'Arez website', :tags => %w(pages homepage=https://arez.github.io zim=no))
  o.project('arez-dom', :description => 'Arez browser components that make DOM properties observable', :tags => %w(travis issues homepage=https://arez.github.io/dom))
  o.project('arez-spytools', :description => 'Arez utilities that enhance the spy capabilities', :tags => %w(travis issues homepage=https://arez.github.io/spytools))
  o.project('arez-testng', :description => 'Arez utilities for writing TestNG tests', :tags => %w(travis issues homepage=https://arez.github.io/testng))
  o.project('arez-persist', :description => 'Arez extension for persisting observable properties', :tags => %w(travis issues homepage=https://arez.github.io/persist))

  # Historic projects
  o.project('arez-promise', :description => 'Arez component that wraps a Promise and makes it observable', :tags => %w(historic))
  o.project('arez-devtools', :description => 'Browser-based Arez DevTools', :tags => %w(historic))
  o.project('arez-browserlocation', :description => 'Arez component for the browser' 's location hash', :tags => %w(historic))
  o.project('arez-idlestatus', :description => 'Arez Browser component that tracks when the user is idle', :tags => %w(historic))
  o.project('arez-mediaquery', :description => 'Arez browser component that exposes when a CSS media query is matched', :tags => %w(historic))
  o.project('arez-networkstatus', :description => 'Arez Browser component that tracks when the user is online', :tags => %w(historic))
  o.project('arez-ticker', :description => 'Arez component that ticks at a specified interval', :tags => %w(historic))
  o.project('arez-timeddisposer', :description => 'Arez utility that will dispose specified node after a delay', :tags => %w(historic))
  o.project('arez-when', :description => 'Arez component that waits until a condition is true and then runs an effect action', :tags => %w(historic))
end
