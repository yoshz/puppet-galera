# == Class galera
#
# Installs mysql with galera
#
# === Parameters
#
# [*status_password*]
#   (required) The password of the status check user
#
# [*galera_servers*]
#   (optional) A list of IP addresses of the nodes in
#   the galera cluster
#   Defaults to [$::ipaddress_eth1]
#
# [*galera_master*]
#   (optional) The node that will bootstrap the cluster if
#   all nodes go down. (There is no election)
#   Defaults to $::fqdn
#
# [*bootstrap_command*]
#   (optional) Command used to bootstrap the galera cluster
#   Defaults to a vendor- or os-specific bootstrap command.
#
# [*local_ip*]
#   (optional) The IP address of this node to use for comms
#   Defaults to $::ipaddress_eth1
#
# [*bind_address*]
#   (optional) The IP address to bind mysql to
#   Defaults to $::ipaddress_eth1
#
# [*mysql_port*]
#   (optional) The port to use for mysql
#   Defaults to 3306
#
# [*wsrep_group_comm_port*]
#   (optional) The port to use for galera clsutering
#   Defaults to 4567
#
# [*wsrep_state_transfer_port*]
#   (optional) The port to use for galera state transfer
#   Defaults to 4444
#
# [*wsrep_inc_state_transfer_port*]
#   (optional) The port to use for galera incremental
#   state transfer
#   Defaults to 4568
#
# [*wsrep_sst_method*]
#   (optional) The method to use for state snapshot transfer
#   between nodes
#   Defaults to rsync
#   xtrabackup, xtrabackup-v2, mysqldump, and skip options are also
#   accepted
#   Note that rsync 3.10 is incompatible with Percona XtraDB 5.5
#   currently (see launchpad bug #1315528). xtrabackup-v2 is the
#   recommended solution when using Percona XtraDB on platforms such as
#   Ubuntu trusty which provide rsync 3.10
#
# [*root_password*]
#   (optional) The mysql root password.
#   Defaults to 'test'
#
# [*create_root_my_cnf*]
#   (optional) Flag to indicate if we should manage the root .my.cnf. Set this
#   to false if you wish to manage your root .my.cnf file elsewhere.
#   Defaults to true
#
# [*create_root_user*]
#   (optional) Flag to indicate if we should manage the root user. Set this
#   to false if you wish to manage your root user elsewhere.
#   If this is set to undef, we will use true if galera_master == $::fqdn
#   Defaults to undef
#
# [*create_status_user*]
#   (optional) Flag to indicate if we should manage the status user. Set this
#   to false if you wish to manage your status user elsewhere.
#   Defaults to true
#
# [*override_options*]
#   (optional) Options to pass to mysql::server class.
#   See the puppet-mysql doc for more information.
#   Defaults to {}
#
# [*vendor_type*]
#   (optional) The galera vendor to use. Valid options
#   are 'mariadb' and 'percona'
#   Defaults to 'percona'
#
# [*vendor_version*]
#   (optional) The galera version to use. Valid option for percona
#   are '5.5' and '5.6'. Only valid for percona+debian.
#   Defaults to undef
#
# [*configure_repo*]
#   (optional) Whether to configure additional repositories for
#   installing galera
#   Defaults to true
#
# [*configure_firewall*]
#   (optional) Whether to open firewall ports used by galera
#   Defaults to true
#
# [*deb_sysmaint_password*]
#   (optional) The password to set on Debian for the sysmaint
#   user used during updates.
#   Defaults to 'sysmaint'
#
# [*mysql_restart*]
#   (optional) The option to pass through to mysql::server::restart
#   This can cause issues during bootstrapping if switched on.
#   Defaults to false
#
# [*mysql_package_name*]
#   (optional) The name of the server package to install.  The default is
#   platform and vendor dependent.
#
# [*galera_package_name*]
#   (optional) The name of the galera wsrep package to install.  The default is
#   platform and vendor dependent.
#
# [*client_package_name*]
#   (optional) The name of the mysql client package.  The default is platform
#   and vendor dependent.
#
# [*package_ensure*]
#   (Optional) Ensure state for package.
#   Defaults to 'installed'
#
# [*galera_package_ensure*]
#   (Optional) Ensure state for Galera package.
#   In some distibutions Galera package should have different versioning. You
#   can use this variable to lock galera package.
#   Defaults to 'installed'
#
# [*service_enabled*]
#   (optional) Whether the mysql service should be enabled
#   Defaults to undef
#
# [*manage_package_nmap*]
#   (optional) Whether the package nmap should be installed
#
# [*manage_additional_packages*]
#   (optional) Whether additional packages should be installed
#
# [*status_password*]
#   (required) The password of the status check user
#
# [*status_allow*]
#   (optional) The subnet to allow status checks from
#   Defaults to '%'
#
# [*status_host*]
#   (optional) The cluster to add the cluster check user to
#   Defaults to 'localhost'
#
# [*status_user*]
#   (optional) The name of the user to use for status checks
#   Defaults to 'clustercheck'
#
# [*status_port*]
#   (optional) Port for cluster check service
#   Defaults to 9200
#
# [*status_available_when_donor*]
#   (optional) When set to 1, the node will remain in the cluster
#   when it enters donor mode. A value of 0 will remove the node
#   from the cluster.
#   Defaults to 0
#
# [*status_available_when_readonly*]
#   (optional) When set to 0, clustercheck will return a 503
#   Service Unavailable if the node is in the read_only state,
#   as defined by the "read_only" mysql variable. Values other
#   than 0 have no effect.
#   Defaults to -1
#
# [*status_log_on_success_operator*]
#   (optional) Determines which operator xinetd uses to output logs on success
#   Defaults to '='
#
# [*status_log_on_success*]
#   (optional) Determines which fields xinetd will log on success
#   Defaults to ''
#
# [*status_log_on_failure*]
#   (optional) Determines which fields xinetd will log on failure
#   Defaults to undef
#
class galera(
  # required parameters
  String $bind_address,
  String $bootstrap_command = lookup("${name}::${vendor_type}::${vendor_version}::bootstrap_command", {default_value => undef}) ? {
    undef => lookup("${name}::${vendor_type}::bootstrap_command"),
    default => lookup("${name}::${vendor_type}::${vendor_version}::bootstrap_command"),
  },
  String $client_package_name = lookup("${name}::${vendor_type}::${vendor_version}::client_package_name", {default_value => undef}) ? {
    undef => lookup("${name}::${vendor_type}::client_package_name"),
    default => lookup("${name}::${vendor_type}::${vendor_version}::client_package_name"),
  },
  Boolean $configure_firewall,
  Boolean $configure_repo,
  Boolean $create_root_my_cnf,
  Boolean $create_status_user,
  String $deb_sysmaint_password,
  Hash $default_options,
  String $galera_master,
  String $galera_package_ensure,
  String $galera_package_name = lookup("${name}::${vendor_type}::${vendor_version}::galera_package_name", {default_value => undef}) ? {
    undef => lookup("${name}::${vendor_type}::galera_package_name"),
    default => lookup("${name}::${vendor_type}::${vendor_version}::galera_package_name"),
  },
  String $grep_binary,
  String $local_ip,
  Boolean $manage_additional_packages,
  Boolean $manage_package_nmap,
  String $mysql_binary,
  Integer $mysql_port,
  Boolean $mysql_restart,
  String $mysql_service_name = lookup("${name}::${vendor_type}::${vendor_version}::service_name", {default_value => undef}) ? {
    undef => lookup("${name}::${vendor_type}::service_name"),
    default => lookup("${name}::${vendor_type}::${vendor_version}::service_name"),
  },
  Hash $override_options,
  String $package_ensure,
  Boolean $purge_conf_dir,
  String $root_password,
  String $rundir,
  Boolean $service_enabled,
  String $status_allow,
  Integer $status_available_when_donor,
  Integer $status_available_when_readonly,
  Boolean $status_check,
  String $status_host,
  String $status_log_on_success_operator,
  String $status_password,
  Integer $status_port,
  String $status_user,
  Boolean $validate_connection,
  Enum['codership', 'mariadb', 'osp5', 'percona'] $vendor_type,
  Integer $wsrep_group_comm_port,
  Integer $wsrep_inc_state_transfer_port,
  String $wsrep_sst_auth,
  Enum['mysqldump', 'rsync', 'skip', 'xtrabackup'] $wsrep_sst_method,
  Integer $wsrep_state_transfer_port,
  # optional parameters
  Optional[Array] $additional_packages = lookup("${name}::sst::${wsrep_sst_method}::additional_packages", {default_value => undef}),
  Optional[String] $create_root_user = undef,
  Optional[String] $mysql_package_name = lookup("${name}::${vendor_type}::${vendor_version}::mysql_package_name", {default_value => undef}) ? {
    undef => lookup("${name}::${vendor_type}::mysql_package_name"),
    default => lookup("${name}::${vendor_type}::${vendor_version}::mysql_package_name"),
  },
  Optional[Array] $galera_servers = undef,
  Optional[String] $status_log_on_failure = undef,
  Optional[String] $status_log_on_success = undef,
  Optional[String] $vendor_version = undef,
) {
  if $configure_repo {
    include galera::repo
    Class['::galera::repo'] -> Class['mysql::server']
  }

  if $configure_firewall {
    include galera::firewall
  }

  # Debian machines need some help
  if ($::osfamily == 'Debian') {
    include galera::debian
  }

  if $status_check {
    include galera::status
  }

  if $validate_connection {
    include galera::validate
  }

  $node_list = join($galera_servers, ',')
  $_wsrep_cluster_address = {
    'mysqld' => {
      'wsrep_cluster_address' => "gcomm://${node_list}/"
    }
  }

  $options = mysql_deepmerge($default_options, $_wsrep_cluster_address, $override_options)

  if ($create_root_user =~ String) {
    $create_root_user_real = $create_root_user
  } else {
    if ($galera_master == $::fqdn) {
      # manage root user on the galera master
      $create_root_user_real = true
    } else {
      # skip manage root user on nodes that are not the galera master since
      # they should get a database with the root user already configured when
      # they sync from the master
      $create_root_user_real = false
    }
  }

  if (($create_root_my_cnf == true) and ($root_password =~ String)) {
    # Check if we can already login with the given password
    $my_cnf = "[client]\r\nuser=root\r\nhost=localhost\r\npassword='${root_password}'\r\n"

    exec { "create ${::root_home}/.my.cnf":
      command => "/bin/echo -e \"${my_cnf}\" > ${::root_home}/.my.cnf",
      onlyif  => [
        "${mysql_binary} --user=root --password=${root_password} -e 'select count(1);'",
        "/usr/bin/test `/bin/cat ${::root_home}/.my.cnf | ${grep_binary} -c \"password='${root_password}'\"` -eq 0",
        ],
      require => Service['mysqld'],
      before  => [Class['mysql::server::root_password']],
    }
  }

  class { '::mysql::server':
    package_name       => $galera::mysql_package_name,
    override_options   => $options,
    root_password      => $root_password,
    create_root_my_cnf => $create_root_my_cnf,
    create_root_user   => $create_root_user_real,
    service_enabled    => $service_enabled,
    purge_conf_dir     => $purge_conf_dir,
    service_name       => $galera::mysql_service_name,
    restart            => $mysql_restart,
  }

  file { $galera::rundir:
    ensure  => directory,
    owner   => 'mysql',
    group   => 'mysql',
    require => Class['mysql::server::install'],
    before  => Class['mysql::server::installdb']
  }

  if ($manage_additional_packages and $additional_packages) {
    ensure_resource(package, $additional_packages,
    {
      ensure  => $package_ensure,
      before  => Class['mysql::server::install'],
    })
  }

  Package<| title == 'mysql_client' |> {
    name => $galera::client_package_name
  }

  package {[ $galera::galera_package_name ] :
    ensure => $galera_package_ensure,
    before => Class['mysql::server::install'],
  }

  if ($fqdn == $galera_master) {
    # If there are no other servers up and we are the master, the cluster
    # needs to be bootstrapped. This happens before the service is managed
    $server_list = join($galera_servers, ' ')

    if $manage_package_nmap {
      package { 'nmap':
        ensure => $package_ensure,
        before => Exec['bootstrap_galera_cluster']
      }
    }

    # NOTE: Galera >=5.7 on systemd systems should use mysqld_bootstrap.
    #       See http://galeracluster.com/documentation-webpages/startingcluster.html.
    # NOTE: MariaDB >=10.1 on systemd systems should use galera_new_cluster.
    #       See https://mariadb.com/kb/en/library/getting-started-with-mariadb-galera-cluster/.
    exec { 'bootstrap_galera_cluster':
      command  => $bootstrap_command,
      unless   => "nmap -Pn -p ${wsrep_group_comm_port} ${server_list} | grep -q '${wsrep_group_comm_port}/tcp open'",
      require  => Class['mysql::server::installdb'],
      before   => Service['mysqld'],
      provider => shell,
      path     => '/usr/bin:/bin:/usr/sbin:/sbin'
    }

  }
}
