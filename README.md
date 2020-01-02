# devsecops-pipeline-workshop
Instructions and code for Gene Gotimer's DevSecOps Pipeline Workshop.


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
	