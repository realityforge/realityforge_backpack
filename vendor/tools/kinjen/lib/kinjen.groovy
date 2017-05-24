/**
 * Return the branch name that this branch will automatically merge into if any. Return null if branch is not an auotmerge branch.
 */
static extract_auto_merge_target( script )
{
  if ( script.env.BRANCH_NAME ==~ /^AM_.*/ )
  {
    return 'master'
  }
  else if ( script.env.BRANCH_NAME ==~ /^AM-([^_]+)_.*$/ )
  {
    return script.env.BRANCH_NAME.replaceFirst( /^AM-([^_]+)_.*$/, '$1' )
  }
  else
  {
    return ''
  }
}

/**
 * The standard prepare stage that cleans up repository and downloads/installs java/ruby dependencies.
 */
static prepare_stage( script, Map options = [:] )
{
  script.stage( 'Prepare' ) {
    script.sh 'git reset --hard'
    def clean_repository = options.clean == null ? true : options.clean
    if ( clean_repository )
    {
      script.sh 'git clean -ffdx'
    }
    def versions_envs = options.versions_envs == null ? true : options.versions_envs
    if ( versions_envs )
    {
      script.env.BUILD_NUMBER = "${script.env.BUILD_NUMBER}"
      script.env.PRODUCT_VERSION =
        script.sh( script: 'echo $BUILD_NUMBER-`git rev-parse --short HEAD`', returnStdout: true ).trim()
    }
    def include_ruby = options.ruby == null ? true : options.ruby
    if ( include_ruby )
    {
      script.sh 'echo "gem: --no-ri --no-rdoc" > ~/.gemrc'
      script.retry( 2 ) { script.sh 'gem install octokit -v 4.6.2' }
      script.retry( 2 ) { script.sh 'gem install netrc -v 0.11.0' }
      script.retry( 2 ) { script.sh 'bundle install; rbenv rehash' }
      def include_buildr = options.buildr == null ? true : options.buildr
      if ( include_buildr )
      {
        script.retry( 2 ) { script.sh 'bundle exec buildr artifacts' }
      }
    }
  }
}

/**
 * The commit stage that runs buildr pre-commit task 'ci:commit' and collects reports.
 */
static commit_stage( script, project_key, Map options = [:] )
{
  script.stage( 'Commit' ) {

    script.sh 'xvfb-run -a bundle exec buildr ci:commit'
    def analysis = false
    def include_checkstyle = options.checkstyle == null ? false : options.checkstyle
    if ( include_checkstyle )
    {
      analysis = true
      script.step( [$class          : 'hudson.plugins.checkstyle.CheckStylePublisher',
                    pattern         : "reports/${project_key}/checkstyle/checkstyle.xml",
                    unstableTotalAll: '1',
                    failedTotalAll  : '1'] )
      script.publishHTML( target: [allowMissing         : false,
                                   alwaysLinkToLastBuild: false,
                                   keepAll              : true,
                                   reportDir            : "reports/${project_key}/checkstyle",
                                   reportFiles          : 'checkstyle.html',
                                   reportName           : 'Checkstyle issues'] )
    }
    def include_findbugs = options.findbugs == null ? false : options.findbugs
    if ( include_findbugs )
    {
      analysis = true
      script.step( [$class             : 'FindBugsPublisher',
                    pattern            : "reports/${project_key}/findbugs/findbugs.xml",
                    unstableTotalAll   : '1',
                    failedTotalAll     : '1',
                    isRankActivated    : true,
                    canComputeNew      : true,
                    shouldDetectModules: false,
                    useDeltaValues     : false,
                    canRunOnFailed     : false,
                    thresholdLimit     : 'low'] )
      script.publishHTML( target: [allowMissing         : false,
                                   alwaysLinkToLastBuild: false,
                                   keepAll              : true,
                                   reportDir            : "reports/${project_key}/findbugs",
                                   reportFiles          : 'findbugs.html',
                                   reportName           : 'Findbugs issues'] )
    }
    def include_pmd = options.pmd == null ? false : options.pmd
    if ( include_pmd )
    {
      analysis = true
      script.step( [$class          : 'PmdPublisher',
                    pattern         : "reports/${project_key}/pmd/pmd.xml",
                    unstableTotalAll: '1',
                    failedTotalAll  : '1'] )
      script.publishHTML( target: [allowMissing         : false,
                                   alwaysLinkToLastBuild: false,
                                   keepAll              : true,
                                   reportDir            : "reports/${project_key}/pmd",
                                   reportFiles          : 'pmd.html',
                                   reportName           : 'PMD Issues'] )
    }
    def include_jdepend = options.jdepend == null ? false : options.jdepend
    if ( include_jdepend )
    {
      script.publishHTML( target: [allowMissing         : false,
                                   alwaysLinkToLastBuild: false,
                                   keepAll              : true,
                                   reportDir            : "reports/${project_key}/jdepend",
                                   reportFiles          : 'jdepend.html',
                                   reportName           : 'JDepend Report'] )
    }
    if ( analysis )
    {
      script.step( [$class: 'AnalysisPublisher', unstableTotalAll: '1', failedTotalAll: '1'] )
    }

    if ( script.currentBuild.result != 'SUCCESS' )
    {
      script.error( 'Build failed commit stage' )
    }
  }
}

