# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

# A name that describes what the system you're building with Chef does.
name 'nexus-repo'

include_policy "fast-client", path: "./fast-client.lock.json"

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'java::default', 'nexus3-server::default', 'nginx-proxy::default'

# Policyfile defined attributes
default['java']['jdk_version'] = '8'
default['nexus3']['version'] = '3.20.1-01'
default['nexus3']['url'] = 'https://download.sonatype.com/nexus/3/latest-unix.tar.gz'
default['nexus3']['checksum'] = 'fba9953e70e2d53262d2bd953e5fbab3e44cf2965467df14a665b0752de30e51'
default['nginx_proxy']['port'] = '8081'

# Specify a custom source for a single cookbook:
cookbook 'nexus3-server', path: '../cookbooks/nexus3-server'
cookbook 'nginx-proxy', path: '../cookbooks/nginx-proxy'
