pipeline {
    agent any
    options {
        skipDefaultCheckout(true)
    }
    environment {
        TF_TOKEN_app_terraform_io = credentials('terraform-cloud-token')
    }
    stages {
        stage('Clean workspace') {
            steps {
                deleteDir()
            }
        }
        stage('Verify Git and checkout') {
            steps {
                sh '''
                    echo "Checking Git on the Jenkins agent..."
                    whoami
                    echo "PATH=$PATH"
                    if ! command -v git >/dev/null 2>&1; then
                        echo "ERROR: git is not available on this Jenkins agent."
                        exit 1
                    fi
                    git --version
                '''
                checkout([$class: 'GitSCM',
                    branches: [[name: "*/${env.BRANCH_NAME}" ]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/AMBAR173/PAYEDGE.git',
                        credentialsId: 'c662229a-3f53-4e19-899b-ab17b884f206'
                    ]]
                ])
            }
        }
        stage('Terraform plan - Feature Branch') {
            when {
                branch pattern: "feature/.*", comparator: "REGEXP"
            }
            steps {
                sh '''
                   terraform init
                   terraform plan
                '''
            }
        }
    }
}