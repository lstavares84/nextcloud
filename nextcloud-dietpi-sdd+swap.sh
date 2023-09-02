# Change data directory for external storage
sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --on

sudo apt install btrfs-progs -y
sudo umount /dev/sda1
sudo mkfs.btrfs -f /dev/sda1
sudo mkdir /media/myCloudDrive		# Change this if you want to mount the drive elsewhere, like /mnt/, or change the name of the drive
rsync -avh /var/www/nextcloud/data /media/myCloudDrive
chown -R www-data:www-data /media/myCloudDrive/data
chmod -R 770 /media/myCloudDrive/data

UUID=$(sudo blkid -s UUID -o value /dev/sda1)
echo "UUID=$UUID /media/myCloudDrive btrfs defaults 0 0" | sudo tee -a /etc/fstab
sudo mount -a
sudo systemctl daemon-reload

sed -i "s/'datadirectory' => '\/var\/www\/nextcloud\/data',.*/'datadirectory' => '\/media\/myCloudDrive\/nextcloud\/data',/" /var/www/nextcloud/config/config.php

# Replace trusted_domains in the config.php file
sed -i "/'trusted_domains' =>/s/0 => 'localhost',/0 => 'localhost',\n    1 => '$NEXTCLOUD_IP',\n    2 => 'thepandacloud.duckdns.org',/" /var/www/nextcloud/config/config.php

sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off

# If Using Swap

sudo swapoff -a
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon --show
free -h
