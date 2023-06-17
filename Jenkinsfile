pipeline {
  agent{
        label "ansible"
    }
  stages {
    stage("Set Up") {
      steps {
        echo "Logging into the private AWS Elastic Container Registry"
        script {
          sh """
          echo "Hello World"
          """
        }
      }
    }
    stage("Build production Image") {
      steps {
        echo 'Build the staging image for more tests'
        script {
          sh """
          echo "Hello World"
          """
        }
      }
    }
    stage("Deploy to EKS Cluster") {
      steps {
        echo 'Deploy release to production
        script {
          sh """
          echo "Hello World"
          """
        }
      }
    }
    stage("Clean Up") {
      steps {
        echo 'Clean up local docker images
        script {
          sh """
          echo "Hello World"
          """
        }
      }
    }
  }
}
