node {
        checkout scm

        sh "git rev-parse HEAD > .git/commit-id"
        def version = readFile('.git/commit-id').trim().substring(0,6)

        sh "date +%Y%m%d%H%M > .timestamp"
        def timestamp = readFile('.timestamp').trim()

        println "Building version ${version}"

        currentBuild.displayName = "$timestamp"
        currentBuild.description = "${version}@${timestamp}"

        stage('commit stage') {
            sh "echo syntax check"
            sh "echo config check"
            sh "echo publish"
        }
        parallel (
          local: {
            stage('local tests stage') {
                sh "echo test-kitchen"
            }
          },
          remote: {
            //if (env.DEPLOY_TEST_STACK == 'true') {
            //input "Do you want to run remote test?"

              stage('remote tests stage') {
                sh "echo deploy test stack"
              }
            //}
          }
        )

        stage('deploy test') {
            sh "bash -x src/bin/deploy.sh test"
        }


        milestone()

        stage('deploy prod') {
            sh "echo deploying on prod"
        }


}
