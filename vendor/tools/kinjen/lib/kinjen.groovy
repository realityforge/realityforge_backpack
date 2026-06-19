//file:noinspection unused
import hudson.model.Result
import jenkins.model.CauseOfInterruption.UserInterruption

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
 *
 * This stage will also abort the build if the project only builds commits which have an associated pull request.
 */
static prepare_stage( script, project_key, Map options = [:] )
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
      script.env.GIT_SHORT_HASH = script.sh( script: 'echo `git rev-parse --short HEAD`', returnStdout: true ).trim()
      script.env.PRODUCT_VERSION = "${script.env.BUILD_NUMBER}-${script.env.GIT_SHORT_HASH}"
    }
    def include_node = options.node == null ? false : options.node
    if ( include_node )
    {
      def include_yarn = options.yarn == null ? true : options.yarn
      if ( include_yarn )
      {
        script.retry( 2 ) { script.sh 'yarn install; nodenv rehash' }
      }
    }
    def include_ruby = options.ruby == null ? true : options.ruby
    if ( include_ruby )
    {
      script.sh 'echo "gem: --no-document --silent" > ~/.gemrc'
      script.retry( 2 ) { script.sh 'gem install octokit -v 4.6.2' }

      def require_pr = options.require_pull_request == null ? false : options.require_pull_request
      if ( script.env.BRANCH_NAME != 'master' && '' == script.env.AUTO_MERGE_TARGET_BRANCH && require_pr )
      {
        def isTriggeredByUser = script.currentBuild.getBuildCauses('hudson.model.Cause$UserIdCause').size()
        if ( !isTriggeredByUser )
        {
          script.echo "Checking to ensure commit ${script.env.GIT_SHORT_HASH} is included in a PR before continuing"
          def has_pr = has_github_open_pullrequest(script, project_key, script.env.GIT_SHORT_HASH)
          if (!has_pr)
          {
            script.error( "Not building as no pull requests exist for commit ${script.env.GIT_SHORT_HASH}" )
          }
        } else {
          script.echo "Build was triggered by a user, so proceeding without checking for a PR"
        }
      }

      script.retry( 2 ) { script.sh 'gem install netrc -v 0.11.0' }
      script.retry( 2 ) { script.sh 'bundle install --quiet; rbenv rehash' }
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
    def include_spotbugs = options.spotbugs == null ? false : options.spotbugs
    if ( include_spotbugs )
    {
      analysis = true
      script.step( [$class             : 'FindBugsPublisher',
                    pattern            : "reports/${project_key}/spotbugs/spotbugs.xml",
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
                                   reportDir            : "reports/${project_key}/spotbugs",
                                   reportFiles          : 'spotbugs.html',
                                   reportName           : 'Spotbugs issues'] )
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
    script.sh 'xvfb-run -a bundle exec buildr clean; xvfb-run -a bundle exec buildr ci:package_no_test DB_TYPE=pg'
  }
}

/**
 * Guard a set of import actions.
 * Does nothing if there has been no change in the database directory since the last successful build.
 * We only go back 25 commits when looking for a successful build.
 * If a successful build can not be found for the past 25 commits (or back until a commit was part of master)
 * then a comparison is done against master to determine if the actions should run.
 */
