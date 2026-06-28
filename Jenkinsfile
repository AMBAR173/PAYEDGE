pipeline {
    agent any
    stages {
        stage('Terraform plan - Feature Branch') {
            when {
                branch pattern: "feature/.*" comparator: "REGEXP"
            }    
            steps {
                sh '''
                   terraform init
                   terraform plan -var-file=variables/dev-us-east-1.tfvars
                '''
            }    
        }
    }
}