require 'belt'

Dir["#{File.expand_path('.')}/scopes/*.rb"].each(&method(:require))
