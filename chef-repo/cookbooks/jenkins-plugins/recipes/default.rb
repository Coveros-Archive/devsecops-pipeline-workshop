#
# Cookbook:: jenkins-plugins
# Recipe:: default
#
# Copyright:: 2019, Coveros, Inc., All Rights Reserved.

include_recipe 'jenkins::master'

%w(ansicolor blueocean build-name-setter git github jacoco junit
   maven-plugin nexus-artifact-uploader pipeline-multibranch-defaults
   sonar warnings-ng dependency-check-jenkins-plugin).each do |plugin|
  jenkins_plugin plugin do
    notifies :restart, 'service[jenkins]', :delayed
  end
end