/**
 * The package stage that runs buildr task 'ci:package' and collects reports.
 */
static package_stage( script, Map options = [:] )
{
  script.stage( 'Package' ) {
    script.sh 'xvfb-run -a bundle exec buildr ci:package'
    def include_junit = options.junit == null ? false : options.junit
    if ( include_junit )
    {
      script.step( [$class: 'JUnitResultArchiver', testResults: 'reports/**/TEST-*.xml'] )
    }
    def include_testng = options.testng == null ? false : options.testng
    if ( include_testng )
    {
      script.step( [$class                   : 'hudson.plugins.testng.Publisher',
                    reportFilenamePattern    : 'reports/*/testng/testng-results.xml',
                    failureOnFailedTestConfig: true,
                    unstableFails            : 0,
                    unstableSkips            : 0] )
    }
  }
}

/**
 * The pg package stage that runs buildr task 'ci:package_no_test' building for postgres artifacts.
 * No tests are run under the naive assumption that the sql server variant tests required functionality.
 */
static pg_package_stage( script )
{
  script.stage( 'Pg Package' ) {
    script.sh 'xvfb-run -a bundle exec buildr clean; export DB_TYPE=pg; xvfb-run -a bundle exec buildr ci:package_no_test'
  }
}

/**
 * The basic database import task.
 */
static import_stage( script )
{
  script.stage( 'DB Import' ) {
    script.sh 'xvfb-run -a bundle exec buildr ci:import'
  }
}

/**
 * A database import task testing an import variant.
 */
static import_variant_stage( script, variant )
{
  script.stage( "DB ${variant} Import" ) {
    script.sh "xvfb-run -a bundle exec buildr ci:import:${variant}"
  }
}

/**
 * A task that triggers the zimming out of dependencies to downstream projects.
 */
static zim_stage( script, name, dependencies )
{
  script.stage( 'Zim' ) {
    script.build job: 'zim/upgrade_dependency',
                 parameters: [script.string( name: 'DEPENDENCIES', value: dependencies ),
                              script.string( name: 'NAME', value: name ),
                              script.string( name: 'VERSION', value: "${script.env.PRODUCT_VERSION}" )],
                 wait: false
  }
}

static publish_stage( script, upload_prefix = '' )
{
  script.stage( 'Publish' ) {
    script.sh """export DOWNLOAD_REPO=${script.env.UPLOAD_REPO}
export UPLOAD_REPO=${script.env."EXTERNAL_${upload_prefix}UPLOAD_REPO"}
export UPLOAD_USER=${script.env."EXTERNAL_${upload_prefix}UPLOAD_USER"}
export UPLOAD_PASSWORD=${script.env."EXTERNAL_${upload_prefix}UPLOAD_PASSWORD"}
export PUBLISH_VERSION=${script.PUBLISH_VERSION}
bundle exec buildr ci:publish"""
  }
}

