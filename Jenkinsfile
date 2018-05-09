pipeline {
    agent any

    environment {
        GIT_COMMIT_ID =  sh (script: "git rev-parse HEAD", returnStdout: true).trim()
    }

    stages {
        stage('Build') {
            steps {
                // connect to aws elastic container registry
                sh "aws ecr get-login --no-include-email --region ${params.AWS_REGION} | bash"

                // create image to build app
                sh """
                docker build -t ${params.ECR_URI}:${env.GIT_COMMIT_ID} .
                docker push ${params.ECR_URI}:${env.GIT_COMMIT_ID}
                """
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
        stage('Deploy') {
            steps {
                // get image and tag for release
                sh """
                docker pull ${params.ECR_URI}:${env.GIT_COMMIT_ID}
                docker tag ${params.ECR_URI}:${env.GIT_COMMIT_ID} ${params.ECR_URI}:release
                docker push ${params.ECR_URI}:release
                """

                // run image on production instance
                // /var/lib/cloud/scripts/per-boot/start-website runs image tagged release on reboot
                sh "aws ec2 reboot-instances --instance-ids ${params.INSTANCE_ID} --region ${params.AWS_REGION}"
            }
        }
    }
}
