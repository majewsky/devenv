#!/usr/bin/env ruby
# This script makes ~/.config/openstack/clouds.yaml sort of available for the
# legacy OpenStack clients (`nova`, `neutron`, and so on). Together with a
# shell function in my .profile, it's used like this:
#
#   $ env | grep OS_AUTH_URL
#   $ cloud_is devstack
#   $ env | grep OS_AUTH_URL
#   OS_AUTH_URL=http://devstack.domain:5000/v3

require 'yaml'

# load config for the requested cloud from clouds.yaml
cloud_key = ARGV.first \
  or raise ArgumentError, "Usage: env_for_cloud.rb $CLOUD_NAME"
cloud = YAML.load_file('/home/stefan/.config/openstack/clouds.yaml')['clouds'][cloud_key] \
  or raise ArgumentError, "unknown cloud #{cloud_key}"
auth = cloud['auth']

# Identity v3 is always implied
  set_vars = ['auth_url']
unset_vars = []

include_one_of = lambda do |vars|
  var = vars.find { |v| auth.has_key?(v) }
  set_vars   += [var] if var
  unset_vars += vars.reject { |v| var == v }
end

# check user
include_one_of.call(%w[username user_id])
include_one_of.call(%w[user_domain_name user_domain_id])

# check requested token scope
include_one_of.call(%w[domain_id domain_name project_id project_name])
if set_vars.include?('project_name')
  include_one_of.call(%w[project_domain_id project_domain_name])
end

# is password given?
include_one_of.call(%w[password])

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
puts "export OS_AUTH_VERSION=3" # for swiftclient

# also store the cloud key (e.g. a custom prompt can display it)
puts "export CURRENT_OS_CLOUD='#{cloud_key}'"
