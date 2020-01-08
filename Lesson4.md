# devsecops-pipeline-workshop

Instructions and code for Gene Gotimer's Building a DevSecOps Pipeline workshop.

## Lesson 4: Continuous Integration

### 4.1: Deploy Jenkins

On your workstation, go into the `devsecops-pipeline-workshop/chef-repo/` directory. Install and upload the `jenkins-server` policy, which installs Java 11, Jenkins server, Jenkins plugins, and Maven, and configures Maven to use Nexus.

```shell
cd ~/devsecops-pipeline-workshop/chef-repo/
chef install policyfiles/jenkins-server.rb
chef push codemash policyfiles/jenkins-server.rb
```

Use the `knife` utility again to launch an AWS instance for Jenkins. The following information is different this time:

* Node name: what should Chef call this box.
  * `jenkins`
* AWS name: what should AWS tag this instance as.
  * `jenkins` to be consistent
* Policy name: what policy should we assign to the system. Has to be uploaded already.
  * `jenkins-server`

The rest of the `knife ec2 server create` is the same as before, and will look similar to:

```shell
knife ec2 server create \
  --node-name jenkins --aws-tag Name=jenkins \
  --policy-group codemash --policy-name jenkins-server \
  --region us-east-2 --availability-zone us-east-2a \
  --flavor m5.large --image ami-0d5d9d301c853a04a --security-group-id sg-0332cccd54252e129 \
  --ssh-key gotimer-workshop --ssh-identity-file ~/gotimer-workshop.pem --connection-user ubuntu \
  --sudo --chef-license accept-silent --yes
```

> **Important**: An `m5.large` will be plenty for us today, but Jenkins will quickly become the centerpiece of your mission-critical build pipeline. Do not skimp in your organization. If you hear so much as a developer *sighing heavily* while waiting for a job to finish on Jenkins, consider upgrading the instance. Computer time is *way* cheaper than developer time, in so many ways.

As before, this will take a few minutes. Also as before, note the public and private DNS names and IP addresses of the system. Visit Jenkins in the browser using the public DNS name or IP address. By default, there is no authentication required.

### 4.2: Define the Jenkins job using pipeline-as-code

Create a declarative `Jenkinsfile` that defines the Jenkins build job so that we minimize the configuration on Jenkins. Also, now job changes can be tested and tracked in source control.

Switch to the `42-add-jenkinsfile` branch, rebase to keep the earlier distribution management changes, and merge back to `master`. We will delete the branch after it is merged. Then push to GitHub. When asked for credentials, supply your GitHub username and the *personal access token* you created earlier.

```shell
cd ~/jpetstore-6/
git checkout 42-add-jenkinsfile
git rebase master
git checkout master
git merge 42-add-jenkinsfile
git branch -D 42-add-jenkinsfile
git push origin
```

### 4.3: Configure Jenkins to find the GitHub repository

Visit Jenkins and click on the **New Item** link in the left-hand menu.

Enter a name for the jobs to use, such as `jpetstore`. Select the **Multibranch pipeline** job type and then click the **OK** button.

Under **Branch Sources**, choose **Add source** and then pick **GitHub** from the drop-down menu. Enter the **Repository HTTPS URL** to your GitHub repository, such as `https://github.com/gotimer/jpetstore-6.git`.

Since it is our first repository on Jenkins from GitHub, we need to add then select our GitHub credentials. Above the URL on the **Credentials** line, click **Add**. Chose the job name from the drop-down menu (e.g., `jpetstore`).

Enter your GitHub **Username** and your *personal access token* in the **Password** field, then click the **Add** button. Then select the credentials in the drop-down to the left, where it says `- none -`. These credentials will let Jenkins inform GitHub of the results of any builds.

As soon as you click **Save**, Jenkins will immediately scan your repository and build any branches that have a `Jenkinsfile` in them. That is why we deleted the `42-add-jenkinsfile` branch: `master` has the correct, rebased version of the code and `42-add-jenkinsfile` does not.

As when we did it locally, this  build may take a few minutes to build the OWASP Dependency Check NVD database for the first time.

Look at the job build results in Jenkins. Spend a few moments exploring the interface. In particular, the **Open Blue Ocean** option can show some interesting depictions of pipelines.

### 4.4: Configure the GitHub webhook

While you could build on-demand after making code changes in the repository, we want Jenkins to notice the changes automatically. We can configure GitHub to tell Jenkins any time a change has been made to the repository.

On your repository page in GitHub, choose the **Settings** tab across the top, and then the **Webhooks** item from the left-hand menu. Then click on the **Add webhook** button towards the top of the page.

The **Payload URL** must use the Jenkins *public* DNS name or IP address, and will be `http://`*public IP*`/github-webhook/` (include the trailing slash), similar to:

```plaintext
http://222.333.444.555/github-webhook/
```

For **Content type** choose `application/json` and leave **Secret** blank. Then select the **Send me everything** radio button and click on the green **Add webhook** button.

We will see the webhook at work in the next lesson.

## Done