static deploy_stage( script, project_key )
{
  script.stage( 'Deploy' ) {
    script.build job: "${project_key}/deploy-to-development",
                 parameters: [script.string( name: 'PRODUCT_ENVIRONMENT', value: 'development' ),
                              script.string( name: 'PRODUCT_NAME', value: project_key ),
                              script.string( name: 'PRODUCT_VERSION', value: "${script.env.PRODUCT_VERSION}" )],
                 wait: false
  }
}

/**
 * The builtin jenkins capabilities do not deal well with api rate limiting, as a result jenkins believes
 * the status has been set but it has not been. Hence the need for custom ruby code. However this may need
 * to run prior to ruby having being setup so it falls back to the old methods in this scenario.
 */
static set_github_status( script, state, message, Map options = [:] )
{
  def build_context = options.build_context == null ? 'jenkins' : options.build_context
  def git_commit = options.git_commit == null ? script.env.GIT_COMMIT : options.git_commit
  def target_url = options.target_url == null ? script.env.BUILD_URL : options.target_url
  def git_project = options.git_project == null ? script.env.GIT_PROJECT : options.git_project
  def use_ruby =
    options.use_ruby == null ?
    ( script.sh( script: 'gem list | grep octokit', returnStatus: true ) == 0 ) :
    options.use_ruby

  script.echo "Set Github Status -- Git Project: ${git_project}, Use Ruby: ${use_ruby}, Context: ${build_context}, SHA1: ${git_commit}, Target URL: ${target_url}"

  if ( use_ruby )
  {
    script.sh "ruby -e \"require 'octokit';Octokit::Client.new(:netrc => true).create_status('${git_project}', '${git_commit}', '${state}', :context => '${build_context}', :description => '${message}', :target_url => '${target_url}')\""
  }
  else if ( options.git_commit != null )
  {
    script.step( [
      $class            : 'GitHubCommitStatusSetter',
      commitShaSource   : [$class: 'ManuallyEnteredShaSource', sha: options.git_commit],
      contextSource     : [$class: 'ManuallyEnteredCommitContextSource', context: build_context],
      errorHandlers     : [[$class: 'ChangingBuildStatusErrorHandler', result: 'UNSTABLE']],
      statusResultSource: [$class: 'ConditionalStatusResultSource', results: [[$class: 'AnyBuildResult', message: message, state: state]]]
    ] )
  }
  else
  {
    script.step( [
      $class            : 'GitHubCommitStatusSetter',
      contextSource     : [$class: 'ManuallyEnteredCommitContextSource', context: build_context],
      errorHandlers     : [[$class: 'ChangingBuildStatusErrorHandler', result: 'UNSTABLE']],
      statusResultSource: [$class: 'ConditionalStatusResultSource', results: [[$class: 'AnyBuildResult', message: message, state: state]]]
    ] )
  }
}

static do_guard_build( script, Map options = [:], actions )
{
  def notify_github = options.notify_github == null ? true : options.notify_github
  def build_context = options.build_context == null ? 'jenkins' : options.build_context
  def email = options.email == null ? true : options.email
  def err = null

  try
  {
    script.currentBuild.result = 'SUCCESS'
    if ( notify_github )
    {
      set_github_status( script, 'pending', 'Building in jenkins', [build_context: build_context] )
    }

    actions()
  }
  catch ( exception )
  {
    script.currentBuild.result = "FAILURE"
    err = exception
  }
  finally
  {
    if ( notify_github )
    {
      if ( script.currentBuild.result == 'SUCCESS' )
      {
        set_github_status( script, 'success', 'Successfully built', [build_context: build_context] )
      }
      else
      {
        set_github_status( script, 'failure', 'Failed to build', [build_context: build_context] )
      }
    }

    if ( email )
    {
      send_notifications( script )
    }
    if ( err )
    {
      throw err
    }
  }
}

