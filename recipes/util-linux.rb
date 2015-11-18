include_recipe 'backport-systemd::common'

execute 'Fetch util-linux source package' do
  command 'apt-get source util-linux/testing'
  cwd '/root/deb-packages/util-linux'
end

bash 'Install util-linux build dependencies' do
  code 'aptitude -y build-dep util-linux'
end

ruby_block 'Patch util-linux sources' do
  block do
    Dir.chdir '/root/deb-packages/util-linux/util-linux-2.27.1/debian/' do
      control = Chef::Util::FileEdit.new 'control'
      control.search_file_replace(
          /\b(initscripts|sysvinit-utils)\s+\(.*?\)/,
          '\1')
      control.write_file

      rules = Chef::Util::FileEdit.new 'rules'
      rules.search_file_replace(
          /(dh\s+\$@\s+--with\s+autoreconf,systemd)\s*$/,
          '\1 --parallel')
      rules.write_file
    end
  end
end

bash 'Build util-linux' do
  code $BUILDDPKG
  cwd '/root/deb-packages/util-linux/util-linux-2.27.1'
end

bash 'Add util-linux into the package repository' do
  code 'aptly repo add backport-systemd *.deb'
  cwd '/root/deb-packages/util-linux'
end

bash 'Publish backport-systemd repository with util-linux' do
  code 'aptly publish update jessie backport-systemd'
end

bash 'aptitude update util-linux' do
  code 'aptitude update'
end

bash 'aptitude upgrade util-linux' do
  code 'aptitude -y upgrade'
end