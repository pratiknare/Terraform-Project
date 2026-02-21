#!/bin/bash
sudo -su ec2-user
sudo yum install mysql -y

# 1. Database Setup
export MYSQL_PWD="${db_password}"
mysql -h ${db_RDS_endpoint} -u ${db_user} <<EOF
CREATE DATABASE IF NOT EXISTS webappdb;
USE webappdb;
CREATE TABLE IF NOT EXISTS transactions (
    id INT NOT NULL AUTO_INCREMENT, 
    amount DECIMAL(10,2), 
    description VARCHAR(100), 
    PRIMARY KEY(id)
);
EOF

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
nvm install 16
nvm use 16
npm install -g pm2   

sudo yum install git -y
git clone "https://github.com/pratiknare/Terraform-Project.git"
mv aws_3tier_architecture-main/application-code/app-tier/ /home/ec2-user
cd app-tier

# 3. Create the .env file (Matches your app keys)
cat <<EOT > .env
DB_HOST=${db_RDS_endpoint}
DB_USER=${db_user}
DB_PASS=${db_password}
DB_NAME=${db_name}
EOT

npm install
pm2 start index.js
pm2 startup
pm2 save