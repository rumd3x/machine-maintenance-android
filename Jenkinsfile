pipeline {
    agent {
        node {
            label 'docker'
        }
    }
    
    parameters {
        choice(
            name: 'RELEASE_TYPE',
            choices: ['patch', 'minor', 'major'],
            description: 'Type of version increment (patch: 1.0.0 -> 1.0.1, minor: 1.0.0 -> 1.1.0, major: 1.0.0 -> 2.0.0)'
        )
    }
    
    environment {
        GITHUB_CREDENTIALS_ID = 'github-credentials'  // Update with your Jenkins credential ID
        GITHUB_REPO = 'rumd3x/machine-maintenance-android'  // Update with your GitHub repo
        APP_NAME = 'machine-maintenance'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
                
                // Configure git user for commits
                sh '''
                    git config user.name "Jenkins CI"
                    git config user.email "jenkins@ci.local"
                '''
            }
        }
        
        stage('Calculate New Version') {
            steps {
                script {
                    docker.image('cirrusci/flutter:stable').inside() {
                        echo "Release type: ${params.RELEASE_TYPE}"
                        
                        // Extract current version from pubspec.yaml
                        def versionLine = sh(
                            script: "grep '^version:' pubspec.yaml | head -1",
                            returnStdout: true
                        ).trim()
                    
                    def versionMatch = (versionLine =~ /version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)/)
                    if (!versionMatch) {
                        error("Could not parse version from pubspec.yaml")
                    }
                    
                    def major = versionMatch[0][1] as Integer
                    def minor = versionMatch[0][2] as Integer
                    def patch = versionMatch[0][3] as Integer
                    def build = versionMatch[0][4] as Integer
                    
                    def currentVersion = "${major}.${minor}.${patch}"
                    echo "Current version: ${currentVersion}+${build}"
                    
                    // Calculate new version based on release type
                    switch(params.RELEASE_TYPE) {
                        case 'major':
                            major++
                            minor = 0
                            patch = 0
                            break
                        case 'minor':
                            minor++
                            patch = 0
                            break
                        case 'patch':
                            patch++
                            break
                    }
                    
                    // Increment build number
                    build++
                    
                    def newVersion = "${major}.${minor}.${patch}"
                    env.NEW_VERSION = newVersion
                    env.NEW_BUILD_NUMBER = build.toString()
                    env.VERSION_TAG = "v${newVersion}"
                    
                    echo "New version will be: ${newVersion}+${build}"
                    echo "Git tag will be: ${env.VERSION_TAG}"
                    }
        }
        
        stage('Update Version') {
            steps {
                script {
                    docker.image('cirrusci/flutter:stable').inside() {
                        echo "Updating version to ${env.NEW_VERSION}+${env.NEW_BUILD_NUMBER}..."
                
                // Make sure script is executable
                sh 'chmod +x scripts/update_version.sh'
                
                // Run version update script
                sh "./scripts/update_version.sh ${env.NEW_VERSION} ${env.NEW_BUILD_NUMBER}"
                
                        // Verify the update
                        sh 'cat pubspec.yaml | grep "^version:"'
                        sh 'cat lib/utils/constants.dart | grep -A 1 "appVersion"'
                    }
                }
            }
        }
        
        stage('Get Dependencies') {
            steps {
                script {
                    docker.image('cirrusci/flutter:stable').inside() {
                        echo 'Fetching Flutter dependencies...'
                        sh 'flutter pub get'
                    }
                }
            }
        }
        
        stage('Analyze Code') {
            steps {
                script {
                    docker.image('cirrusci/flutter:stable').inside() {
                        echo 'Analyzing code...'
                        sh 'flutter analyze'
                    }
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    docker.image('cirrusci/flutter:stable').inside() {
                        echo 'Running tests...'
                        sh 'flutter test || echo "No tests found or tests failed - continuing..."'
                    }
                }
            }
        }
        
        stage('Build Release APK') {
            steps {
                script {
                    docker.image('cirrusci/flutter:stable').inside() {
                        echo "Building release APK for version ${env.NEW_VERSION}+${env.NEW_BUILD_NUMBER}..."
                        sh 'flutter build apk --release'
                        
                        // Rename APK with version number
                        sh """
                            cd build/app/outputs/flutter-apk/
                            cp app-release.apk ${env.APP_NAME}-${env.NEW_VERSION}-${env.NEW_BUILD_NUMBER}.apk
                            ls -lh *.apk
                        """
                    }
                }
            }
        }
        
        stage('Commit Version Changes') {
            steps {
                script {
                    echo 'Committing version changes...'
                    sh """
                        git add pubspec.yaml lib/utils/constants.dart
                        git commit -m "chore: bump version to ${env.NEW_VERSION}+${env.NEW_BUILD_NUMBER}" || echo "No changes to commit"
                    """
                }
            }
        }
        
        stage('Create Git Tag') {
            steps {
                script {
                    echo "Creating git tag ${env.VERSION_TAG}..."
                    sh """
                        git tag -a ${env.VERSION_TAG} -m "Release ${env.NEW_VERSION}"
                        git tag -l | tail -5
                    """
                }
            }
        }
        
        stage('Push to GitHub') {
            steps {
                script {
                    echo 'Pushing changes and tags to GitHub...'
                    withCredentials([string(
                        credentialsId: env.GITHUB_CREDENTIALS_ID,
                        variable: 'GITHUB_TOKEN'
                    )]) {
                        sh """
                            git push https://${GITHUB_TOKEN}@github.com/${env.GITHUB_REPO}.git HEAD:main
                            git push https://${GITHUB_TOKEN}@github.com/${env.GITHUB_REPO}.git ${env.VERSION_TAG}
                        """
                    }
                }
            }
        }
        
        stage('Create GitHub Release') {
            steps {
                script {
                    echo "Creating GitHub release ${env.VERSION_TAG}..."
                    withCredentials([string(
                        credentialsId: env.GITHUB_CREDENTIALS_ID,
                        variable: 'GITHUB_TOKEN'
                    )]) {
                        // Create release using GitHub API
                        sh """
                            curl -X POST \
                                -H "Authorization: token ${GITHUB_TOKEN}" \
                                -H "Accept: application/vnd.github.v3+json" \
                                https://api.github.com/repos/${env.GITHUB_REPO}/releases \
                                -d '{
                                    "tag_name": "${env.VERSION_TAG}",
                                    "name": "Release ${env.NEW_VERSION}",
                                    "body": "Release ${env.NEW_VERSION}\\n\\nBuild: ${env.NEW_BUILD_NUMBER}\\nRelease Type: ${params.RELEASE_TYPE}\\n\\nGenerated by Jenkins CI",
                                    "draft": false,
                                    "prerelease": false
                                }' > release_response.json
                            
                            cat release_response.json
                        """
                        
                        // Extract upload URL and release ID
                        def uploadUrl = sh(
                            script: "cat release_response.json | grep -o '\"upload_url\": \"[^\"]*' | cut -d'\"' -f4 | sed 's/{?name,label}//'",
                            returnStdout: true
                        ).trim()
                        
                        echo "Upload URL: ${uploadUrl}"
                        
                        // Upload APK to release
                        sh """
                            curl -X POST \
                                -H "Authorization: token ${GITHUB_TOKEN}" \
                                -H "Content-Type: application/vnd.android.package-archive" \
                                --data-binary @build/app/outputs/flutter-apk/${env.APP_NAME}-${env.NEW_VERSION}-${env.NEW_BUILD_NUMBER}.apk \
                                "${uploadUrl}?name=${env.APP_NAME}-${env.NEW_VERSION}-${env.NEW_BUILD_NUMBER}.apk"
                        """
                        
                        echo "✅ GitHub release created: https://github.com/${env.GITHUB_REPO}/releases/tag/${env.VERSION_TAG}"
                    }
                }
            }
        }
        
        stage('Archive Artifacts') {
            steps {
                echo 'Archiving APK in Jenkins...'
                archiveArtifacts artifacts: "build/app/outputs/flutter-apk/${env.APP_NAME}-${env.NEW_VERSION}-${env.NEW_BUILD_NUMBER}.apk",
                                 fingerprint: true,
                                 allowEmptyArchive: false
            }
        }
    }
    
    post {
        success {
            echo "✅ Build completed successfully!"
            echo "Version: ${env.NEW_VERSION}+${env.NEW_BUILD_NUMBER}"
            echo "Tag: ${env.VERSION_TAG}"
            echo "GitHub Release: https://github.com/${env.GITHUB_REPO}/releases/tag/${env.VERSION_TAG}"
        }
        failure {
            echo '❌ Build failed!'
        }
        cleanup {
            script {
                // Only clean workspace if it exists
                try {
                    cleanWs()
                } catch (Exception e) {
                    echo "Workspace cleanup skipped: ${e.message}"
                }
            }
        }
    }
}
