#
# Cookbook:: nginx-proxy
# Recipe:: default
#
# Copyright:: 2020, Coveros, Inc., All Rights Reserved.

nginx_install 'repo' do
  default_site_enabled false
end

nginx_site 'proxy' do
  action :enable
  template 'proxy.erb'
  cookbook 'nginx-proxy'
end