static guard_import_stage( script, actions )
{
  // find changes in db directory compared to master
  def changes = script.sh(script: "git diff --name-only origin/master database", returnStdout: true).trim()
  if ( changes ) {
    script.echo 'There are changes in the database directory, compared to master'
    script.echo changes

    // Is there a successful build we can use instead
    def build_required = true
    def stop_looking = false
    def previous_commits = script.sh(script: "git rev-list HEAD~25..HEAD~1", returnStdout: true).trim().split()
    previous_commits.each { git_commit ->
      if ( !stop_looking ) {
        def previous_status = get_success_status_description_for_commit( script, [git_commit: git_commit] )
        if ( previous_status ) {
          script.echo "Found historically successful build for ${git_commit}"
          stop_looking = true
          if ( script.sh(script: "git diff --name-only ${git_commit} database", returnStdout: true).trim() ) {
            script.echo "Changes exist since successful build for ${git_commit}"
            build_required = true
          } else {
            script.echo "No changes exist since successful build for ${git_commit}"
            build_required = false
          }
        } else {
          script.echo "No successful build for ${git_commit}"
          if ( script.sh(script: "git branch --contains ${git_commit}", returnStdout: true).trim().contains("master") ){
            script.echo "Reached master branch without a successful build: ${git_commit}"
            build_required = true
            stop_looking = true
          } else {
            script.echo "Commit is not on master, continuing to check history: ${git_commit}"
          }
        }
      }
    }

    if (build_required) {
      script.echo 'Running DB Import as no historically successful build could be found with no subsequent changes'
      actions()
    } else {
      script.echo 'Skipping db import stage'
    }
  } else {
    script.echo 'Skipping db import stage, no changes in database directory compared to master'
  }
}

/**
 * The basic database import task.
 * Will only run if guard_import_stage allows it to
 */
