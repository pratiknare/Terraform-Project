#!/bin/bash
sudo -su ec2-user
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
nvm install 16
nvm use 16

sudo yum install git -y
git clone "https://github.com/pratiknare/Terraform-Project.git"
mv aws_3tier_architecture-main/application-code/web-tier/ /home/ec2-user
cd web-tier

npm install
npm run build
sudo yum install nginx -y
ls

cat << "EOF" > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;

        # HTTP to HTTPS redirection
        if ($http_x_forwarded_proto = 'http') {
            return 301 https://$host$request_uri;
        }

        #health check
        location /health {
            default_type text/html;
            return 200 "<!DOCTYPE html><p>Web Tier Health Check</p>\n";
        }

        #react app and front end files
        location / {
            root    /home/ec2-user/web-tier/build;
            index index.html index.htm;
            try_files $uri /index.html;
        }

        #proxy for internal lb
        location /api/ {
            proxy_pass http://${external_lb_dns}/;
        }
    }

}
EOF

sudo systemctl restart nginx
chmod -R 755 /home/ec2-user
sudo chkconfig nginx on