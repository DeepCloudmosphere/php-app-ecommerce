
pipeline {
  agent{
        label "ansible"
    }
        
    environment {
        AWS_ACCOUNT_ID="074548180348"
        AWS_DEFAULT_REGION="us-east-1"
        WORKSPACE="${env.WORKSPACE}"
        IMAGE_REPO_NAME="php-web-app"
        GIT_COMMIT_HASH = sh (script: "git log -n 1 --pretty=format:'%H'", returnStdout: true) 
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
       //  When using returnStdout a trailing whitespace will be appended to the returned string. Use .trim() to remove this.
        SLACK_TOKEN= sh (script: "aws secretsmanager get-secret-value --secret-id jenkins --region us-east-1 | python3 -c \"import sys;import json;print(json.loads(json.loads(sys.stdin.read())['SecretString'])['slackToken'])\"", returnStdout: true).trim()
         
        
    } 

  stages {
    stage("Set Up") {
      steps {
        echo "Logging into the private AWS Elastic Container Registry"
        script {
          sh """
           aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
          """
        }
      }
    }
    stage("Build production Image") {
      steps {
          
        echo 'Build the production image'
        script {
            
            
                    try{
                        
                         dockerImage = docker.build("${REPOSITORY_URI}:${GIT_COMMIT_HASH}","phpfpm/")
                         dockerImage.push()
                         
                    // Fill the slack message with the success message
                        textMessage = "Commit hash: $GIT_COMMIT_HASH -- Build has successfully completed and pushed to ECR repository"
                        inError = false
                         
                    } catch(e) {
                        
                        echo "$e"
                        // Fill the slack message with the success message
                        textMessage = "Commit hash: $GIT_COMMIT_HASH -- Build has not successfully completed"
                        inError = true
                     } finally {
                         
                         
                        // Send Slack notification with the result of the tests
                        sh"""
                            curl https://slack.com/api/chat.postMessage -X POST -d channel=#ci-cd-pipeline -d text='${textMessage}' -d token='${SLACK_TOKEN}'
                        """ 
                        if(inError) {
                          // Send an error signal to stop the pipeline
                          error("Failed build image")
                        }  
                     }
            
        }
         
      }
    }
    
    stage("Deploy to EKS Cluster") {
      steps {
        echo 'Deploy release to production'
        script {
            
            
                    try{
                       // replace image and tag    
                                           
                       sh """
                          ansible-playbook  /home/ubuntu/helm_deployment.yaml
                       """
                        // Fill the slack message with the success message
                        textMessage = "Commit hash: $GIT_COMMIT_HASH -- Deployment has  successfully to EKS(prod)"
                        inError = false 
                        
                    } catch(e) {

                        echo "$e"
                        // Fill the slack message with the success message
                        textMessage = "Commit hash: $GIT_COMMIT_HASH -- Deployment to EKS(prod) has failed"
                        inError = true

                    } finally {

                        // Send Slack notification with the result of the tests
                        sh"""
                            curl https://slack.com/api/chat.postMessage -X POST -d channel=#ci-cd-pipeline -d text='${textMessage}' -d token='${SLACK_TOKEN}'
                        """ 
                        if(inError) {
                          // Send an error signal to stop the pipeline
                          error("Failed deployment")
                        }  
                         
                    }
              }
            
        }
      }
    
    stage("Clean Up") {
      steps {
        echo 'Clean up local docker images'
        script {
          sh """
          echo "Hello World"
          """
        }
      }
    }
  }

}