static import_stage( script )
{
  guard_import_stage( script, { actions ->
    script.sh 'xvfb-run -a bundle exec buildr ci:import'
  } )
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

static deploy_stage( script, project_key, deployment_environment = 'development' )
{
  script.stage( 'Deploy' ) {
    cancel_queued_deploys( script, project_key, deployment_environment )
    script.build job: "${project_key}/deploy-to-${deployment_environment}",
                 parameters: [script.string( name: 'PRODUCT_ENVIRONMENT', value: deployment_environment ),
                              script.string( name: 'PRODUCT_NAME', value: project_key ),
                              script.string( name: 'PRODUCT_VERSION', value: "${script.env.PRODUCT_VERSION}" )],
                 wait: false
  }
}

def static kill_previous_builds( script )
{
  def previousBuild = script.currentBuild.previousBuildInProgress

  while (previousBuild != null) {
    def executor = previousBuild.rawBuild.getExecutor()
    if (null != executor) {
      script.echo ">> Aborting older build #${previousBuild.number}"
      executor.interrupt(Result.ABORTED, new UserInterruption("Aborted by newer build #${script.currentBuild.number}"))
    }
    previousBuild = previousBuild.previousBuildInProgress
  }
}

@NonCPS
def static cancel_queued_job( script, job_name )
{
  def q = Jenkins.instance.queue
  for ( def i = q.items.size() - 1; i >= 0; i-- )
  {
    if ( q.items[ i ].task.getOwnerTask().getFullName() == job_name )
    {
      script.echo "Cancelling queued job ${q.items[ i ].task.getOwnerTask().getFullName()}"
      q.cancel( q.items[ i ].task )
    }
  }
}

@NonCPS
def static cancel_queued_deploys( script, project_key, deployment_environment = 'development' )
{
  cancel_queued_job( script, "${project_key}/deploy-to-${deployment_environment}" )
}

/**
 * The builtin jenkins capabilities do not deal well with api rate limiting, as a result jenkins believes
 * the status has been set but it has not been. Hence the need for custom ruby code.
 */
static set_github_status( script, state, message, Map options = [:] )
{
  def build_context = options.build_context == null ? 'jenkins' : options.build_context
  def git_commit = options.git_commit == null ? script.env.GIT_COMMIT : options.git_commit
  def target_url = options.target_url == null ? script.env.BUILD_URL : options.target_url
  def git_project = options.git_project == null ? script.env.GIT_PROJECT : options.git_project

  script.
    sh "ruby -e \"require 'octokit';Octokit::Client.new(:netrc => true).create_status('${git_project}', '${git_commit}', '${state}', :context => '${build_context}', :description => '${message}', :target_url => '${target_url}')\""
}

/**
 * Return true if there is an open, non-draft, pull request that includes the commit.
 * As it uses the installed octokit it can only be run after the initial prepare phase.
 */
static has_github_open_pullrequest( script, git_project, git_commit )
{
  def present = script.sh(
    script: "ruby -e \"require 'octokit';puts Octokit::Client.new(:netrc => true).get('/repos/stocksoftware/${git_project}/commits/${git_commit}/pulls').any?{|pr| pr[:state] != 'closed' && !pr[:draft]}\"",
    returnStdout: true ).trim()

  present.equals( 'true' )
}

/**
 * Return true if status for specified context is successful.
 * As it uses the installed octokit it can only be run after the initial prepare phase.
 */
static is_github_status_success( script, Map options = [:] )
{
  def build_context = options.build_context == null ? 'jenkins' : options.build_context
  def git_commit = options.git_commit == null ? script.env.GIT_COMMIT : options.git_commit
  def git_project = options.git_project == null ? script.env.GIT_PROJECT : options.git_project

  def present = script.sh(
    script: "ruby -e \"require 'octokit';puts Octokit::Client.new(:netrc => true).statuses('${git_project}', '${git_commit}').any?{|s| s[:state] == 'success' && s[:context] == '${build_context}'}\"",
    returnStdout: true ).trim()

  present.equals( 'true' )
}

/**
 * Return true of the given commit had any changes
 */
static git_commit_has_changes( script, Map options = [:]  )
{
  def git_commit = options.git_commit == null ? script.env.GIT_COMMIT : options.git_commit
  return script.sh( script: "git show ${git_commit}", returnStdout: true ).contains('diff --git')
}

/*
 * Return hashes of all parents for a given commit
 */
static git_parent_commit_hashes(script, Map options = [:]) {
  def git_commit = options.git_commit == null ? script.env.GIT_COMMIT : options.git_commit
  return script.sh( script: "git log --pretty=%P -n 1 ${git_commit}", returnStdout: true ).trim().split()
}

/**
 * Return the description of the 'success' status, from the given commit.
 * As it uses the installed octokit it can only be run after the initial prepare phase.
 */
static get_success_status_description_for_commit( script, Map options = [:] )
{
  def build_context = options.build_context == null ? 'jenkins' : options.build_context
  def git_commit = options.git_commit == null ? script.env.GIT_COMMIT : options.git_commit
  def git_project = options.git_project == null ? script.env.GIT_PROJECT : options.git_project

  script.sh(
    script: "ruby -e \"require 'octokit';x=(Octokit::Client.new(:netrc => true).statuses('${git_project}', '${git_commit}').find{|s| s[:state] == 'success' && s[:context] == '${build_context}'}); x.respond_to?('description') ? puts(x['description']) : nil\"",
    returnStdout: true ).trim()
}

static complete_downstream_actions( script )
{
  set_github_status( script, 'success', "Downstream actions completed: ${script.env.PRODUCT_VERSION}", [build_context: 'downstream_updated'] )
}

static get_artifact_from_previous_status( previous_status ) {
  if (previous_status.startsWith("Successfully built: ") || previous_status.startsWith("Build skipped, using artifact: ")) {
    return previous_status.replace( "Successfully built: ", "" ).replace( "Build skipped, using artifact: ", "" )
  }
  return null
}

static do_guard_build( script, Map options = [:], actions )
{
  def notify_github = options.notify_github == null ? true : options.notify_github
  def email = options.email == null ? true : options.email
  def always_run = options.always_run == null ? false : options.always_run
  def err = null

  def git_commit = options.git_commit == null ? script.env.GIT_COMMIT : options.git_commit
  if ( !always_run ) {
    def build_is_automerge = is_github_status_success( script, ['build_context': 'downstream_updated'] )
    if ( build_is_automerge ) {
      script.echo 'Build already occurred on downstream automerge branch'
      def previous_status = get_success_status_description_for_commit( script, [git_commit: git_commit] )
      def previous_artifact = get_artifact_from_previous_status(previous_status)
      if ( previous_artifact ) {
        script.echo "Previous build artifact was ${previous_artifact}, skipping build"
        script.env.PRODUCT_VERSION = previous_artifact
        script.currentBuild.result = 'SUCCESS'
        script.env.SKIP_DOWNSTREAM = 'true'
        send_notifications( script )
        return
      } else {
        script.echo "Unable to determine previous build artifact from `${previous_status}`"
      }
    } else {
      // No need to build if this has already built
      def previous_build_hash = ""
      def already_built = is_github_status_success( script, [git_commit: git_commit] )
      if ( already_built ) {
        script.echo "Commit is already marked as successfully built"
        previous_build_hash = git_commit
      } else {
        // No need to build if all parent branches were built successfully and there are no changes
        if ( git_commit_has_changes( script ) ) {
          script.echo "Commit has changes, triggering build"
        } else {
          def parent_hashes = git_parent_commit_hashes( script )

          if ( parent_hashes.size() > 1 )  {
              script.echo "Build is a merge commit"
              // Determine if there is a single parent with no changes which was a successful build, use it if so.
              def parents_with_no_changes = []
              parent_hashes.each  { parent_hash ->
                if ( script.sh(script: "git diff --name-only ${parent_hash}..${git_commit}", returnStdout: true).trim().isEmpty() ) {
                  parents_with_no_changes.add(parent_hash)
                }
              }
              if ( parents_with_no_changes.size() == 1 ) {
                script.echo "Parent ${parents_with_no_changes[ 0 ]} contains all changes, checking if it was a successful build"
                if ( get_success_status_description_for_commit( script, [git_commit: parents_with_no_changes[0]] ) ) {
                  script.echo "Parent ${parents_with_no_changes[ 0 ]} was a successful build, using it"
                  previous_build_hash = parents_with_no_changes[ 0 ]
                } else {
                  script.echo "Parent ${parents_with_no_changes[ 0 ]} was not a successful build, triggering build"
                }
              } else {
                script.echo "Unable to find a suitable parent, triggering build.  Number of parents with 0 changes: ${parents_with_no_changes.size()}"
              }
          } else {
            if ( get_success_status_description_for_commit( script, [git_commit: parent_hashes[0]] ) ) {
              script.echo "Build is not a merge commit, but the only parent ${parent_hashes[ 0 ]} was a success"
              previous_build_hash = parent_hashes[ 0 ]
            } else {
              script
                .echo "Build is not a merge branch, the only parent ${parent_hashes[ 0 ]} did not build successfully, triggering build"
            }
          }
        }
      }
      if ( previous_build_hash ) {
        def previous_status = get_success_status_description_for_commit( script, [git_commit: previous_build_hash] )
        def previous_artifact = get_artifact_from_previous_status(previous_status)
        if ( previous_artifact ) {
          script.env.PRODUCT_VERSION = previous_artifact
          script.echo "Previous successful build artifact was ${script.env.PRODUCT_VERSION} for commit ${previous_build_hash}"
          script.currentBuild.result = 'SUCCESS'
          set_github_status( script, 'success', "Build skipped, using artifact: ${script.env.PRODUCT_VERSION}" )
          send_notifications( script )
          return
        } else {
          script.echo "No build artifact defined in status \"${previous_status}\" on commit ${previous_build_hash}, triggering build"
        }
      }
    }
  }
  try
  {
    script.currentBuild.result = 'SUCCESS'
    if ( notify_github )
    {
      set_github_status( script, 'pending', "Building in jenkins: ${script.env.PRODUCT_VERSION}" )
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
        set_github_status( script, 'success', "Successfully built: ${script.env.PRODUCT_VERSION}" )
      }
      else
      {
        set_github_status( script, 'failure', "Failed to build: ${script.env.PRODUCT_VERSION}" )
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
      do_guard_build( script, options, actions )
    }
  }
  else
  {
    do_guard_build( script, options, actions )
  }
}

/**
 * Run the closure in a docker container with specified image and named appropriately.
 */
static run_in_container( script, image_name, container_options = "", actions )
{
  def name = "${script.env.JOB_NAME.replaceAll( /[\\\\/-]/, '_' ).replaceAll( '%2F', '_' )}_${script.env.BUILD_NUMBER}"
  script.docker.image( image_name ).inside( "--name '${name}' ${container_options}", actions )
}

static prepare_auto_merge( script, target_branch )
{
  script.env.LOCAL_TARGET_GIT_COMMIT =
    script.sh( script: "git show-ref --hash refs/remotes/origin/${target_branch}", returnStdout: true ).trim()
  script.echo "Automerge branch ${script.env.BRANCH_NAME} detected. Merging ${target_branch} into local branch."
  script.sh( "git merge origin/${target_branch}" )
}

static complete_auto_merge( script, target_branch )
{
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
      def pre_merge_git_commit = script.sh( script: 'git rev-parse HEAD', returnStdout: true ).trim()
      script.sh( "git merge origin/${target_branch}" )
      def post_merge_git_commit = script.sh( script: 'git rev-parse HEAD', returnStdout: true ).trim()
      if ( pre_merge_git_commit != post_merge_git_commit )
      {
        script.echo( 'Changes merged.' )
        script.sh( "git push origin HEAD:${script.env.BRANCH_NAME}" )
      }
      else
      {
        /*
         * The target branch has been updated but current branch includes the changes in the target
         * branch. This can occur if branch A was merged into the target branch but the current branch was
         * branched off branch A. In this case it is safe to merge it into master.
         */
        perform_auto_merge( script, target_branch )
      }
    }
  }
  else if ( script.env.GIT_COMMIT == script.env.LATEST_REMOTE_GIT_COMMIT )
  {
    perform_auto_merge( script, target_branch )
  }
}

