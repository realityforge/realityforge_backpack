#!/usr/bin/env groovy
timestamps {
  node {
    checkout scm
    kinjen = load 'vendor/tools/kinjen/lib/kinjen.groovy'
    kinjen.run_in_container(this, 'stocksoftware/build:java-8.92.14_ruby-2.3.1') {
      kinjen.config_git(this)
      kinjen.guard_build(this, [notify_github: false]) {
        kinjen.prepare_stage(this, [buildr: false])
        stage('Synchronize Projects') {
          withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'realityforge', passwordVariable: 'GITHUB_PASS', usernameVariable: 'GITHUB_USER']]) {
            sh 'echo "machine api.github.com login ${GITHUB_USER} password ${GITHUB_PASS}" > ~/.netrc'
            sh 'echo "machine github.com login ${GITHUB_USER} password ${GITHUB_PASS}" >> ~/.netrc'
            sh 'chmod 0600 ~/.netrc'
          }
          withCredentials([string(credentialsId: 'realityforge-oauth', variable: 'GITHUB_TOKEN')]) {
            retry(8) { sh './backpack' }
          }
        }
      }
    }
  }
}
