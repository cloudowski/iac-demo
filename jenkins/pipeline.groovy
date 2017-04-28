pipeline {
  agent any
  parameters {
    string(name: 'VERSION', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')
    booleanParam(name: 'DEPLOY_TEST_STACK', defaultValue: false, description: 'Deploy test stack during test stage?')
  }
  stages {
    stage('commit stage') {
      steps {
        sh "echo syntax check"
        sh "echo config check"
        sh "echo publish"
      }
    }
    stage('local tests stage') {
      steps {
        sh "echo test-kitchen"
      }
    }
    stage('remote tests stage') {
      when { environment name: 'DEPLOY_TEST_STACK', value: "true" }
      steps {
        sh "echo deploy test stack"
      }
    }

    stage('deploy test') {
      steps {
        sh "echo syntax check"
        sh "echo config check"
      }
    }

  }
}
