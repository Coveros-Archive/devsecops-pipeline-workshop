# devsecops-pipeline-workshop

Instructions and code for Gene Gotimer's Building a DevSecOps Pipeline workshop.

## Lesson 6: Automated Deploys

### 6.1: Deploy the last successful build of JPetStore

Deploying our application code automatically will open up many opportunities for us to do further testing. We are going to configure Chef to deploy the last successful build of the application on `master` from Jenkins.

On your workstation, go into the `devsecops-pipeline-workshop/chef-repo/` directory. This time, we have to edit the `jpetstore` policy to point to our Jenkins server.

```shell
cd ~/devsecops-pipeline-workshop/chef-repo/
pico policyfiles/jpetstore.rb
```

Find the `default['deploy_war']['url']` attribute in the Policyfile and change `jenkinsip` to the Jenkins *private* DNS name or IP address:

```diff
- default['deploy_war']['url'] = 'http://jenkinsip/job/jpetstore/job/master/lastSuccessfulBuild/artifact/target/jpetstore.war'
+ default['deploy_war']['url'] = 'http://172.333.222.111/job/jpetstore/job/master/lastSuccessfulBuild/artifact/target/jpetstore.war'
```

Save the file, then install and push the policy.

```shell
chef install policyfiles/jpetstore.rb
chef push codemash policyfiles/jpetstore.rb
```

The `jpetstore` policy will install Java 11 and Tomcat, deploy the war file as the Tomcat root application, and then add an nginx proxy in front.

Use the `knife` utility again to launch an AWS instance for Jenkins. The following information is different this time:

* Node name: what should Chef call this box.
  * `jpetstore`
* AWS name: what should AWS tag this instance as.
  * `jpetstore` to be consistent
* Policy name: what policy should we assign to the system. Has to be uploaded already.
  * `jpetstore`
* Instance type: size of configuration of the virtual hardware to launch in AWS.
  * We don't need much for this instance, so we'll use a `t3a.small`.

The rest of the `knife ec2 server create` is the same as before, and will look similar to:

```shell
knife ec2 server create \
  --node-name jpetstore --aws-tag Name=jpetstore \
  --policy-group codemash --policy-name jpetstore \
  --region us-east-2 --availability-zone us-east-2a \
  --flavor t3a.small --image ami-0d5d9d301c853a04a --security-group-id sg-0332cccd54252e129 \
  --ssh-key gotimer-workshop --ssh-identity-file ~/gotimer-workshop.pem --connection-user ubuntu \
  --sudo --chef-license accept-silent --yes
```

Visit JPetStore in the browser using the public DNS name or IP address.

We now have a latest-and-greatest deploy of JPetStore from `master` automatically available whenever a change is made. Whenever Chef Client checks in (we have it set for every 5 minutes, but it is 30 minutes by default), if there is a new build it will be deployed automatically.

This might be useful for a development team, but is probably too volatile for test team or for UAT. We won't do it here, but we could use the same `jpetstore` policy to point to a specific release of the `jpetstore.war` file in Nexus. We could create another environment, say `codemash-test`, and push that version of the policy there. It would need to be updated every time we wanted to update, but in that case it is probably what we want- explicit control of the version being deployed and when.

## Done
