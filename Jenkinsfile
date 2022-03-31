pipeline {
    agent none

    stages {
        stage("build") {
            agent {
                docker { image 'docker:dind' }
            }
            steps {
                echo "building docker image..."

                configFileProvider([configFile(fileId: 'myBranchSettingsFile', variable: 'BRANCH_SETTINGS')]) {
                    echo "Branch ${env.BRANCH_NAME}"
                    echo "Branch Settings: ${BRANCH_SETTINGS}"

                    script {
                        def config = readJSON file:"$BRANCH_SETTINGS"
                        def branchConfig = config."${env.BRANCH_NAME}"

                        if (branchConfig) {
                            echo "using config for branch ${env.BRANCH_NAME}"

                            def DOCKER_REGISTRY = branchConfig.DOCKER_REGISTRY
                            def dockerImage = docker.build(branchConfig.IMAGE_NAME)

                            docker.withRegistry("${branchConfig.DOCKER_REGISTRY}", 'docker-registry-credentials') {
                                dockerImage.push("${env.BUILD_NUMBER}")
                                dockerImage.push("latest")
                            }
                        }
                        else {
                            error("Build failed because failed to fetch settings for branch")
                        }
                    }
                }
            }
        }

        stage("deploy") {
            agent {
                docker { image 'ubuntu:20.04' }
            }
            steps {
                configFileProvider([configFile(fileId: 'myBranchSettingsFile', variable: 'BRANCH_SETTINGS')]) {
                    echo "Branch ${env.BRANCH_NAME}"
                    echo "Branch Settings: ${BRANCH_SETTINGS}"

                    script {
                        def config = readJSON file:"$BRANCH_SETTINGS"
                        def branchConfig = config."${env.BRANCH_NAME}"

                        if (branchConfig) {
                            echo "using config for branch ${env.BRANCH_NAME}"
                            def ASG_NAME = branchConfig.ASG_NAME
                            def IAM_CREDENTIALS_NAME = branchConfig.IAM_ASG_CREDENTIALS_NAME
                            echo "credentials name: " + branchConfig.IAM_ASG_CREDENTIALS_NAME
                            echo "credentials name2: " + IAM_CREDENTIALS_NAME

                            withCredentials([usernamePassword(credentialsId: IAM_CREDENTIALS_NAME, passwordVariable: 'AWS_KEY_SECRET', usernameVariable: 'AWS_KEY_ID')]) {
                                // install the AWS CLI
                                sh "apt-get update && apt-get install python3-pip -y && pip3 install awscli"
                                sh 'echo credentials ID: ' + IAM_CREDENTIALS_NAME
                                sh 'echo Username: ' + AWS_KEY_ID
                                sh 'echo Password: ' + AWS_KEY_SECRET

                                // set the aws credentials
                                sh 'aws configure set aws_access_key_id ' + AWS_KEY_ID
                                sh 'aws configure set aws_secret_access_key ' + AWS_KEY_SECRET

                                // use the AWS CLI to send the request to rotate the servers,
                                // which will cause them to pull the latest Docker image.
                                // https://docs.aws.amazon.com/cli/latest/reference/autoscaling/start-instance-refresh.html
                                sh 'aws autoscaling start-instance-refresh --auto-scaling-group-name ' + ASG_NAME
                            }
                        }
                        else {
                            error("Build failed because failed to fetch settings for branch")
                        }
                    }
                }
            }
        }
    }
}
