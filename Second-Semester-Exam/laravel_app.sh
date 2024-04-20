#!/bin/bash      

# sudo apt update
# Function to display messages in gold
gold_echo() {
    echo -e "\e[38;5;220m$@\e[0m"
}


function install_lamp() {
# Install PHP
gold_echo "---------------------update php repository-----------------------"

 sudo apt update
 sudo add-apt-repository ppa:ondrej/php -y

gold_echo "-----------------------Installing Php8.2-----------------------------------------"
 sudo apt install php8.2 -y

gold_echo "-------------------------------------Installing php dependencies----------------------------"

 sudo apt install php8.2-curl php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip -y

gold_echo "-------------------------- php done ----------------------------------"

#Install Apache web server

gold_echo "----------------------------Installing Apache--------------------------------------------------"

 sudo apt install apache2 -y
 sudo apt update
 sudo systemctl restart apache2

#Install Mysql-server

gold_echo "------------------------------------Installing mysql-server----------------------------------------------"

 sudo apt install mysql-server -y
}

 composer_setup() {
 cd ~
 gold_echo "-----------------------Back Home -> ( "$HOME") ->  Checking if composer directory has been created---------------------"       

 if [ -d "$HOME/composer" ]; then

         gold_echo "--------------------------------------Composer Directory Exists--------------------------------------------"
 else
   mkdir composer
   cd composer

   gold_echo "-------------------Directory created successfully--------------------------------"

   curl -sS https://getcomposer.org/installer | php
   sudo mv composer.phar /usr/local/bin/composer

   gold_echo "------------------- Composer Added Successfully-------------------------"
 fi
}

 setup_laravel_app() {
 cd /var/www/

 sudo rm -r ./*
 sudo git clone https://github.com/laravel/laravel
 sudo chown -R $USER:$USER laravel
 cd laravel
#Install dependencies using composer
 composer install
 cp .env.example .env
 php artisan key:generate
 sudo chown -R www-data bootstrap/cache
 sudo chown -R www-data storage

}

conf_mysql() {
   cd /var/www/laravel

   gold_echo "-------------Setup mysql database and user--------------------------------"

# Configure MySQL database
sudo mysql -uroot -e "CREATE DATABASE laravel_db;"
sudo mysql -uroot -e "CREATE USER 'laravel_user'@'localhost' IDENTIFIED BY '000000';"
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel_user'@'localhost';"
sudo mysql -uroot -e "FLUSH PRIVILEGES;"


gold_echo "-----------------Done with database setup--------------"
gold_echo "------------------Editing .env file--------------------"




   sed -i 's/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/' .env
   sed -i 's/# DB_HOST=127.0.0.1/DB_HOSTS=127.0.0.1/' .env
   sed -i 's/# DB_PORT=3306/DB_PORT=3306/' .env
   sed -i 's/# DB_DATABASE=laravel/DB_DATABASE=laravel_db/' .env
   sed -i 's/# DB_USERNAME=root/DB_USERNAME=laravel_user/' .env
   sed -i 's/# DB_PASSWORD=/DB_PASSWORD=000000/' .env


   gold_echo "--------------------Clearing Cache (php artisan cache)------------------"
   php artisan cache:clear
   gold_echo "--------------------Clearing Config(php artisan config)------------------"
   php artisan config:clear


gold_echo "-------Migrating database--------"

   php artisan migrate

}

apache_conf() {
    #Setup Virtual host for app
    cd ~
    sudo tee /etc/apache2/sites-available/laravel.conf <<EOF
    <VirtualHost *:80 *:3000>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/laravel/public/

    <Directory /var/www/laravel/public/>
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
  </VirtualHost>
EOF


  cd ~
   sudo a2dissite 000-default.conf
   sudo a2enmod rewrite
   sudo a2ensite laravel.conf
   sudo systemctl restart apache2
}

#Functions
main() {
install_lamp
composer_setup
setup_laravel_app
conf_mysql
apache_conf
}

#Execute All Functions
main