pipeline {

  environment {
    PROJECT_DIR = "/app"
    REGISTRY = "conorsm/calc_app" + ":" + "$BUILD_NUMBER"
    DOCKER_CREDENTIALS = "docker_auth"
    DOCKER_IMAGE = ""
  }

  agent any

  options {
    skipStagesAfterUnstable()
  }

  stages {

    stage('Cloning The Code from GIT') {
      steps {
        git 'https://github.com/ConorSM/calc_app.git'
      }
    }

    stage('Build-Image') {
      steps {
        script {
          DOCKER_IMAGE = docker.build REGISTRY
        }
      }
    }

    stage('Testing the Code') {
      steps {
        script {
          sh '''
          docker run -v $PWD/test-reports:/reports --workdir $PROJECT_DIR $REGISTRY pytest -v --junitxml=/reports/results.xml
          '''
        }
      }
      post {
        always {
          junit testResults: '**/test-reports/*.xml'
        }
      }
    }

    stage('Deploy To Docker Hub') {
      steps {
        script {
          docker.withRegistry('', DOCKER_CREDENTIALS){
            DOCKER_IMAGE.push()
          }
        }
      }
    }

    stage('Removing the Docker Image') {
      steps {
        sh "docker rmi $REGISTRY"
      }
    }
  }

}