static guard_build( script, Map options = [:], actions )
{
  if ( options.lock_name && '' != options.lock_name )
  {
    script.lock( resource: "${script.env.GIT_PROJECT.replaceAll( /\//, '_' )}_${options.lock_name}" ) {
      script.kinjen.do_guard_build( script, options, actions )
    }
  }
  else
  {
    script.kinjen.do_guard_build( script, options, actions )
  }
}

/**
 * Run the closure in a docker container with specified image and named appropriately.
 */
static run_in_container( script, image_name, actions )
{
  def name = "${script.env.JOB_NAME.replaceAll( /[\\\\/-]/, '_' ).replaceAll( '%2F', '_' )}_${script.env.BUILD_NUMBER}"
  script.docker.image( image_name ).inside( "--name '${name}'", actions )
}

static prepare_auto_merge( script, target_branch )
{
  script.env.LOCAL_TARGET_GIT_COMMIT =
    script.sh( script: "git show-ref --hash refs/remotes/origin/${target_branch}", returnStdout: true ).trim()
  script.echo "Automerge branch ${script.env.BRANCH_NAME} detected. Merging ${target_branch} into local branch."
  script.sh( "git merge origin/${target_branch}" )
}

static complete_auto_merge( script, target_branch, Map options = [:] )
{
  def build_context = options.build_context == null ? 'jenkins' : options.build_context

  script.sh( 'git fetch --prune' )
  script.env.LATEST_REMOTE_MASTER_GIT_COMMIT =
    script.sh( script: "git show-ref --hash refs/remotes/origin/${target_branch}", returnStdout: true ).trim()
  script.env.LATEST_REMOTE_GIT_COMMIT =
    script.sh( script: "git show-ref --hash refs/remotes/origin/${script.env.BRANCH_NAME}", returnStdout: true ).trim()
  if ( script.env.LOCAL_TARGET_GIT_COMMIT != script.env.LATEST_REMOTE_MASTER_GIT_COMMIT )
  {
    if ( script.env.GIT_COMMIT == script.env.LATEST_REMOTE_GIT_COMMIT )
    {
      script.echo( "Merging changes from ${target_branch} to kick off another build cycle." )
      script.sh( "git merge origin/${target_branch}" )
      script.echo( 'Changes merged.' )
      script.sh( "git push origin HEAD:${script.env.BRANCH_NAME}" )
    }
  }
  else
  {
    if ( script.env.GIT_COMMIT == script.env.LATEST_REMOTE_GIT_COMMIT )
    {
      script.echo "Merging automerge branch ${script.env.BRANCH_NAME}."
      def git_commit = script.sh( script: 'git rev-parse HEAD', returnStdout: true ).trim()
      if ( script.env.GIT_COMMIT != git_commit )
      {
        script.sh( "git push origin HEAD:${script.env.BRANCH_NAME}" )
        set_github_status( script,
                           'success',
                           'Successfully built',
                           [build_context: build_context, git_commit: git_commit] )
      }
      script.sh( "git push origin HEAD:${target_branch}" )
      script.sh( "git push origin :${script.env.BRANCH_NAME}" )
    }
  }
}

