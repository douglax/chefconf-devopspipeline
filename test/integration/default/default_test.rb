# # encoding: utf-8

# Inspec test for recipe apache::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('httpd') do
  it { should be_installed }
end

describe file('/var/www/html/index.html') do
  it { should exist }
  its('content') { should match(/Hello World/) } 
end

describe service('httpd') do
   it { should be_enabled }
   it { should be_running }
end

describe command('curl localhost') do
    its('stdout') { should match(/Hello World!!/)}
end
