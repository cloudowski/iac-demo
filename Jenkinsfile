def pullRequest = false
def exitCode = -1
def apply = false

def envs = ['test', 'prod']


ansiColor('xterm') {
  node {
    // Set github status that the images could be built successfully
    step([$class: 'GitHubSetCommitStatusBuilder'])
    checkout scm
    // we don't release or ask for user input on pull requests
    pullRequest = env.BRANCH_NAME != 'master'

    // version with timestamp
    env.CODE_VERSION = get_timestamp_version()
    // set terraform variables
    env.TF_INPUT = 0
    env.TF_IN_AUTOMATION = 1

    currentBuild.displayName = "${env.CODE_VERSION}"


    stage('test') {

      // TODO: execute real tests here
      // sh "./test/mid-level-tests.sh"
      sh "echo ansible-lint"

      // downloadTerraform()
      env.PATH = "${env.PATH}:${env.WORKSPACE}:${env.WORKSPACE}/utils"
      withCredentials([usernamePassword(credentialsId: 'aws-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
        dir('tf/') {
          sh """
            tfw init
            tfw get -update=true
            """
          sh "tfw validate"
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
            tf_set_workspace("${env}")
            sh """
              set +e; tfw plan -out=tf.plan -var-file=../environments/${env}/.terraform.tfvars -detailed-exitcode; echo \$? > status
            """
            exitCode = readFile('status').trim()

            echo "[${env}] Terraform Plan Exit Code: ${exitCode}"
            if (exitCode == "0" || exitCode == "2") {
                 currentBuild.result = 'SUCCESS'
                 stash includes: 'tf.plan, *.auto.tfvars .terraform', name: "${env}-plan"
            }
            if (exitCode == "1") {
                 currentBuild.result = 'FAILURE'
            }
            sh "tfw show tf.plan"
          }
        }
      }
    }
  }
}
// pull requests only runs a plan
//if(pullRequest){
//  return
//}

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
  ansiColor('xterm') {
    node {

      stage('deploy-to-test'){
        // downloadTerraform()
        env.TF_VAR_name = 'iac-demo-test'
        env.PATH = "${env.PATH}:${env.WORKSPACE}"
        withCredentials([usernamePassword(credentialsId: 'aws-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
          dir('tf/') {
            tf_set_workspace('test')
            unstash name: 'test-plan'
            sh "tfw apply tf.plan"
          }
          echo "Provisioning with ansible"
          retry(3) {
            sh "anw ansible-playbook -i environments/test site.yml"
            sh "sleep 20"
          }
}}}}}


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
  ansiColor('xterm') {
    node {

      stage('deploy-to-prod'){
        downloadTerraform()
        env.TF_VAR_name = 'iac-demo-prod'
        tf_set_workspace('prod')
        env.PATH = "${env.PATH}:${env.WORKSPACE}"
        withCredentials([usernamePassword(credentialsId: 'aws-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
          dir('tf/') {
            unstash name: 'prod-plan'
            tf_set_workspace('prod')
            sh "tfw apply tf.plan"
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
}


def downloadTerraform(){

  if (!fileExists('terraform')) {
    sh "curl -o  terraform_0.10.7_linux_amd64.zip https://releases.hashicorp.com/terraform/0.10.7/terraform_0.10.7_linux_amd64.zip && unzip -o terraform_0.10.7_linux_amd64.zip && chmod 777 terraform"
  } else {
    println("terraform already downloaded")
  }
}

def prepareTerraform() {
  downloadTerraform()
}

def tf_set_workspace(ws) {
  sh "tfw workspace select ${ws} 2> /dev/null || tfw workspace new ${ws}"
  sh "tfw workspace select ${ws}"

}

def get_timestamp_version() {
  TimeZone.setDefault(TimeZone.getTimeZone('UTC'))
  def now = new Date()
  return now.format("yyyyMMddHHmmss")
}
