pipeline {
    agent any

    environment {
        GIT_COMMIT_ID =  sh (script: "git rev-parse HEAD", returnStdout: true).trim()
    }

    stages {
        stage('Build') {
            steps {
                // create image and build app
                sh "docker build -t ${params.ECR_URI}:${env.GIT_COMMIT_ID} ."
            }
        }
        stage('Test') {
            steps {
                // run app in container
                sh "docker run -d -p 3000:3000 ${params.ECR_URI}:${env.GIT_COMMIT_ID}"

                // check connection to website
            sh "bash ${WORKSPACE}/integration-test.sh ${params.TARGET_URI}"
            }
            post {
                always {
                    // kill running containers
                    sh "docker ps -q | xargs docker kill"
                }
            }
        }
        stage('Archive') {
            steps {
                // connect to aws elastic container registry
                sh "aws ecr get-login --no-include-email --region ${params.AWS_REGION} | bash"

                // archive and tag image to aws elastic container registry
                sh """
                docker tag ${params.ECR_URI}:${env.GIT_COMMIT_ID} ${params.ECR_URI}:release
                docker push ${params.ECR_URI}:release
                """
            }
        }
        stage('Deploy') {
            steps {
                // run image on production instance
                // /var/lib/cloud/scripts/per-boot/start-website runs image tagged release on reboot
                sh "aws ec2 reboot-instances --instance-ids ${params.INSTANCE_ID} --region ${params.AWS_REGION}"
            }
        }
    }
}
