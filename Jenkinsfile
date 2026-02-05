pipeline {
    agent any
    
    environment {
        // Update this path to match your Jenkins Flutter installation
        FLUTTER_HOME = tool name: 'Flutter', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
        PATH = "${FLUTTER_HOME}/bin:${env.PATH}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Flutter Doctor') {
            steps {
                echo 'Running Flutter Doctor...'
                sh 'flutter doctor -v'
            }
        }
        
        stage('Get Dependencies') {
            steps {
                echo 'Fetching Flutter dependencies...'
                sh 'flutter pub get'
            }
        }
        
        stage('Analyze Code') {
            steps {
                echo 'Analyzing code...'
                sh 'flutter analyze'
            }
        }
        
        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                sh 'flutter test'
            }
        }
        
        stage('Build APK') {
            steps {
                echo 'Building release APK...'
                sh 'flutter build apk --release'
            }
        }
        
        stage('Archive Artifacts') {
            steps {
                echo 'Archiving APK...'
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk', 
                                 fingerprint: true,
                                 allowEmptyArchive: false
            }
        }
    }
    
    post {
        success {
            echo 'Build completed successfully!'
        }
        failure {
            echo 'Build failed!'
        }
        always {
            cleanWs()
        }
    }
}
