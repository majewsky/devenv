#!/usr/bin/env ruby
# This script makes ~/.config/openstack/clouds.yaml sort of available for the
# legacy OpenStack clients (`nova`, `neutron`, and so on). Together with a
# shell function in my .profile, it's used like this:
#
#   $ env | grep OS_AUTH_URL
#   $ cloud devstack
#   $ env | grep OS_AUTH_URL
#   OS_AUTH_URL=http://devstack.domain:5000/v3

require 'yaml'

# load config for the requested cloud from clouds.yaml
cloud_key = ARGV.first \
  or raise ArgumentError, "Usage: env_for_cloud.rb $CLOUD_NAME"
cloud = YAML.load_file('/home/stefan/.config/openstack/clouds.yaml')['clouds'][cloud_key] \
  or raise ArgumentError, "unknown cloud #{cloud}"
auth = cloud['auth']

# some variables are always set (Identity v3 is always implied)
  set_vars = %w[auth_url username password user_domain_name]
# domain/project/user IDs are not supported yet
unset_vars = %w[domain_id user_domain_id project_domain_id project_id]

# check requested token scope
if auth.has_key?('domain_name')
    set_vars += %w[domain_name]
  unset_vars += %w[project_name project_domain_name]
elsif auth.has_key?('project_name')
    set_vars += %w[project_name project_domain_name]
  unset_vars += %w[domain_name]
else
  unset_vars += %w[project_name project_domain_name domain_name]
end

# generate sh code
set_vars.each do |var|
  puts "export OS_#{var.upcase}='#{auth[var]}'"
end
unset_vars.each do |var|
  puts "unset OS_#{var.upcase}"
end

# the region name is a special snowflake
puts "export OS_REGION_NAME='#{cloud['region_name']}'"

# enforce Identity v3
puts "export OS_IDENTITY_API_VERSION=3"

# also store the cloud key (e.g. a custom prompt can display it)
puts "export CURRENT_OS_CLOUD='#{cloud_key}'"
