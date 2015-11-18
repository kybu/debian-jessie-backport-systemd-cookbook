include_recipe 'backport-systemd::common'

execute 'Fetch systemd source package' do
  command 'apt-get source systemd/testing'
  cwd '/root/deb-packages/systemd'
end

# Build dependencies

package 'libcap-dev'
package 'libapparmor-dev'

bash 'Install systemd build dependencies' do
  code 'aptitude -y build-dep systemd'
end

ruby_block 'Patch systemd sources' do
  block do
    Dir.chdir '/root/deb-packages/systemd/systemd-227/debian/' do
      control = Chef::Util::FileEdit.new 'control'
      control.search_file_replace(
          /\b(libcap-dev|libapparmor-dev|apparmor)\s+\(.*?\)/,
          '\1')
      control.write_file
    end
  end
end

bash 'Build systemd' do
  code $BUILDDPKG
  cwd '/root/deb-packages/systemd/systemd-227'
end

bash 'Add systemd into the package repository' do
  code 'aptly repo add backport-systemd *.deb'
  cwd '/root/deb-packages/systemd'
end

bash 'Publish backport-systemd repository with systemd' do
  code 'aptly publish update jessie backport-systemd'
end

bash 'aptitude update systemd' do
  code 'aptitude update'
end

bash 'aptitude upgrade systemd' do
  code 'aptitude -y upgrade'
end

package 'systemd-container'
package 'systemd-journal-remote'
package 'libnss-mymachines'