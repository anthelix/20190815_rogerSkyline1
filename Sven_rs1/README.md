# Roger Skyline 1

## Setup (VM Part)

OS: Debian 10.0 'Buster'.
HV: Virtual Box 5.32.

### Hypervisor: Virtual Box
1. Create a new virtual machine with an 8 GB (~7.45 GiB) vdi disk. Be carrefull, VB uses Gibibytes (power-of-two) quantities with Gigabytes (power-of-ten) units. If you simply put the size in bytes, you can't go wrong. See [ConsistentUnitPrefixes][1] for more infos.
2. Change the VM's network settings to `Bridged adapter.
3. Load the debian iso into the optical drive and run the VM.

### OS: Debian
1. Select the non-graphical install.
- Hostname: `skyline`
- Root password: `imroot`
- User: `roger`
- Password: `rs1`
2. Choose `Manual paritioning` and create one partition of 4,2 GB an two other ones. Choose `/` and `/home` as mount points for the two first partitions and make the last one a swap area. Debian uses the right quantity to unit correspondance.
3. Tasksel installations: `Web server`, `SSH server` and `Utilities`.
4. Let the VM reboot (the install disk is automatically ejected).
5. Login then update and upgrade as root with the following command:
```
su -c "apt update && apt upgrade" root
```
To verify the sizes, use fdisk (GiB only) ot parted (install), both need sudo.

## Network and Security
1. The non root user is already created at install.
2. Install the `sudo` package and add the user to the sudo group with the following commands:
```
su -c "apt install sudo" root
su -c "sudo usermod -aG sudo USER" root
```
(logout and login to update)
3. Static ip. Look the ip of the VM, put it in the `/etc/network/interfaces` file and change `dhcp` with `static`:
```
iface enp0s3 inet static
	address 10.1f.x.y
	netmask 30
	gateway 10.1f.254.254
```
f represents the floor.

Restart the network service or reboot.
4. SSH:
```
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bck
sudo vi /etc/ssh/sshd_config
#Port 22 -> Port 1337
```
5. SSH Keys
Create the keys on the host machine:
```
ssh-keygen -b 4096
```
Then, copy the public key to the guest:
```
ssh-copy-id roger@10.11.200.12 -p 1337
```
You can log in with:
```
ssh roger@10.1f.x.y -p 1337
```
Finaly, for security reasons, dissallow root to acces through ssh and password authentication. Edit/add the following lines in `/etc/ssh/sshd_config`:
```
PermitRootLogin no
DenyUsers root

PasswordAuthentication no
```
6. Firewall
```
sudo apt install ufw
sudo ufw enable
sudo ufw allow 1337/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443
sudo ufw reload
```
7. DOS protection
```
sudo apt install fail2ban
sudo cp /etc/fail2ban/jail.conf /et/fail2ban/jail.local
sudo vi /etc/fail2ban/jail.local
```
Options to set in `jail.local`:
```
bantime=600
findtime=600
maxretry=3

[sshd]
enabled = true
port    = 1337
logpath = %(sshd_log)s
backend = %(sshd_backend)s
bantime = 600
findtime = 600
maxretry = 3
```
Enable all apache rules and restart the fail2ban service:
```
sudo service fail2ban restart
```
8. Port scanning
```
sudo apt install portsentry
```
Edit the following lines in `/etc/default/portsentry`
```
BLOCK_UDP="1"
BLOCK_TCP="1"
```
Restart the service:
```
sudo service portsentry restart
```
9. Services
```
sudo systemctl disable console-setup.service
sudo systemctl disable keyboard-setup.service
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl disable syslog.service
```
10. Crontab
```
sudo systemctl enable cron
```
Add the `init_apt_upgrade.sh` and `crontab_monitor.sh` scripts to the server's home and make them executable. Then, add the following lines to `/etc/crontab`:
```
@reboot roger sudo sh /home/roger/package_upgrade.sh
0 4 * * 0 roger sudo sh /home/roger/package_upgrade.sh
0 0 * * *  roger sudo sh /home/roger/crontab_monitor.sh
```

## Web
1. Create the `www/html` directory in your home and copy the default site configuration file:
```
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-prod.conf
```
Make the `DocumentRoot` in `000-prod.conf` point to your site:
```
DocumentRoot /home/roger/www/html
```
Add your directory to the security model in `/etc/apache2/apache2.conf` (follow the example with /srv/):
```
<Directory /home/roger/www/html>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
</Directory>
```
Deactivate the default site and activate yours:
```
sudo a2dissite 000-default.prod && sudo a2ensite 000-prod.conf
```
Reload the service:
```
sudo systemctl reaload apache2
```
External users have now acces to the site `http://10.1f.x.y`.
2. Copy the default ssl configuration:
```
cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/prod-ssl.conf
```
Make the `DocumentRoot` in `prod-ssl.conf` point to your site.
Enable apache2 ssl modules and your ssl site:
```
sudo a2enmod ssl
sudo a2enmod headers
sudo a2ensite prod-ssl.conf
```
Create a self-signed certificate:
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -sha256 -out /etc/ssl/private/selfsigned.crt -keyout /etc/ssl/private/selfsigned.key
```
Reload the service:
```
sudo systemctl reload apache2
```

## Deploy
Create a bare git repository on the server:
```
git init --bare ~/www/.git
```
This is not an ordinary, working, directory. This is only a git repository that stores the git revision history of the repo.
Clone this repository on the local machine or add it as remote to you web application repo:
```
git clone ssh://roger@10.1f.x.y:1337/~/www/.git
```
or
```
git remote add prod roger@10.1f.x.y:1337/~/www/.git
```
You can now push to the remote: make a first empty commit to test.
Now, we will create a hook script to add the changes to the server when pushing to master.
Create a bash script file `~/www/hooks/post-receive` on the server and add this script:
```
#!/usr/bin/env bash
#
# post-receive hook
# Deploys to production after a push.
# Only the master reference will trigger a deployment.

while read oldrev newrev ref
do
        if [[ $ref =~ .*/master$ ]];
        then
                echo "$ref: deploying to production."
                git --work-tree=/var/www/html --git-dir=/home/roger/www checkout -f
        else
                echo "$ref: nothing will be deployed to production."
        fi
done
```
Now, when pushing master from your local repo to the `prod` remote, your site will automatically be deployed.

[1]: https://wiki.debian.org/ConsistentUnitPrefixes "ConsistentUnitPrefixes"
