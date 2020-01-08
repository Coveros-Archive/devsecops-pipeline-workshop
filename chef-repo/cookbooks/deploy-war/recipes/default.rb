#
# Cookbook:: deploy-war
# Recipe:: default
#
# Copyright:: 2020, Coveros, Inc., All Rights Reserved.

tomcat_install node['deploy_war']['webapp'] do
  version node['deploy_war']['tomcat_version']
  tomcat_user node['deploy_war']['tomcat_user']
  tomcat_group node['deploy_war']['tomcat_group']
  exclude_manager true
  exclude_hostmanager true
end

remote_file "/opt/tomcat_#{node['deploy_war']['webapp']}/webapps/ROOT.war" do
  owner node['deploy_war']['tomcat_user']
  mode '0644'
  source node['deploy_war']['url']
end

tomcat_service node['deploy_war']['webapp'] do
  action [:start, :enable]
  tomcat_user node['deploy_war']['tomcat_user']
  tomcat_group node['deploy_war']['tomcat_group']
end
