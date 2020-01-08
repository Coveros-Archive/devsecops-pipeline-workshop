#
# Cookbook:: deploy-war
# Attribute:: default
#
# Copyright:: 2020, Coveros, Inc., All Rights Reserved.

node.default['deploy_war']['tomcat_version'] = '9.0.30'
node.default['deploy_war']['tomcat_user'] = 'tomcat'
node.default['deploy_war']['tomcat_group'] = 'tomcat'
