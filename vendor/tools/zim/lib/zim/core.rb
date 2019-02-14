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

module Zim # nodoc
  class << self
    def context(&block)
      self.instance_eval &block
    end

    def current_suite?
      !get_current_suite.nil?
    end

    attr_writer :current_suite

    def current_suite
      current_suite = get_current_suite
      Zim.error('current_suite invoke but no suite specified.') if current_suite.nil?
      current_suite
    end

    attr_accessor :initial_args

    # Set the description for the next command defined
    def desc(description)
      @next_description = description
    end

    # Retrieve and clear the description for the next command
    def pop_description
      description = @next_description
      @next_description = nil
      description
    end

    private

    def get_current_suite
      if @current_suite.nil? && 1 == Zim.suites.size
        # Set default suite if only one suite defined
        @current_suite = Zim.suites.first
      end
      @current_suite
    end
  end
end
