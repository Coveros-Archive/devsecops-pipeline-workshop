#
# Cookbook:: maven-settings
# Spec:: default
#
# Copyright:: 2020, Coveros, Inc., All Rights Reserved.

require 'spec_helper'

describe 'maven-settings::default' do
  context 'When all attributes are default, on Ubuntu 18.04' do
    # for a complete list of available platforms and versions see:
    # https://github.com/chefspec/fauxhai/blob/master/PLATFORMS.md
    platform 'ubuntu', '18.04'

    it 'converges successfully' do
      stub_search('node', 'policy_name:nexus-repo AND policy_group:').and_return('11.22.33.44')
      expect { chef_run }.to_not raise_error
    end
  end
end
