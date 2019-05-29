pipeline {
    agent { label "minion-farm"}
    stages {
        stage('Update node') {
            steps {
                sh 'sudo dnf -y update'
            }    
        }
        stage('Install ChefDK') {
            steps {
                script {
                    def chefdkExists = fileExists '/usr/bin/chef-client'
                    if (chefdkExists) {
                        echo 'Skipping Chef install...already installed'
                    }else{
                        sh 'wget https://packages.chef.io/files/stable/chefdk/4.0.60/el/7/chefdk-4.0.60-1.el7.x86_64.rpm'
                        sh 'sudo rpm -ivh chefdk-4.0.60-1.el7.x86_64.rpm'
                    }
                }
            }
        }
        stage('Download Cookbook') {
            steps {
                git credentialsId: 'github-creds', url: 'git@github.com:technotrainertm1/apache.git'
            }
        }
        stage('Install Docker ') {
            steps {
                script {
                    def dockerExists = fileExists '/usr/bin/docker'
                    if (dockerExists) {
                        echo 'Skipping Docker install...already installed'
                    }else{
                        sh 'sudo yum install -y git yum-utils'
                        sh 'sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo'
                        sh 'sudo yum makecache fast'
                        sh 'sudo yum -y install docker-ce'
                        sh 'sudo systemctl enable docker'
                        sh 'sudo systemctl start docker'
                        sh 'sudo usermod -aG docker $USER'
                        sh 'sudo systemctl stop getty@tty1.service'
                        sh 'sudo systemctl mask getty@tty1.service'
                        
                    }    
                    sh 'sudo docker run hello-world'
                }
            }
        }
        stage('Install Ruby and Test Kitchen') {
            steps {
                sh 'sudo dnf install -y rubygems ruby-devel'
                sh 'chef gem install kitchen-docker'
            }
        }
        stage('Run Test Kitchen') {
            steps {
               sh 'sudo kitchen test' 
            }
        }
        stage('Slack Notification') {
            steps {
                slackSend message: "Team DevOps: Please approve ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.JOB_URL} | Open>)"
            }
        }
        stage('Let the human feel important') {
            input { message "Click Proceed to continue the build"}
            steps {
                echo "User Input"    
            }
        }
        stage('Upload Cookbook to Chef Server, Converge Nodes') {
            steps {
                withCredentials([zip(credentialsId: 'chef-server-creds', variable: 'CHEFREPO')]) {
                    sh 'mkdir -p $CHEFREPO/chef-repo/cookbooks/apache'
                    sh 'sudo rm -rf $WORKSPACE/Berksfile.lock'
                    sh 'mv $WORKSPACE/* $CHEFREPO/chef-repo/cookbooks/apache'
                    sh "knife cookbook upload apache --force -o $CHEFREPO/chef-repo/cookbooks -c $CHEFREPO/chef-repo/.chef/knife.rb"
                    withCredentials([sshUserPrivateKey(credentialsId: 'agent-creds', keyFileVariable: 'AGENT_SSHKEY', passphraseVariable: '', usernameVariable: '')]) {
                        sh "knife ssh 'role:webserver' -x ubuntu -i $AGENT_SSHKEY 'sudo chef-client' -c $CHEFREPO/chef-repo/.chef/knife.rb"      
                    }
                }
            }
        }
    }
}
