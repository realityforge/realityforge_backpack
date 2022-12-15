#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'backpack'

# Load the local customization file if present
require File.expand_path('_backpack.rb') if File.exist?('_backpack.rb')

filename = 'backpack_config.rb'
if File.exist?(filename)
  require File.expand_path('backpack_config.rb')
else
  puts "Expected to find configuration file #{filename} to drive Backpack."
  puts 'Please create such a file before re-running the backpack command.'
  exit 1
end

ENV['OCTOKIT_DEFAULT_MEDIA_TYPE'] = 'application/vnd.github+json'

Backpack.organizations.each do |organization|
  Backpack::Driver.converge(Backpack.context, organization)
end
