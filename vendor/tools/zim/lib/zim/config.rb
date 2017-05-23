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

  # Class used to configure the Zim library
  class Config

    @base_directory = nil
    @log_level = nil

    class << self
      def parameters
        @parameters ||= {}
      end

      def parameter_by_name(name)
        value = parameters[name.to_s]
        raise "Unable to locate parameter named '#{name}'" unless value
        value
      end

      attr_accessor :first_app

      attr_writer :base_directory

      def base_directory
        @base_directory || (raise 'Base directory undefined')
      end

      def suite_directory
        "#{base_directory}/#{Zim.current_suite.directory}"
      end

      def log_level=(log_level)
        valid_log_levels = [:normal, :verbose, :quiet]
        raise "Invalid log level #{log_level} expected to be one of #{valid_log_levels.inspect}" unless valid_log_levels.include?(log_level)
        @log_level = log_level
      end

      def log_level
        @log_level || :info
      end

      def keep_unknown?
        @keep_unknown.nil? ? false : !!@keep_unknown
      end

      attr_writer :keep_unknown

      def info?
        self.log_level == :info
      end

      def verbose?
        self.log_level == :verbose
      end

      def quiet?
        self.log_level == :quiet
      end

      def include_tags
        @include_tags ||= []
      end

      def exclude_tags
        @exclude_tags ||= []
      end

      def filters
        @filters ||= []
      end

      def only_modify_changed?
        self.project_select_mode == :changed
      end

      def only_modify_changed!
        self.project_select_mode = :changed
      end

      def only_modify_unchanged?
        self.project_select_mode == :unchanged
      end

      def only_modify_unchanged!
        self.project_select_mode = :unchanged
      end

      def project_select_mode
        @project_select_mode || :all
      end

      def project_select_mode=(project_select_mode)
        raise "Unknown project_select_mode #{project_select_mode}" unless [:all, :changed, :unchanged].include?(project_select_mode)
        @project_select_mode = project_select_mode
      end
    end
  end
end
