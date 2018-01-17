@Library('github.com/cloudowski/cloudowski-pipeline-library@0.1') _

def exitCode = -1
def apply = false
def envs = ['test', 'prod']


  node {
    // Set github status that the images could be built successfully
    step([$class: 'GitHubSetCommitStatusBuilder'])
    checkout scm

    // version with timestamp
    env.CODE_VERSION = get_timestamp_version()
    currentBuild.displayName = "${env.CODE_VERSION}"


    stage('test') {

      // TODO: execute real tests here
      // sh "./test/mid-level-tests.sh"
      sh "echo ansible-lint"

      env.PATH = "${env.PATH}:${env.WORKSPACE}:${env.WORKSPACE}/utils"
      withCredentials([usernamePassword(credentialsId: 'aws-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
        dir('tf/') {
          terraform.init()
          terraform.exec('validate')

          echo "Putting code_version into terrafom config (code_version.auto.tfvars)"
          sh "echo 'code_version = ${env.CODE_VERSION}' > code_version.auto.tfvars"

        }
        def artifact = "iac-${env.CODE_VERSION}.tgz"
        echo "Archiving artifacts to ${artifact}"
        sh "git archive --format tar HEAD | gzip -9 > ${artifact}"
        archiveArtifacts "${artifact}"
        // TODO: publish in s3 bucket
      }
    }

    stage('build-and-publish') {
      for (env in envs) {
        withCredentials([usernamePassword(credentialsId: 'aws-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
          dir('tf/') {
            terraform.set_workspace("${env}")
            // sh """
            //   set +e; tfw plan -out=tf.plan -var-file=../environments/${env}/.terraform.tfvars -detailed-exitcode; echo \$? > status
            // """
            exitCode = terraform.exec("plan -out=tf.plan -var-file=../environments/${env}/.terraform.tfvars -detailed-exitcode")

            echo "[${env}] Terraform Plan Exit Code: ${exitCode}"

            if (exitCode == "0" || exitCode == "2") {
                 currentBuild.result = 'SUCCESS'
                 stash includes: 'tf.plan, *.auto.tfvars .terraform', name: "${env}-plan"
            }
            if (exitCode == "1") {
                 currentBuild.result = 'FAILURE'
            }
            terraform.exec("show tf.plan")
          }
        }
      }
    }
  }

// Do not allocate a node as this is a blocking request and should be run on light weight executor
def userInputEnv = null

// changes to infra are needed
if (exitCode == "2") {
  timeout(time: 1, unit: 'HOURS') {
    try {
       input message: 'Deploy to test?', ok: 'Deploy'
       apply = true
    } catch (err) {
       apply = false
       currentBuild.result = 'UNSTABLE'
}}}

if (apply) {
    node {

      stage('deploy-to-test'){
        // downloadTerraform()
        env.TF_VAR_name = 'iac-demo-test'
        env.PATH = "${env.PATH}:${env.WORKSPACE}"
        withCredentials([usernamePassword(credentialsId: 'aws-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
          dir('tf/') {
            terraform.set_workspace('test')
            unstash name: 'test-plan'
            terraform.exec('apply tf.plan')
          }

          echo "Provisioning with ansible"
          retry(3) {
            sh "anw ansible-playbook -i environments/test site.yml"
            sh "sleep 20"
          }
}}}}


// changes to infra are needed
if (exitCode == "2") {
  timeout(time: 1, unit: 'HOURS') {
    try {
       input message: 'Deploy to prod?', ok: 'Deploy'
       apply = true
    } catch (err) {
       apply = false
       currentBuild.result = 'UNSTABLE'
    }
  }
}

if (apply) {
    node {
      stage('deploy-to-prod'){
        env.TF_VAR_name = 'iac-demo-prod'
        terraform.set_workspace('prod')
        env.PATH = "${env.PATH}:${env.WORKSPACE}"
        withCredentials([usernamePassword(credentialsId: 'aws-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
          dir('tf/') {
            unstash name: 'prod-plan'
            terraform.set_workspace('prod')
            terraform.exec('apply tf.plan')
          }
          echo "Provisioning with ansible"
          retry(3) {
            sh "anw ansible-playbook -i environments/prod site.yml"
            sh "sleep 20"
          }
        }
      }
    }
}

def get_timestamp_version() {
  TimeZone.setDefault(TimeZone.getTimeZone('UTC'))
  def now = new Date()
  return now.format("yyyyMMddHHmmss")
}
