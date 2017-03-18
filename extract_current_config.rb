#!/usr/bin/env ruby

require 'octokit'

client = Octokit::Client.new(:netrc => true, :auto_paginate => true)
client.login

# A simple script that will extract configuration from the repo

client.repositories('realityforge').sort { |v1, v2| v1['name'].to_s <=> v2['name'].to_s }.each do |remote_repository|
  description =
    remote_repository['description'].to_s == '' ? '' : ", :description => '#{remote_repository['description'].gsub("'", "''")}'"

  homepage = remote_repository['homepage'].to_s == '' ? '' : ", :homepage => '#{remote_repository['homepage']}'"
  private = remote_repository['private'].to_s == 'true' ? '' : ', :private => false'
  issues = remote_repository['has_issues'].to_s == 'true' ? '' : ', :issues => true'
  wiki = remote_repository['has_wiki'].to_s == 'true' ? '' : ', :wiki => true'

  tags = []

  hooks = client.hooks(remote_repository['full_name'])
  if hooks.size > 0
    hooks.each do |hook|
      if hook[:name] == 'email'
        tags << 'notify:stock'
      elsif hook[:name] == 'travis'
        tags << 'travis'
      elsif hook[:name] == 'docker'
        tags << 'docker-hub'
      else
        puts "Unhandled Hook:\n#{hook.inspect}"
        exit
      end
    end
  end

  puts "  o.repository('#{remote_repository['name']}'#{description}#{homepage}#{private}#{issues}#{wiki}#{tags.size > 0 ? ", :tags => %w(#{tags.join(' ')})" : ''})"
end
