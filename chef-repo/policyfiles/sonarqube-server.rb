# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

# A name that describes what the system you're building with Chef does.
name 'sonarqube-server'

include_policy "fast-client", path: "./fast-client.lock.json"

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'java::default', 'sonarqube::default', 'nginx-proxy::default'

# Policyfile defined attributes
default['java']['jdk_version'] = '11'
default['sonarqube']['mirror'] = 'https://binaries.sonarsource.com/Distribution/sonarqube'
default['sonarqube']['version'] = '8.1.0.31237'
default['sonarqube']['checksum'] = 'd955449cb4fdf0f0f09d2fe0e9ed8d5cb32048ead11d6272931ab36ac9a9c1c0'
default['nginx_proxy']['port'] = '9000'

# Specify a custom source for a single cookbook:
cookbook 'nginx-proxy', path: '../cookbooks/nginx-proxy'
