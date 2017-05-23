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

require 'zim'

Zim.context do
  filename = 'zim_config.rb'
  if File.exist?(filename)
    instance_eval IO.read(filename), filename
  else
    puts "Expected to find configuration file #{filename} to drive Zim."
    puts 'Please create such a file before re-running the zim command.'
    exit 1
  end
end

Zim::Driver.process(ARGV)
