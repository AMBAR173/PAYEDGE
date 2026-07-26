pipeline {
    agent any
    options {
        skipDefaultCheckout(true)
    }
    parameters {
        choice(name: 'ENV', choices: ['DEV'], description: 'Target enviornment')
        choice(name: 'REGION', choices: ['us-east-1'], description: 'AWS region')
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
        stage('Load environment config') {
            steps {
                script {
                    def config = readYaml file: 'env-mapping.yaml'
                    def envConfig = config.environments[params.ENV][params.REGION]

                    if (!envConfig) {
                        error "No mapping found for ${params.ENV}/${params.REGION} in env-mapping.yaml"
                    }

                    env.TF_ORGANIZATION = envConfig.organization
                    env.TF_WORKSPACE_NAME = envConfig.workspace_name
                    env.DEPLOY_ENV = params.ENV
                    env.AWS_REGION = params.REGION
                }
            }
        }
        stage('Terraform plan - Feature Branch') {
            when {
                branch pattern: "feature/.*", comparator: "REGEXP"
            }
            steps {
                sh '''
                   terraform init \
                        -backend-config="organization=${TF_ORGANIZATION}" \
                        -backend-config="workspaces.name=${TF_WORKSPACE_NAME}"
                   terraform plan -lock=false -input=false \
                        -var "env=${DEPLOY_ENV}" \
                        -var "region=${AWS_REGION}"
                '''
            }
        }
        stage('Terraform plan - Dev') {
            when {
                branch 'develop'
            }
            steps {
                sh '''
                   terraform init \
                        -backend-config="organization=${TF_ORGANIZATION}" \
                        -backend-config="workspaces.name=${TF_WORKSPACE_NAME}"
                   terraform plan -lock=false -input=false \
                        -var "env=${DEPLOY_ENV}" \
                        -var "region=${AWS_REGION}"
                '''
            }
        }
    }
}