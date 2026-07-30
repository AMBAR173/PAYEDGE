pipeline {
    agent any
    options {
        skipDefaultCheckout(true)
    }
    parameters {
        choice(name: 'ACTION', choices: ['PLAN','APPLY','DESTROY'], description: 'Pipeline action')
        choice(name: 'ENV', choices: ['DEV'], description: 'Target enviornment')
        choice(name: 'REGION', choices: ['us-east-1'], description: 'AWS region')
        string(name: 'CHANGE_NUMBER', defaultValue: '', description: 'Change number (required for SANDBOX/PROD)')
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
                allOf {
                    expression { return params.ACTION == 'PLAN' }
                    branch pattern: "feature/.*", comparator: "REGEXP"
                }
            }
            steps {
                                sh '''
                                     # Generate backend.tf dynamically so workspace name is set correctly
                                     cat > backend.tf <<EOF
terraform {
    backend "remote" {
        organization = "$TF_ORGANIZATION"
        workspaces {
            name = "$TF_WORKSPACE_NAME"
        }
    }
}
EOF

                                     cat > terraform.auto.tfvars <<TFVARS
env = "${DEPLOY_ENV}"
region = "${AWS_REGION}"
TFVARS

                                     terraform init -input=false
                                     terraform plan -lock=false -input=false
                                '''
            }
        }
        stage('Terraform plan - Dev') {
            when {
                allOf {
                    expression { return params.ACTION == 'PLAN' }
                    branch 'develop'
                }
            }
            steps {
                sh '''
                    # Generate backend.tf dynamically so workspace name is set correctly
                    cat > backend.tf <<EOF
terraform {
    backend "remote" {
        organization = "$TF_ORGANIZATION"
        workspaces {
            name = "$TF_WORKSPACE_NAME"
        }
    }
}
EOF

                    cat > terraform.auto.tfvars <<TFVARS
env = "${DEPLOY_ENV}"
region = "${AWS_REGION}"
TFVARS

                    terraform init -input=false
                    terraform plan -lock=false -input=false
                '''
            }
        }

        stage('Terraform apply') {
            when {
                allOf {
                    expression { return params.ACTION == 'APPLY' }
                    branch 'develop'
                }
            }
            steps {
                script {
                    input message: "Proceed with terraform apply for ${env.TF_WORKSPACE_NAME} (${params.ENV}/${params.REGION})?", ok: 'Apply'
                    sh '''
                        cat > backend.tf <<EOF
terraform {
    backend "remote" {
        organization = "$TF_ORGANIZATION"
        workspaces {
            name = "$TF_WORKSPACE_NAME"
        }
    }
}
EOF

                        cat > terraform.auto.tfvars <<TFVARS
env = "${DEPLOY_ENV}"
region = "${AWS_REGION}"
TFVARS

                        terraform init -input=false
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Terraform destroy') {
            when {
                allOf {
                    expression { return params.ACTION == 'DESTROY' }
                    branch 'develop'
                }
            }
            steps {
                script {
                    def confirm = input message: "DANGER: Destroy workspace ${env.TF_WORKSPACE_NAME}. Type DESTROY to confirm.", parameters: [string(name: 'CONFIRM', defaultValue: '')]
                    if (confirm != 'DESTROY') {
                        error 'Destroy confirmation failed - aborting.'
                    }
                    sh '''
                        cat > backend.tf <<EOF
terraform {
    backend "remote" {
        organization = "$TF_ORGANIZATION"
        workspaces {
            name = "$TF_WORKSPACE_NAME"
        }
    }
}
EOF

                        cat > terraform.auto.tfvars <<TFVARS
env = "${DEPLOY_ENV}"
region = "${AWS_REGION}"
TFVARS

                        terraform init -input=false
                        terraform destroy -auto-approve
                    '''
                }
            }
        }
    }
}
