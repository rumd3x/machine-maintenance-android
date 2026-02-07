# Jenkins Setup Guide for Machine Maintenance Android

Quick setup guide for configuring Jenkins to run the CI/CD pipeline.

## Prerequisites

- Jenkins installed and running
- Docker installed on Jenkins host
- GitHub account with repository access
- Jenkins Docker Pipeline plugin

## Step 1: Install Docker Pipeline Plugin

1. Go to **Jenkins** → **Manage Jenkins** → **Manage Plugins**
2. Click **Available** tab
3. Search for "Docker Pipeline"
4. Check the box and click **Install without restart**
5. Wait for installation to complete

## Step 2: Configure Docker Node

### Configure Jenkins to Use Host Docker Daemon

**Important**: If your Jenkins is running in a Docker container, you need to mount the host's Docker socket so Jenkins can use the host Docker daemon instead of nesting containers.

#### If Jenkins Runs on Host (Not in Container)

```bash
# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# Verify (run as jenkins user)
sudo -u jenkins docker ps
```

#### If Jenkins Runs in Docker Container

When starting your Jenkins container, mount the Docker socket:

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(which docker):/usr/bin/docker \
  jenkins/jenkins:lts
```

**Or if using docker-compose:**

```yaml
version: '3'
services:
  jenkins:
    image: jenkins/jenkins:lts
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock  # Mount host Docker socket
      - /usr/bin/docker:/usr/bin/docker            # Mount Docker binary
    user: root  # Required to access Docker socket
volumes:
  jenkins_home:
```

Then give Jenkins access inside the container:

```bash
# Enter Jenkins container
docker exec -it jenkins bash

# Install Docker CLI (if not already present)
apt-get update && apt-get install -y docker.io

# Add jenkins user to docker group (inside container)
usermod -aG docker jenkins

# Restart Jenkins container
docker restart jenkins
```

### Label a Node as "docker"

1. Go to **Jenkins** → **Manage Jenkins** → **Manage Nodes and Clouds**
2. Click on your node (e.g., "Built-in Node" or your agent)
3. Click **Configure**
4. In the **Labels** field, add: `docker`
5. Click **Save**

## Step 3: Create GitHub Personal Access Token

1. Go to: https://github.com/settings/tokens
2. Click **Generate new token** → **Generate new token (classic)**
3. Name: `Jenkins CI - Machine Maintenance`
4. Select scopes:
   - ✅ **repo** (Full control of private repositories)
     - ✅ repo:status
     - ✅ repo_deployment
     - ✅ public_repo
     - ✅ repo:invite
     - ✅ security_events
   - ✅ **write:packages** (optional, for package registry)
5. Click **Generate token**
6. **Copy the token immediately** (you won't see it again!)

## Step 4: Add GitHub Credentials to Jenkins

### Option A: Secret Text (Recommended for API)

1. Go to **Jenkins** → **Manage Jenkins** → **Manage Credentials**
2. Click on **(global)** domain
3. Click **Add Credentials**
4. Configure:
   - **Kind**: Secret text
   - **Scope**: Global
   - **Secret**: Paste your GitHub token
   - **ID**: `github-credentials`
   - **Description**: GitHub Token for Machine Maintenance Android
5. Click **OK**

### Option B: Username with Password (Alternative)

1. Same steps as above, but:
   - **Kind**: Username with password
   - **Username**: Your GitHub username
   - **Password**: Your GitHub token (not your GitHub password!)
   - **ID**: `github-credentials`

## Step 5: Update Jenkinsfile Configuration

Edit `Jenkinsfile` and update these variables:

```groovy
environment {
    GITHUB_CREDENTIALS_ID = 'github-credentials'  // Must match credential ID from Step 4
    GITHUB_REPO = 'your-username/machine-maintenance-android'  // Update with your repo
    APP_NAME = 'machine-maintenance'  // App name for APK files
}
```

## Step 6: Create Jenkins Pipeline Job

1. Go to **Jenkins** → **New Item**
2. Enter name: `machine-maintenance-android-release`
3. Select: **Pipeline**
4. Click **OK**

### Configure Pipeline

**General Section**:
- ✅ Check "This project is parameterized"
  - Parameters will be auto-detected from Jenkinsfile on first scan
  - Or manually add:
    - **Name**: RELEASE_TYPE
    - **Type**: Choice Parameter
    - **Choices**: (one per line)
      ```
      patch
      minor
      major
      ```
    - **Description**: Type of version increment

**Pipeline Section**:
- **Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: `https://github.com/your-username/machine-maintenance-android.git`
- **Credentials**: Select your GitHub credentials (or None for public repos)
- **Branch Specifier**: `*/main`
- **Script Path**: `Jenkinsfile`

Click **Save**

## Step 7: First Build - Parameter Discovery

### ⚠️ IMPORTANT: Parameters Must Be Discovered First

**Jenkins needs to scan the Jenkinsfile to discover parameters. The first run will fail, but this is expected.**

#### Method 1: Let Jenkins Scan (Recommended)

1. After saving the pipeline job, Jenkins will automatically scan the Jenkinsfile
2. Wait a few seconds for the scan to complete
3. Refresh the page
4. You should now see **Build with Parameters** button

#### Method 2: Manual Discovery Build (If Method 1 Doesn't Work)

If you don't see "Build with Parameters" button:

