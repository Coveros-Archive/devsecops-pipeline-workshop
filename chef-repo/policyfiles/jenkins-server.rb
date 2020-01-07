# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

# A name that describes what the system you're building with Chef does.
name 'jenkins-server'

include_policy "fast-client", path: "./fast-client.lock.json"

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'java::default', 'jenkins::master', 'maven::default', 'maven-settings::default', 'jenkins-plugins::default'

# Policyfile defined attributes
default['java']['jdk_version'] = '11'
default['jenkins']['master']['port'] = 80
default['jenkins']['master']['user'] = 'root'
default['jenkins']['executor']['protocol'] = nil
default['maven']['version'] = '3.6.3'
default['maven']['checksum'] = '26ad91d751b3a9a53087aefa743f4e16a17741d3915b219cf74112bf87a438c5'

# Specify a custom source for a single cookbook:
cookbook 'jenkins-plugins', path: '../cookbooks/jenkins-plugins'
cookbook 'maven-settings', path: '../cookbooks/maven-settings'