static config_git( script, Map options = [:] )
{
  script.sh( "git config --global user.email \"${script.env.BUILD_NOTIFICATION_EMAIL}\"" )
  script.sh( 'git config --global user.name "Build Tool"' )
  script.env.GIT_COMMIT = script.sh( script: 'git rev-parse HEAD', returnStdout: true ).trim()
  script.env.GIT_ORIGIN = script.sh( script: 'git remote get-url origin', returnStdout: true ).trim()
  script.env.GIT_PROJECT =
    script.env.GIT_ORIGIN.replaceAll( /^https:\/\/github\.com\//, '' ).replaceAll( /\.git$/, '' )
  setup_git_credentials( script, options )
}

static setup_git_credentials( script, Map options = [:] )
{
  def username = options.username == null ? 'stock-hudson' : options.username

  script.withCredentials( [[$class          : 'UsernamePasswordMultiBinding',
                            credentialsId   : username,
                            usernameVariable: 'GIT_USERNAME',
                            passwordVariable: 'GIT_PASSWORD']] ) {
    script.sh "echo \"machine github.com login ${script.GIT_USERNAME} password ${script.GIT_PASSWORD}\" > ~/.netrc"
    script.sh "echo \"machine api.github.com login ${script.GIT_USERNAME} password ${script.GIT_PASSWORD}\" >> ~/.netrc"
    script.sh "chmod 0600 ~/.netrc"
  }
}

static send_notifications( script )
{
  if ( script.currentBuild.result == 'SUCCESS' &&
       script.currentBuild.rawBuild.previousBuild != null &&
       script.currentBuild.rawBuild.previousBuild.result.toString() != 'SUCCESS' )
  {
    script.echo "Emailing SUCCESS notification to ${script.env.BUILD_NOTIFICATION_EMAIL}"

    script.emailext body: "<p>Check console output at <a href=\"${script.env.BUILD_URL}\">${script.env.BUILD_URL}</a> to view the results.</p>",
                    mimeType: 'text/html',
                    replyTo: "${script.env.BUILD_NOTIFICATION_EMAIL}",
                    subject: "\ud83d\udc4d ${script.env.JOB_NAME.replaceAll( '%2F', '/' )} - #${script.env.BUILD_NUMBER} - SUCCESS",
                    to: "${script.env.BUILD_NOTIFICATION_EMAIL}"
  }

  if ( script.currentBuild.result != 'SUCCESS' )
  {
    def emailBody = """
<title>${script.env.JOB_NAME.replaceAll( '%2F', '/' )} - #${script.env.BUILD_NUMBER} - ${script.currentBuild.result}</title>
<BODY>
    <div style="font:normal normal 100% Georgia, Serif; background: #ffffff; border: dotted 1px #666; margin: 2px; content: 2px; padding: 2px;">
      <table style="width: 100%">
        <tr style="background-color:#f0f0f0;">
          <th colspan=2 valign="center"><b style="font-size: 200%;">BUILD ${script.currentBuild.result}</b></th>
        </tr>
        <tr>
          <th align="right"><b>Build URL</b></th>
          <td>
            <a href="${script.env.BUILD_URL}">${script.env.BUILD_URL}</a>
          </td>
        </tr>
        <tr>
          <th align="right"><b>Job</b></th>
          <td>${script.env.JOB_NAME.replaceAll( '%2F', '/' )}</td>
        </tr>
        <tr>
          <td align="right"><b>Build Number</b></td>
          <td>${script.env.BUILD_NUMBER}</td>
        </tr>
        <tr>
          <td align="right"><b>Branch</b></td>
          <td>${script.env.BRANCH_NAME}</td>
        </tr>
 """
    if ( null != script.env.CHANGE_ID )
    {
      emailBody += """
       <tr>
          <td align="right"><b>Change</b></td>
          <td><a href="${script.env.CHANGE_URL}">${script.env.CHANGE_ID} - ${script.env.CHANGE_TITLE}</a></td>
        </tr>
"""
    }

    emailBody += """
      </table>
    </div>

    <div style="background: lightyellow; border: dotted 1px #666; margin: 2px; content: 2px; padding: 2px;">
"""
    for ( String line : script.currentBuild.rawBuild.getLog( 200 ) )
    {
      emailBody += "${line}<br/>"
    }
    emailBody += """
    </div>
</BODY>
"""
    script.echo "Emailing FAILED notification to ${script.env.BUILD_NOTIFICATION_EMAIL}"
    script.emailext body: emailBody,
                    mimeType: 'text/html',
                    replyTo: "${script.env.BUILD_NOTIFICATION_EMAIL}",
                    subject: "\ud83d\udca3 ${script.env.JOB_NAME.replaceAll( '%2F', '/' )} - #${script.env.BUILD_NUMBER} - FAILED",
                    to: "${script.env.BUILD_NOTIFICATION_EMAIL}"
  }
}

return this
