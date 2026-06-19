#!/usr/bin/env groovy

timestamps {
  node {
    checkout scm
    docker
      .image( 'stocksoftware/build:current' )
      .inside( "--name '${env.JOB_NAME.replaceAll( /[\\\\\\/-]/, '_' ).replaceAll( '%2F', '_' )}_${env.BUILD_NUMBER}'" ) {
        try
        {
          currentBuild.result = 'SUCCESS'
          stage( 'Synchronize Projects' ) {
            withCredentials( [[$class: 'UsernamePasswordMultiBinding', credentialsId: 'realityforge', passwordVariable: 'GITHUB_PASS', usernameVariable: 'GITHUB_USER']] ) {
              sh 'echo "machine api.github.com login ${GITHUB_USER} password ${GITHUB_PASS}" > ~/.netrc'
              sh 'echo "machine github.com login ${GITHUB_USER} password ${GITHUB_PASS}" >> ~/.netrc'
              sh 'chmod 0600 ~/.netrc'
            }
            sh "git config --global user.email \"${env.BUILD_NOTIFICATION_EMAIL}\""
            sh 'git config --global user.name "Build Tool"'
            sh 'git config --global core.autocrlf false'
            sh 'git reset --hard'
            sh 'git clean -ffdx'
            sh 'echo "gem: --no-document --silent" > ~/.gemrc'
            retry( 2 ) { sh 'bundle install --quiet; rbenv rehash' }
            withCredentials( [string( credentialsId: 'realityforge-oauth', variable: 'GITHUB_TOKEN' )] ) {
              retry( 8 ) { sh './backpack' }
            }
          }
        }
        catch ( exception )
        {
          currentBuild.result = 'FAILURE'
          throw exception
        }
      }
  }
}
