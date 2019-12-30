# devsecops-pipeline-workshop
Code for Gene Gotimer's DevSecOps Pipeline Workshop.


## Prerequisites
To participate in the workshop, you will need the following:

* A Chef Manage account
  * free for up to 5 nodes, which is enough for us

* An AWS account

* A GitHub account

* On your laptop
  * Java 11
  * Maven 3.1.1 or newer
  * Chef Workstation (or ChefDK) installed and configured

  
## Before the workshop

Make sure you are ready to fully participate and get the most out of the workshop by doing the following before the workshop begins.

The target application that we will be building is at https://github.com/Coveros/gimme-feedback. **Fork** the repository to your GitHub account since you'll be making changes to it when exercising your DevSecOps pipeline. Then **clone** your repository to your laptop and build the `master` branch using Maven, `mvn verify`.

Ensure the `knife` utility in Chef is configured correctly by getting a (probably empty) list of nodes on your Chef account, `knife node list`. If that fails, the Learn Chef Rally site can walk you through setting up Chef and `knife`. We'll be working with Ubuntu systems in AWS, so try https://learn.chef.io/modules/learn-the-basics/ubuntu/aws#/.

Ensure your AWS credentials are available to `knife` by spinning up a 


