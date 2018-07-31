# xTuple Admin Utility
The xTuple Admin Utility (xTAU) is a toolkit for administering xTuple on an Ubuntu Linux server. It includes options for performing a quick installation of xTuple, and for maintaining the PostgreSQL server and xTuple databases. 

xTAU runs on Linux, Ubuntu 14.04 LTS, 14.10, 15.04, and 16.04. Debian 7.x and 8.1, all 64bit only.

Quick Setup:

sudo apt-get install git

git clone https://github.com/xtuple/xtuple-admin-utility.git

cd xtuple-admin-utility && ./xtuple-utility.sh

If you are installing from scratch, choose Quick Install from the main menu. You will be prompted to choose web-enabled or non-web-enabled and then prompted to enter information such as postgresql port, cluster name, postgres user password, admin passwords and so on. Remember what you choose!

For an unattended install on a clean machine, try: ./xtuple-utility.sh -a

Help Output:
```
To get an interactive menu run xtuple-utility.sh with no arguments

  -h    Show this message
  -a    Install all (PostgreSQL (currently 9.6), demo database (currently 4.11.3) and web client (currently 4.11.3))
  -d    Specify database name to create
  -p    Override PostgreSQL version
  -n    Override instance name
  -x    Override xTuple version (applies to web client and database)
  -t    Specify the type of database to grab (demo/quickstart/empty)
```

Full instructions for getting, installing, and using the xTuple Admin Utility are available in the xTuple Admin Guide, on xTuple University. 

[Chapter 3. Web-Enabled Server Administration on Linux Using xTAU](https://xtupleuniversity.xtuple.com/sites/default/files/prodguide/admin-guide/xtau-admin.html).

## Vagrant setup

### Prerequisites

- MacOSX or Linux is used.
- Code of xTupleCommerce projects is placed into `~/Code/Drupal7` directory on the host machine (on your MacOS or Linux).
- Each xTupleCommerce directory name ends with `.xd`, e.g. `example.xd`.

### Installation

+ Update your operating system and packages:
    - _(MacOSX)_ if you use [brew](https://brew.sh), make sure `brew doctor` returns `Your system is ready to brew.` and `brew update` returns `Already up-to-date.`;
    - _(Ubuntu Linux)_ run `sudo apt-get update && sudo apt-get upgrade`
    - run `gem update`.
+ Download and install VirtualBox ([https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)).
+ Download and install Vagrant ([http://downloads.vagrantup.com](http://www.vagrantup.com/downloads.html)).
+ Install `vbguest` plugin ([dotless-de/vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)), run `vagrant plugin install vagrant-vbguest`.
+ Install `sshfs` plugin ([dustymabe/vagrant-sshfs](https://github.com/dustymabe/vagrant-sshfs)), run `vagrant plugin install vagrant-sshfs`.
+ _(MacOSX)_: Install `dns` plugin ([BerlinVagrant/vagrant-dns](https://github.com/BerlinVagrant/vagrant-dns)), run `vagrant plugin install vagrant-dns`.
+ Go to _xTAU_ directory, e.g. `cd ~/Vagrant/xtau`.
+ Copy `config.yaml.dist` (located in the repository root) as `config.yaml`, e.g. run `cp config.yaml.dist config.yaml`.
+ Edit `config.yaml` with your local data:
    +  ensure the IP address for virtual machine is not used (`192.168.33.xyz` pattern is recommended).
    +  setup your local timezone (see [Linux Timezones list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)).
    +  setup address for the synced folder on your *host* machine.
    +  ensure you have the right host machine OS set (use `:macos` for MacOSX, `:linux` for Linux, and `:windows` for Windows).
    +  setup your Github token (see: [Creating Github token](https://help.github.com/articles/creating-an-access-token-for-command-line-use)).
    +  setup your host machine username (run `whoami` in your terminal).
+ Run `vagrant up` to start your virtual machine.
+ Run `vagrant reload` as Ubuntu on virtual host requires restart after all updates applied during the installation.
+ _(MacOSX)_ Run `vagrant dns --install` to activate `vagrant-dns` plugin (user password will be asked).

### Directories

- `~/Code/Drupal7` on the host machine would be available as `/opt/xtuple/commerce` on the virtual machine; this location is used by Nginx by default.
- `xtau` directory on the host machine (e.g. `~/Vagrant/xtau`) is available as `/vagrant` on the virtual machine.

### Know issues

#### "Bundler, the underlying system Vagrant uses to install plugins, reported an error."

To resolve the issue download the latest Vagrant image, use uninstall tool it's delivered with, then install Vagrant again. It should clean-up libraries/dependencies and resolve the issue.

#### SSH private key not working

It's recommended to use git only on the host machine, as it's usually fully set up there. Yet, if you use git on the virtual machine, there might be a problem with access to private repos. The SSH keys are forwarded from host machine to virtual machine by Vagrant, but if they are not in the keychain (for MacOS) they won't work automatically. So make sure to run `ssh-add -K ~/.ssh/id_rsa` to add your private key to the keychain.
