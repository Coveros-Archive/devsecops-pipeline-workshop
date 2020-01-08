# devsecops-pipeline-workshop

Instructions and code for Gene Gotimer's Building a DevSecOps Pipeline workshop.

## Lesson 3: Build locally

### 3.1: Build using Maven

On your workstation, go into the `~/jpetstore-6/` directory. Build, test, package, and verify the code using Maven with `mvn verify -DskipITs`.

```shell
cd ~/jpetstore-6/
mvn verify -DskipITs
```

You will see a message that says `BUILD SUCCESS` towards the end of the output. This will take a while the first time, since all the Maven plugins and dependencies have to be downloaded.

### 3.2: Deploy the packaged web application (.war)

In the `pom.xml`, change the `distributionManagement` section to point to our Nexus Repo. Merge the code from the `origin/31-deploy-to-nexus` to the `master` branch, and then edit the instances of `nexusip` to be the private IP address for Nexus from the previous lesson.

```shell
git merge origin/31-deploy-to-nexus
pico pom.xml
```

When it is complete, that section should look similar to (with your IP address):

```xml
  <distributionManagement>
    <snapshotRepository>
      <id>nexus-snapshots</id>
      <url>http://172.111.222.333/repository/maven-snapshots/</url>
    </snapshotRepository>
    <repository>
      <id>nexus-releases</id>
      <url>http://172.111.222.333/repository/maven-releases/</url>
    </repository>
  </distributionManagement>
```

Rebuild, but this time `deploy` the packaged artifact using `mvn deploy -DskipITs`.

```shell
mvn deploy -DskipITs
```

You'll see that towards the end, a message shows that the .war file was uploaded to `nexus-snapshots`.

```plaintext
Uploaded to nexus-snapshots: http://172.111.222.333/repository/maven-snapshots/org/mybatis/jpetstore/6.0.3-SNAPSHOT/jpetstore-6.0.3-20200108.014910-1.war (10 MB at 16 MB/s)
```

Add and commit the code to Git as our new baseline.

```shell
git add pom.xml
git commit -m 'Added Nexus as a distribution target'
```

### 3.2: Use OWASP Dependency Check to search for components with known vulnerabilities

Add the OWASP Dependency Check plugin to the `pom.xml` file. As part of the `verify` phase, Maven will download updates from the National Vulnerability Database (NVD) and build an index out of the data. Then it will use that index to match against the dependencies in our project, looking for components with known vulnerabilities.

Switch to the `32-add-owasp-dependency-check` branch, rebase to keep the earlier distribution management changes, and rebuild.

```shell
git checkout 32-add-owasp-dependency-check
git rebase master
mvn deploy -DskipITs
```

This may take a few minutes to build the NVD database initially. As long as the updates are downloaded at least every 7 days, only the changes will need to be downloaded an indexed.

At the end, you will notice that there is a vulnerability found in `log4j-1.2.17.jar`. It is a valid finding and should be fixed, but since we are dealing with legacy code (i.e., not ours) at the moment, let's note the finding and plan to fix it as soon as we can.

In the future, we could uncomment the line in the `pom.xml` that fails builds for serious findings, rather than allowing the build to continue. The pertinent lines are:

```xml
            <!-- <failBuildOnCVSS>${dependency.check.maven.failBuildOnCVSS}</failBuildOnCVSS> -->
```

Uncomment to begin failing builds, and

```xml
    <dependency.check.maven.failBuildOnCVSS>8</dependency.check.maven.failBuildOnCVSS>
```

Set the CVSS score to the desired threshold. The default is `11` (out of `10`), so it never fails. The `log4j-1.2.17` finding has a score of `9.8` which is considered critical.

We will see some reporting on these vulnerability findings later.

Add and commit the code to Git, merging to `master` as our new baseline.

```shell
git add pom.xml
git commit -m 'Added OWASP Dependency Check'
git checkout master
git merge 32-add-owasp-dependency-check
```

## Done
