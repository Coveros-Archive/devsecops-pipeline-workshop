# devsecops-pipeline-workshop

Instructions and code for Gene Gotimer's Building a DevSecOps Pipeline workshop.

## Prerequisites

To participate in the workshop, you will need the following:

* An AWS account
  * We'll be working on a workstation in AWS for this workshop.
  * You'll also need to be able to create EC2 instances using the AWS API, so you'll need to have (or be able to create) an AWS Access Key ID and AWS Secret Access Key.

* A Chef Manage account
  * Chef Manage is free for up to 5 nodes, which is enough for this workshop.
  * You'll need the `chef-starter.zip` with includes the private key for your Chef Manage account.

* A GitHub account
  * You'll be forking a GitHub repository and making changes to it in your own account in order to trigger actions in the pipeline.

* An SSH client
  * We will be using SSH to access the Ubuntu workstation we will be working from in AWS.
    * PuTTY is a popular option for Windows, https://www.chiark.greenend.org.uk/~sgtatham/putty/.
    * Git Bash has an SSH client included, https://gitforwindows.org/.
    * If you use a Mac or Linux, you already have `ssh` installed.

* A web browser

We will be building a pipeline in AWS that is Internet-accessible. I know it sounds like overkill to point this out, but your laptop needs to be able to access IP addresses in the public AWS space. If you use a VPN or if your network-access is restricted, please talk to your IT department to make sure you will be able to actively participate. Or bring a personal machine.

## Lesson 0: Prepare your environment

### 0.1: Launch a workstation

Log into your AWS account and go to the EC2 Service, AMIs, and select Public AMIs from the drop-down on the search bar. In the search bar, choose `AMI ID` and then enter `ami-0d3498a401d9919a4`. You should see one result.

That AMI is a stock "Ubuntu Server 18.04 LTS (HVM), SSD Volume Type" server (from `ami-0d5d9d301c853a04a`) that I've run the following on, so you don't have to:

```shell
sudo apt-get update
sudo apt-get install openjdk-11-jdk-headless maven awscli unzip
wget "https://packages.chef.io/files/stable/chef-workstation/0.13.35/ubuntu/18.04/chef-workstation_0.13.35-1_amd64.deb"
sudo apt-get install ./chef-workstation_0.13.35-1_amd64.deb
```

Select the checkbox for that AMI and click on the **Launch** button. I recommend selecting a `t3a.medium` instance (so you get 2 CPUs and 4 GiB memory). Click through the **Next** buttons until you get to **Step 6: Configure Security Group**.

We need to create a security group that allows `SSH`, `HTTP`, and `HTTPS`, so add rules for each of those three.

Select **Review and Launch** and then **Launch**. Choose your key pair (or create a new one) and then **Launch Instance**.

While the EC2 instance is spinning up, configure your SSH client to use your private key for AWS, if needed. (For PuTTY, see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html).

Once the system has launched, use the `IPv4 Public IP` or `Public DNS` to connect to the system with the username `ubuntu`.

### 0.2: Configure AWS credentials

Create a new set of AWS API access keys so we can delete them at the end of this workshop. Click on your AWS username in the top right, and choose **My Security Credentials**. Then click on the **Create access key** button. Leave that window open for now.

In your SSH session, type `aws configure` and fill in each of the four prompts, copying the newly created AWS Access Key ID and AWS Secret Access Key from the browser:

```shell
ubuntu@ip-172-31-34-22:~$ aws configure
AWS Access Key ID [None]: <your access key ID>
AWS Secret Access Key [None]: <your secret access key>
Default region name [None]: us-east-2
Default output format [None]: json
```

You can close the access key window.

### 0.3: Configure Chef on the workstation

Clone the workshop repository from GitHub to your workstation.

```shell
ubuntu@ip-172-31-34-22:~$ git clone https://github.com/Coveros/devsecops-pipeline-workshop.git
Cloning into 'devsecops-pipeline-workshop'...
...
Unpacking objects: 100% (11/11), done.
```

Log into your Chef Manage account, choose **Administration** at the top, then select **Starter Kit** in the left sidebar. Click on the **Download Starter Kit** button to download the `chef-starter.zip` file to your laptop, and then use your SSH client to upload `chef-starter.zip` to your workstation.

Unzip the file with `unzip chef-starter.zip`. We just need the configuration from it, which is the `chef-repo/.chef` directory. Move the configuration directory into the workshop repo with `mv chef-repo/.chef devsecops-pipeline-workshop/chef-repo/` and then remove the unzipped file to avoid confusion later with `rm -rf chef-repo`.

```shell
ubuntu@ip-172-31-34-22:~$ unzip chef-starter.zip
Archive:  chef-starter.zip
  inflating: chef-repo/README.md     
...
  inflating: chef-repo/.chef/ggotimer.pem  
ubuntu@ip-172-31-34-22:~$ mv chef-repo/.chef devsecops-pipeline-workshop/chef-repo/
ubuntu@ip-172-31-34-22:~$ ls -a devsecops-pipeline-workshop/chef-repo/
.  ..  .chef  .gitignore  README.md  cookbooks  policyfiles  roles
ubuntu@ip-172-31-34-22:~$ rm -rf chef-repo
```

Test our configuration by entering the `devsecops-pipeline-workshop/chef-repo/` (which is where we will be doing almost all our work) and run `knife client list`.

```shell
ubuntu@ip-172-31-34-22:~/devsecops-pipeline-workshop/chef-repo$ knife client list
coveros-validator
```

No errors is success.
