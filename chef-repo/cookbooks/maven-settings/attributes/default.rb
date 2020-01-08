#
# Cookbook:: maven-settings
# Attribute:: default
#
# Copyright:: 2020, Coveros, Inc., All Rights Reserved.

node.default['maven_settings']['settings_dir'] = '/root/.m2'
node.default['maven_settings']['username'] = 'admin'
node.default['maven_settings']['password'] = 'admin123'
