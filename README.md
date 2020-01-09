# devsecops-pipeline-workshop

Instructions and code for Gene Gotimer's Building a DevSecOps Pipeline workshop.

[Presentation slides](https://drive.google.com/file/d/1-50Yp1V7c0lksP5MHfJ4cPvN90J0AxnF/view?usp=sharing)

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
    * PuTTY is a popular option for Windows, <https://www.chiark.greenend.org.uk/~sgtatham/putty/>.
    * Git Bash has an SSH client included, <https://gitforwindows.org/>.
    * If you use a Mac or Linux, you already have `ssh` installed.

* A web browser

We will be building a pipeline in AWS that is Internet-accessible. I know it sounds like overkill to point this out, but your laptop needs to be able to access IP addresses in the public AWS space. If you use a VPN or if your network-access is restricted, please talk to your IT department to make sure you will be able to actively participate. Or bring a personal machine.

## Lesson 0: Prepare your environment

### 0.1: Launch a workstation

Log into your AWS account and select `us-east-2` as the region. Go to the EC2 Service, AMIs, and select Public AMIs from the drop-down on the search bar. In the search bar, choose `AMI ID` and then enter `ami-0d3498a401d9919a4`. You should see one result.

That AMI is a stock "Ubuntu Server 18.04 LTS (HVM), SSD Volume Type" server (from `ami-0d5d9d301c853a04a`) that I've run the following on, so you don't have to:

```shell
sudo apt-get update
sudo apt-get install openjdk-11-jdk-headless maven awscli unzip
wget "https://packages.chef.io/files/stable/chef-workstation/0.13.35/ubuntu/18.04/chef-workstation_0.13.35-1_amd64.deb"
sudo apt-get install ./chef-workstation_0.13.35-1_amd64.deb
```

Select the checkbox for that AMI and click on the **Launch** button. I recommend selecting a `t3a.medium` instance (so you get 2 CPUs and 4 GiB memory). Click through the **Next** buttons until you get to **Step 6: Configure Security Group**.

We need to create a security group that allows `SSH`, `HTTP`, and `HTTPS` inbound traffic, so add rules for each of those three.

Select **Review and Launch** and then **Launch**. Choose your key pair (or create a new one, so we can delete it later) and then **Launch Instance**. Make note of the key pair name for Lesson 2.

While the EC2 instance is spinning up, configure your SSH client to use your private key for AWS, if needed. (For PuTTY, see <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html>). You'll need the private key again in Lesson 2.

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

Unzip the file with `unzip chef-starter.zip`. We just need the configuration from it, which is the `chef-repo/.chef` directory. Move the configuration directory into the workshop repo with `mv chef-repo/.chef devsecops-pipeline-workshop/chef-repo/` and then remove the other unzipped files to avoid confusion later with `rm -rf chef-repo`.

```shell
ubuntu@ip-172-31-34-22:~$ unzip chef-starter.zip
Archive:  chef-starter.zip
  inflating: chef-repo/README.md
...
  inflating: chef-repo/.chef/ggotimer.pem  
ubuntu@ip-172-31-34-22:~$ mv chef-repo/.chef devsecops-pipeline-workshop/chef-repo/
ubuntu@ip-172-31-34-22:~$ ls -a devsecops-pipeline-workshop/chef-repo/
.  ..  .chef  .gitignore  README.md  cookbooks  policyfiles
ubuntu@ip-172-31-34-22:~$ rm -rf chef-repo
```

Test our configuration by entering the `devsecops-pipeline-workshop/chef-repo/` directory and running `knife client list`.

```shell
ubuntu@ip-172-31-34-22:~$ cd ~/devsecops-pipeline-workshop/chef-repo/
ubuntu@ip-172-31-34-22:~/devsecops-pipeline-workshop/chef-repo$ knife client list
coveros-validator
```

No errors is success.

### 0.4: Configure Git

Add your name and email address to the global Git configuration.

```shell
git config --global --edit
```

When it is done, the Git global configuration file, `/home/ubuntu/.gitconfig`, should look similar to:

```ini
# This is Git's per-user configuration file.
[user]
        name = Gene Gotimer
        email = gene.gotimer@coveros.com
```

### 0.5: Fork and clone the application we are "developing"

We'll be using a version of MyBatis JPetStore 6 as our application to develop. I have added the branches we'll need, but you need to *fork* the repository to your GitHub account since you'll be making changes to it when exercising your DevSecOps pipeline.

Log into your GitHUb account and then visit <https://github.com/Coveros/jpetstore-6>. Click on the **Fork** button in the upper-right corner.

Once the fork is complete, copy the URL from the **Clone or download** button and clone *your* fork to your home directory on the workstation.

```shell
ubuntu@ip-172-31-34-22:~/devsecops-pipeline-workshop/chef-repo$ cd
ubuntu@ip-172-31-34-22:~$ git clone https://github.com/ggotimer/jpetstore-6.git
Cloning into 'jpetstore-6'...
...
Resolving deltas: 100% (3491/3491), done.
```

### 0.6: Generate a GitHub personal access token

We'll be interacting with GitHub and we don't want to be spreading your GitHub password around. Plus, you *should* have two-factor authentication turned on, which won't work with most automated calls. So we'll create a *personal access token* to use instead of a password.

Log into your GitHub account. Click on your icon in the upper-right corner and choose **Settings** from the drop-down menu. In the left-hand menu, choose **Developer settings**. In the new left-hand menu, choose **Personal access tokens**, and then click on the **Generate new token** button at the top of the page.

Give a name to your token such as `codemash-2020` so you can find it later (to delete it). And then grant it the **repo** scope, which automatically includes the four scopes underneath it (**repo:status**, **repo_deployment**, **public_repo**, **repo:invite**). Then scroll to the bottom and click the green **Generate token** button.

Copy the generated token and record it somewhere. You can never see it again if you leave this page, but you can just generate a new one.

You will receive an email from GitHub warning that someone (in this case you) created a new person access token.

## Done
