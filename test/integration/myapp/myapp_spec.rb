# describe service('nginx') do
#   it { should be_installed }
#   it { should be_enabled }
#   it { should be_running }
# end

describe file('/usr/share/nginx/html/index.html') do
  it { should exist }
  its('type') { should cmp 'file' }
  it { should be_file }
  it { should_not be_directory }
  its('content') { should match /ver: test123/ }
end