1. Click **Build Now** (this will fail - that's OK!)
2. The build will fail with error about missing parameters or workspace cleanup
3. This is expected - Jenkins is loading the parameters from Jenkinsfile
4. Refresh the page
5. Now you'll see **Build with Parameters** button

**Why this happens**: Jenkins needs to execute the pipeline once to discover the `parameters` block in the Jenkinsfile.

### Run Your First Real Release Build

1. Click **Build with Parameters**
2. Select **RELEASE_TYPE**: `patch` (for first release)
3. Click **Build**
4. Watch console output for progress

## Step 8: Verify Build

### Check Console Output

Look for these success messages:
```
✅ Build completed successfully!
Version: 1.0.1+2
Tag: v1.0.1
GitHub Release: https://github.com/your-username/machine-maintenance-android/releases/tag/v1.0.1
```

### Verify GitHub

1. Check repository commits:
   - Should see commit: `chore: bump version to X.Y.Z+N`
2. Check repository tags:
   - Should see tag: `vX.Y.Z`
3. Check releases:
   - Should see release with APK attached

### Download APK

From Jenkins:
- Build page → **Artifacts** → Download APK

From GitHub:
- Go to Releases tab
- Click on latest release
- Download APK from Assets

## Troubleshooting

### Error: "process apparently never started" or Docker workspace mounting issues

**Problem**: Jenkins is running in a container without proper Docker socket mounting, or workspace paths don't match between host and container

**Solutions**:

1. **Mount Docker socket** from host into Jenkins container:
   ```bash
   -v /var/run/docker.sock:/var/run/docker.sock
   ```

2. **Let Jenkins handle workspace mounting**: The Jenkinsfile sets working directory but lets Jenkins mount the workspace automatically:
   ```groovy
   docker.image('cirrusci/flutter:stable').inside("-u root:root -w ${env.WORKSPACE}")
   ```
   Note: No explicit `-v` mount needed - Jenkins handles this automatically

3. **Verify Docker socket is accessible**:
   ```bash
   # Inside Jenkins container
   docker ps
   # Should work without errors
   ```

4. **Check Jenkins logs** for workspace path mismatches:
   - Look for messages about paths not being found
   - Ensure workspace path is consistent between Jenkins and Docker container

### Error: "Required context class hudson.FilePath is missing"

**Problem**: Workspace cleanup error in post section (common on first run)

**Solution**: This has been fixed in the Jenkinsfile. If you see this:
- Pull the latest Jenkinsfile from the repository
- The `post` section now uses `cleanup` instead of `always` with proper error handling
- This error won't affect actual builds with parameters

### Error: "Parameters not loading" or "No Build with Parameters button"

**Problem**: Jenkins hasn't scanned the Jenkinsfile yet

**Solution**:
1. After creating the job, wait 10-20 seconds for automatic scan
2. Refresh the page - parameters should appear
3. If not, run one build (it will fail) - this forces parameter discovery
4. Refresh again - "Build with Parameters" will now be available

### Error: "No node with label 'docker'"

**Problem**: No Jenkins node has the "docker" label

**Solution**: Go back to Step 2 and label a node

### Error: "Permission denied" when accessing Docker

**Problem**: Jenkins user not in docker group

**Solution**:
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Error: "GitHub authentication failed"

**Problem**: Credentials not configured correctly

**Solutions**:
- Verify credential ID matches exactly: `github-credentials`
- Check token has `repo` scope
- Test token manually:
  ```bash
  curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user
  ```

### Error: "Could not parse version from pubspec.yaml"

**Problem**: Version format in pubspec.yaml is incorrect

**Solution**: Ensure format is exactly: `version: 1.0.0+1`

### Pipeline Hangs at Docker Stage

**Problem**: Docker image pull is slow or failing

**Solution**:
- Pre-pull image on Jenkins node:
  ```bash
  docker pull cirrusci/flutter:stable
  ```
- Check Docker Hub is accessible
- Check disk space: `df -h`

### Error: "curl: GitHub API rate limit"

**Problem**: Too many API requests

**Solution**: 
- Wait 1 hour for rate limit reset
- Use authenticated requests (check token is valid)
- Check current rate limit:
  ```bash
  curl https://api.github.com/rate_limit
  ```

## Next Steps

Once pipeline is working:

1. **Test releases**: Try patch, minor, and major release types
2. **Set up notifications**: Add Slack/email notifications
3. **Schedule builds**: Add cron triggers if needed
4. **Add signing**: Configure keystore for signed APKs
5. **Play Store**: Integrate with Play Store publishing

## Security Best Practices

- ✅ Never commit tokens to git
- ✅ Use Jenkins credentials store
- ✅ Give tokens minimal required permissions
- ✅ Rotate tokens periodically
- ✅ Use separate tokens for dev/prod
- ✅ Enable 2FA on GitHub account
- ✅ Review Jenkins audit logs regularly

## Support

For issues with:
- **Pipeline code**: Check [ci-cd-pipeline.md](.github/copilot-instructions/ci-cd-pipeline.md)
- **Version management**: Check [version-management.md](.github/copilot-instructions/version-management.md)
- **Flutter build**: Check Flutter docs or console output
- **Jenkins setup**: Check Jenkins documentation

## Quick Reference

### Run Release Build
```
Jenkins → machine-maintenance-android-release → Build with Parameters → Select release type → Build
```

### Update GitHub Token
```
Jenkins → Manage Jenkins → Manage Credentials → (global) → github-credentials → Update
```

### View Build Artifacts
```
Build page → Artifacts → Download APK
```

### Check GitHub Release
```
https://github.com/your-username/machine-maintenance-android/releases
```

---

**Setup Date**: 2026-02-05  
**Jenkins Required Version**: 2.x or higher  
**Docker Required**: Yes  
**GitHub Token Required**: Yes
