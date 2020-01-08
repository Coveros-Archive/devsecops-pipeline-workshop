# devsecops-pipeline-workshop

Instructions and code for Gene Gotimer's Building a DevSecOps Pipeline workshop.

## Lesson 2: Deploy an artifact repository

### 2.1: Deploy Sonatype Nexus Repository Manager

In the AWS interface, look up the workstation information in the EC2 console. Note the *Availability zone*. Find and click on the **Security group**. You'll need the *Security Group ID* in the next step.

Use your SSH client to upload your private key (e.g., `gotimer-workshop.pem`) that you created in Lesson 0 to your home directory on the workstation.

On your workstation, go into the `devsecops-pipeline-workshop/chef-repo/` directory. Install and upload the `fast-client` and `nexus-repo` policies.

* `fast-client` sets Chef Client to "phone home" to the Chef Server about every 5 minutes. I often use this on development server because I am impatient.
* `nexus-repo` installs Nexus Repository Manager running on Java 8 with an nginx proxy in front of it.

We will create the policies in a *policy group* that we will call `codemash`. We could have called it `test`, `staging`, `wilburs`, `foo`, etc. The same *policy* can be different in different *policy groups*, so there could be one version of the policy in the `development` policy group and an older (or just different, or even the same) version in the `production` group.

```shell
cd ~/devsecops-pipeline-workshop/chef-repo/
chef install policyfiles/fast-client.rb
chef push codemash policyfiles/fast-client.rb
chef install policyfiles/nexus-repo.rb
chef push codemash policyfiles/nexus-repo.rb
```

Accept the Chef licenses, if asked.

Use the `knife` utility to launch an AWS instance, install the Chef client and connect back to the Chef Server (also known as bootstrapping Chef), assign the `nexus-repo` policy which will tell Chef that this instance is a Nexus Repository Manager and should be configured accordingly.

You will need the following information:

* Node name: what should Chef call this box.
  * `nexus`
* AWS name: what should AWS tag this instance as.
  * `nexus` to be consistent
* Policy group: what environment the policy has been uploaded to, could be `development`, `staging`, etc.
  * `codemash`
* Policy name: what policy should we assign to the system. Has to be uploaded already.
  * `nexus-repo`
* Region: which AWS region to use.
  * Needs to be `us-east-2` since that is where the workstation and AMI we are using is.
* Availability zone: which AWS availability zone to use. **Must** be consistent with our region. **Could** be consistent with our other systems for performance.
  * *Availability zone* that matches our workstation (noted earlier).
* Instance type: size of configuration of the virtual hardware to launch in AWS.
  * Sonatype Nexus Repository Manager wants 2 CPUs and 8 GiB RAM, so we'll use `m5.large`.
* AMI ID: what base image to use. **Must** be consistent with our region. AMD IDs are region-specific.
  * `ami-0d5d9d301c853a04a`, which is "Ubuntu Server 18.04 LTS (HVM), SSD Volume Type" in our region from the AWS Marketplace.
* Security group ID: Firewall settings for the instance. These IDs are unique to each account and each region. 
  * *Security Group ID* that we created for our workstation (noted earlier) that allows `SSH`, `HTTP`, and `HTTPS` inbound traffic.
* SSH Key name: name of the key pair that Chef will use to log in on the instance it launches.
  * *Key pair name* that we created in Lesson 0.
* SSH private key file: path to the key pair private key that Chef will use to log in on the instance it launches.
  * *Path to the private key*  (uploaded earlier).
* Connection user: username that Chef will log in as on the instance it launches.
  * `ubuntu` from the AWS Marketplace page for the AMI we are using.

```shell
knife ec2 server create \
  --node-name nexus --aws-tag Name=nexus \
  --policy-group codemash --policy-name nexus-repo \
  --region us-east-2 --availability-zone us-east-2a \
  --flavor m5.large --image ami-0d5d9d301c853a04a --security-group-id sg-0332cccd54252e129 \
  --ssh-key gotimer-workshop --ssh-identity-file ~/gotimer-workshop.pem --connection-user ubuntu \
  --sudo --chef-license accept-silent --yes
```

This will take a few minutes as:

* The instance is launched
* Chef connects using SSH
* Chef Client is installed and configured
* The `fast-client` policy is implemented
  * Chef is configured to connect about every 5 minutes (default is 30 minutes)
* The `nexus-repo` policy is implemented
  * Java is installed
  * Nexus is installed
  * nginx is installed to proxy Nexus via port `80`

Note the public and private DNS names and IP addresses of the system. Visit it in the browser using the public DNS name or IP address. The default username is `admin` and the default password is `admin123`. Leave them default for now.

### 2.2: Visit the Chef Server

Log into the Chef Server at https://manage.chef.io/. You should see the `nexus` node (what Chef calls the system) we just created. Click around for a while and notice all the information Chef has collected about the new node. The **Attributes** tab is particularly interesting.

### 2.3: Configure Maven to use Nexus

Create a Maven configuration settings file and edit it to point to the Nexus instance you just launched. Change *nexusip* to be the private IP address. We could use the public value, but private is safer since the workstation and Nexus are colocated.

```shell
cd
mkdir ~/.m2
cp devsecops-pipeline-workshop/resources/settings.xml .m2/
pico .m2/settings.xml
```

Check the configuration by using Maven to do a `mvn clean` on the JPetStore directory.

```shell
cd ~/jpetstore-6/
mvn clean
```

No errors is success. You should see the Maven plugins being downloaded from your Nexus Repo Manager.

If you visit Nexus again and browse the `maven-central` repository you will see many libraries have been proxied. The next time we need them, they will not have to be downloaded from the Internet again, only from our Nexus Repository.

## Done
