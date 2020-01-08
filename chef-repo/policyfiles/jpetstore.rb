# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

# A name that describes what the system you're building with Chef does.
name 'jpetstore'

include_policy "fast-client", path: "./fast-client.lock.json"

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'java::default', 'deploy-war::default', 'nginx-proxy::default'

# Policyfile defined attributes
default['java']['jdk_version'] = '11'
default['deploy_war']['webapp'] = 'jpetstore'
default['deploy_war']['url'] = 'http://jenkinsip/job/jpetstore/job/master/lastSuccessfulBuild/artifact/target/jpetstore.war'
default['nginx_proxy']['port'] = '8080'

# Specify a custom source for a single cookbook:
cookbook 'deploy-war', path: '../cookbooks/deploy-war'
cookbook 'nginx-proxy', path: '../cookbooks/nginx-proxy'
