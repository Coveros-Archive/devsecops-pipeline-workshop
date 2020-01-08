# devsecops-pipeline-workshop

Instructions and code for Gene Gotimer's Building a DevSecOps Pipeline workshop.

## Lesson 5: Static Code Analysis

### 5.1: Deploy SonarQube

On your workstation, go into the `devsecops-pipeline-workshop/chef-repo/` directory. Install and upload the `sonarqube-server` policy, which installs Java 11, the SonarQube server, and an nginx proxy in front.

```shell
cd ~/devsecops-pipeline-workshop/chef-repo/
chef install policyfiles/sonarqube-server.rb
chef push codemash policyfiles/sonarqube-server.rb
```

Use the `knife` utility again to launch an AWS instance for Jenkins. The following information is different this time:

* Node name: what should Chef call this box.
  * `sonarqube`
* AWS name: what should AWS tag this instance as.
  * `sonarqube` to be consistent
* Policy name: what policy should we assign to the system. Has to be uploaded already.
  * `sonarqube-server`

The rest of the `knife ec2 server create` is the same as before, and will look similar to:

```shell
knife ec2 server create \
  --node-name sonarqube --aws-tag Name=sonarqube \
  --policy-group codemash --policy-name sonarqube-server \
  --region us-east-2 --availability-zone us-east-2a \
  --flavor m5.large --image ami-0d5d9d301c853a04a --security-group-id sg-0332cccd54252e129 \
  --ssh-key gotimer-workshop --ssh-identity-file ~/gotimer-workshop.pem --connection-user ubuntu \
  --sudo --chef-license accept-silent --yes
```

Note again the public and private DNS names and IP addresses of the system. Visit SonarQube in the browser using the public DNS name or IP address. The default username is `admin` and the default password is `admin`. Leave them default for now.

SonarQube can take a minute or two to start after the instance has been launched, so be a little patient.

### 5.2: Configure the SonarQube webhook

The SonarQube analysis can take some time in bigger projects and is performed asynchronously. So we need to set up a webhook so that SonarQube can let Jenkins know when an analysis is done and what the results are.

Visit SonarQube in your browser and log in via the **Log in** link in the upper-right corner (`admin`/`admin`). Select the **Administration** tab across the top menu, then open the **onfiguration** drop-down from the Administration menu and choose **Webhooks**. Click on the **Create** button towards the top right.

The **Name** can be anything descriptive, such as `jenkins`. The **URL** should be the Jenkins *private* DNS name or IP address, `http://`*private IP*`/sonarqube-webhook/` (include the trailing slash), similar to:

```plaintext
http://172.333.222.111/sonarqube-webhook/
```

Leave **Secret** blank. Then click on the **Create** button at the bottom of the dialog.

### 5.3: Configure the SonarQube server globally in Jenkins

Rather than each job having to pass in the SonarQube server location, we can add the SonarQube URL globally in Jenkins and refer to it in jobs with a symbolic name.

From the Jenkins home screen, choose **Manage Jenkins** from the left-side menu. Then choose **Configure System**. Scroll down to the section on **SonarQube servers** and click on the **Add SonarQube** button.

We will refer to the **Name** in our `Jenkinsfile`, so set it to `sonarqube-1`. The **Server URL** should use the *public* DNS name or IP address of your SonarQube server, `http://`*public IP*`, similar to:

```plaintext
http://222.333.444.555
```

Leave the **Server authentication token** set to `- none -` and click on the blue **Save** button at the bottom of the window.

### 5.4: Change the job configuration in a branch

So that we don't disrupt other branches and other builds that are currently working correctly, we will take advantage of the fact that we can make our `Jenkinsfile` changes on a branch so that we can test and review them before inflicting the changes on others.

In the `jpetstore-6` directory, make sure you ar on the `master` branch and create a new branch to work on, for example `54-add-sonarqube-analysis`. Then open your text editor to undate `Jenkinsfile`.

```shell
cd ~/jpetstore-6/
git checkout master
git checkout -b 54-add-sonarqube-analysis
pico Jenkinsfile
```

After the `Deploy` stage section, add a new stage for the static analysis on SonarQube:

```xml
        stage ('Static Analysis') {
            steps {
                withSonarQubeEnv('sonarqube-1') {
                    sh 'mvn sonar:sonar'
                }
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
```

Save the file, add the change to Git, and then commit and push to GitHub. When asked for credentials, supply your GitHub username and the *personal access token* you created earlier.

```shell
git add Jenkinsfile
git commit -m 'Added SonarQube analysis to the job'
git push --set-upstream origin 54-add-sonarqube-analysis
```

GitHub will let Jenkins know about the code change immediately and start a job for the new branch. When the build is finished and the static code analysis is complete, SonarQube will let Jenkins know and will display the results on the job page. Go to the `jpetstore` job in Jenkins and click on the `54-add-sonarqube-analysis` branch. You'll see a **SonarQube Quality Gate** section with the results of the analysis. You can click on the green **OK** result to jump directly to the metrics and findings in SonarQube.

### 5.5: Create a pull request

When you pushed the `Jenkinsfile` changes, GitHub responded with a URL to create a pull request, similar to:

```plaintext
remote: Resolving deltas: 100% (9/9), completed with 2 local objects.
remote:
remote: Create a pull request for '54-add-sonarqube-analysis' on GitHub by visiting:
remote:      https://github.com/gotimer/jpetstore-6/pull/new/54-add-sonarqube-analysis
remote:
To https://github.com/gotimer/jpetstore-6.git
 * [new branch]      54-add-sonarqube-analysis -> 54-add-sonarqube-analysis
Branch '54-add-sonarqube-analysis' set up to track remote branch '54-add-sonarqube-analysis' from 'origin'.
```

> **Important:** Visit that URL to create the pull request. Since this is a forked repository, the pull request will default to merging back upstream. Since we want to make this pull request in your repository, change the *base repository** to your repo (e.g., `gotimer/jpetstore-6`). Once we do so, the screen will refresh and the **base repository** and **head repository** drop-downs will disappear.

Verify that the changes are as expected and click on the green **Create pull request** button.

Immediately you will see that the pull request has a note that **All checks have passed** since Jenkins previously built the branch. If you open up the **Show all checks** link, you will get further details and a link directly to the Jenkins build for that branch, labeled **Details**.

### 5.6: Merge the pull request

This is the opportunity for peers to review the changes and make meaningful suggestions, using the build and analysis results in context. If something ha failed, they can see that right in the pull request.

Once you are satisfied that everything is as it should be and there are no errors, click on the green **Merge pull request** button and then the green **Confirm merge** button. Again, GitHub will let Jenkins know of the change to the `master` branch and will kick off a new build. Click on the **Delete branch** button, just to see how Jenkins represents it.

Visit Jenkins and watch the build complete.

If you want to explore some more, I suggest changing the *TIMEOUT* value in the `Jenkinsfile` to trigger changes (and builds and analyses).

## Done
