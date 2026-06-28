pipeline {
    agent any
    stages {
        stage('Terraform plan - Feature Branch') {
            when {
                branch pattern: "feature/.*", comparator: "REGEXP"                
            }
            steps {
                sh "terraform init"
                sh "terraform plan"   
            }
        }
    }
}