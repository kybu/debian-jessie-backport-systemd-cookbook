include_recipe 'backport-systemd::common'

execute 'Fetch bash-completion source package' do
  command 'apt-get source bash-completion/testing'
  cwd '/root/deb-packages/bash-completion'
end

bash 'Build bash-completion' do
  code "aptitude -y build-dep bash-completion && #{$BUILDDPKG}"
  cwd '/root/deb-packages/bash-completion/bash-completion-2.1'
end

bash 'Add bash-completion into the package repository' do
  code 'aptly repo add backport-systemd *.deb'
  cwd '/root/deb-packages/bash-completion'
end

bash 'Publish backport-systemd repository with bash-completion' do
  code 'aptly publish update jessie backport-systemd'
end

bash 'aptitude update bash-completion' do
  code 'aptitude update'
end

bash 'aptitude upgrade bash-completion' do
  code 'aptitude -y upgrade'
end