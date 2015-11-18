$CPU_NPROC=`nproc`.to_i

bash 'Update repository keys' do
  code 'apt-key update'
end

package 'aptitude'

cookbook_file 'apt-testing-src-source.list' do
  path '/etc/apt/sources.list.d/apt-testing-src.list'
end

bash 'aptitude update' do
  code 'aptitude -y update'
end

$BUILDDPKG="DEB_BUILD_OPTIONS='nocheck parallel=#{$CPU_NPROC}' dpkg-buildpackage -uc -us"

package 'build-essential'

directory '/root/deb-packages'
directory '/root/deb-packages/systemd'
directory '/root/deb-packages/util-linux'
directory '/root/deb-packages/bash-completion'
