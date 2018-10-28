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

class Backpack::Repository
  def email_hook(email_address)
    hook('email',
         :events => %w(push pull_request),
         :config => {:address => email_address, :send_from_author => '0'})
  end

  def jira_hook(jira_endpoint_url, options = {})
    insecure_ssl = options[:insecure_ssl].nil? ? '0' : !!options[:insecure_ssl] ? '1' : '0'
    hook('jira-hook',
         :type => 'web',
         :config_key => :url,
         :events => %w(issue_comment pull_request pull_request_review_comment push),
         :config => {:content_type => 'json', :url => jira_endpoint_url, :insecure_ssl => insecure_ssl})
  end

  def ci_hook(hook_endpoint_url)
    hook('ci-hook',
         :type => 'web',
         :config_key => :url,
         :events => %w(issue_comment pull_request),
         :config => {:insecure_ssl => '1', :url => hook_endpoint_url, :content_type=> 'form'})

  end

  def docker_hook
    hook('docker', :events => %w(push), :config => {})
  end

  def travis_hook(user, token)
    hook('travis',
         :type => 'web',
         :events => %w(issue_comment member public pull_request push),
         :password_config_keys => [:secret],
         :config => { :url => 'https://notify.travis-ci.org/', :secret => token, :insecure_ssl => '0', 'content_type' => 'form' })
  end

  def codecov_hook(token)
    hook('codecov',
         :type => 'web',
         :config_key => :url,
         :events => %w(delete public pull_request push repository status),
         :password_config_keys => %w(secret),
         :config => { :content_type => 'json',
                      :secret => token,
                      :url => 'https://codecov.io/webhooks/github',
                      :insecure_ssl => '0' })
  end
end
