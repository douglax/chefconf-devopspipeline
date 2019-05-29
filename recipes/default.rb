#
# Cookbook:: apache
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.
package 'httpd'

file '/var/www/html/index.html' do
  content "<h2>This is: #{node['name']}</h2><h1>Hello World!!</h1>"
end

service 'httpd' do
  action [ :enable, :start ]
end
