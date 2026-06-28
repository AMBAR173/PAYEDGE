pipeline {
    agent any
    stages {
        stage('Terraform plan - Feature Branch') {
            when {branch "feature/.*"}
            steps {
                sh "terraform init"
                sh "terraform plan"    
            }
        }
    }
}