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

module Backpack
  class Context < Reality::BaseElement
    def initialize(options = {}, &block)
      @client = nil
      @hooks = []
      self.options = options
      yield self if block_given?
    end

    def client
      unless @client
        @client = Octokit::Client.new(:netrc => true, :auto_paginate => true)
        @client.login
      end
      @client
    end

    def add_hook(hook)
      @hooks << hook
    end

    def hooks
      @hooks.dup
    end
  end

  class << self
    def context
      @context ||= Backpack::Context.new
    end
  end
end
