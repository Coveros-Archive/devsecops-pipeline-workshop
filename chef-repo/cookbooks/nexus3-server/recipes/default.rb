#
# Cookbook:: nexus3-server
# Recipe:: default
#
# Copyright:: 2020, Coveros, Inc., All Rights Reserved.

include_recipe 'nexus3'

nexus3 'nexus' do
  action :install
end