static perform_auto_merge( script, target_branch )
{
  script.echo "Merging automerge branch ${script.env.BRANCH_NAME}."
  def git_commit = script.sh( script: 'git rev-parse HEAD', returnStdout: true ).trim()
  if ( script.env.GIT_COMMIT != git_commit )
  {
    script.sh( "git push origin HEAD:${script.env.BRANCH_NAME}" )
    set_github_status( script,
                       'success',
                       "Successfully built: ${script.env.PRODUCT_VERSION}",
                       [git_commit: git_commit] )
  }
  script.sh( "git push origin HEAD:${target_branch}" )
  /*
   * Return status so we can ignore failures for next command. Some of our repositories will
   * automatically remove branches merged to master and thus step may fail.
   */
  script.sh( script: "git push origin :${script.env.BRANCH_NAME}", returnStatus: true )
  script.env.AUTO_MERGE_COMPLETE = 'true'
}

static config_git( script, Map options = [:] )
{
  script.sh( "git config --global user.email \"${script.env.BUILD_NOTIFICATION_EMAIL}\"" )
  script.sh( 'git config --global user.name "Build Tool"' )
  script.sh( 'git config --global core.autocrlf false' )
  script.env.GIT_COMMIT = script.sh( script: 'git rev-parse HEAD', returnStdout: true ).trim()
  script.env.GIT_ORIGIN = script.sh( script: 'git remote get-url origin', returnStdout: true ).trim()
  script.env.GIT_PROJECT =
    script.env.GIT_ORIGIN.replaceAll( /^https:\/\/github\.com\//, '' ).replaceAll( /\.git$/, '' )
  setup_git_credentials( script, options )
  script.sh( 'git reset --hard' )
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

    script.
      emailext body: "<p>Check console output at <a href=\"${script.env.BUILD_URL}\">${script.env.BUILD_URL}</a> to view the results.</p>",
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

/**
 * Method called to complete the build.
 * Accepts an optional block which contains the downstream actions.
 */
static complete_build( script, actions = null )
{
  if ( script.currentBuild.result == 'SUCCESS' && script.env.SKIP_DOWNSTREAM != 'true' )
  {
    if ( '' != script.env.AUTO_MERGE_TARGET_BRANCH )
    {
      complete_auto_merge( script, script.env.AUTO_MERGE_TARGET_BRANCH )
    }
    if ( null != actions )
    {
      if ( script.env.BRANCH_NAME == 'master' ||
           ( script.env.AUTO_MERGE_TARGET_BRANCH == 'master' && script.env.AUTO_MERGE_COMPLETE == 'true' ) )
      {
        actions()
        complete_downstream_actions( script )
      }
    }
    else
    {
      complete_downstream_actions( script )
    }
  }
}

return this
