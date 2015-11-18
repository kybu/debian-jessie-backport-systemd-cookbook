include_recipe 'backport-systemd::common'

package 'aptly'

pub_key = cookbook_file_contents 'gpg_pub.key', 'backport-systemd'
bsw_gpg_load_key_from_string 'Import public GPG key' do
  key_contents pub_key
  for_user 'root'
end

priv_key = cookbook_file_contents 'gpg_priv.key', 'backport-systemd'
bsw_gpg_load_key_from_string 'Import private GPG key' do
  key_contents priv_key
  for_user 'root'
end

cookbook_file 'gpg_pub.key' do
  path '/root/.gnupg/bilbo_gpg_pub.key'
end

bash 'Add the gpg key into the packaging system' do
  code 'apt-key add /root/.gnupg/bilbo_gpg_pub.key'
end

bash 'Create backport-systemd package repository' do
  code <<BLA
aptly repo create -distribution=jessie -component=main backport-systemd
aptly -architectures=amd64 publish repo backport-systemd backport-systemd
ln -s /root/.aptly/public/backport-systemd /var/lib/backport-systemd
BLA
  not_if { File.exists? '/var/lib/backport-systemd' }
end

cookbook_file 'apt-backport-systemd-source.list' do
  path '/etc/apt/sources.list.d/backport-systemd.list'
  notifies :run, 'bash[aptitude update backport-systemd]', :immediately
end

bash 'aptitude update backport-systemd' do
  code 'aptitude update'
  action :nothing
end