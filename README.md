# MatrixDeployer
Hello! This repository is intended to setup an encrypted Matrix server environment, which you can connect with the Riot chat application. There are two main parts in this project. First one is terraform(tf) files to create the desired infrastructure. The second part is the bash scripts (sh) to build the correct packages to achieve our goal. This guide will lead you to correctly setup these two main parts.

## Prerequisites:
* Download Terraform and install it
* Download the Matrix Server code
* Make sure you are signed up for an AWS account
* Obtain or create a new IAM Access Code

## Steps:
1) First we will setup the infrastructure which will be independent from our bash scripts. To achieve this, first create a file called "secret-variables.auto.tfvars" in the project folder and enter the below lines.
```
        aws_access_key_id = "your_access_key_id_here"
        aws_secret_access_key = "your_secret_access_key_here"
```

2) Now run the below command to start the installation of the infrastructure. These terraform codes will launch an Amazon EC2 instance with Linux in it. It will also adjust the firewall rules accordingly to set the communication between tools.
```
        terraform init
        terraform apply 
        #then type "yes" as input
```
3) Setup your domain to point to the Amazon EC2 instance and wait for it to register before proceeding.

4) After our infrastructure is created successfully, we will start the first script which will build the Matrix server, Nginx server and the certbot. We will need to connect to the EC2 instance and perform all of the following steps with "root" user. Type "sudo su" to switch to root user before starting.
```
        - copy the content of "matrix_server_install.sh" file in GitHub repository.
        - create a file with the same name and edit it in Linux terminal with the below command:
        
        "vi matrix_server_install.sh"
        
        - Type "i" to switch into insert mode. Then paste all the lines within the terminal. When finished, press the "ESC" key and type ":wq." Press enter to continue. You may perform these steps with your favorite editor.
        - Finally run "sh matrix_server_install.sh" to initiate the script.
        -Answer 'y' to all installation questions.
```

5) On the first installation, you will have a registration form to start with - with a dns verification. Add the code to your DNS and wait 15 minutes or so, before clicking enter.

6) After this script has finished, perform the following script in the Linux terminal and make the following changes:
```
        - Then type "sudo certbot renew"
        - Then type:
        python -m synapse.app.homeserver \
            --server-name matrix.example.com \
            --config-path homeserver.yaml \
            --generate-config \
            --report-stats=no
        
        "vi ~/synapse/homeserver.yaml"
        
        port: 8008
        tls: false
        bind_addresses: ['127.0.0.1']
        type: http
        x_forwarded: true
        
        
        
        - Scroll down to registration and uncomment enable_registration and set it to true.
  
```

7) The next section is to configure the nginx proxy functionality by replacing the domain:
```
        "sudo vi /etc/nginx/conf.d/matrix.conf"
        
server {
    listen 80;
	listen [::]:80;
    server_name matrix.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name matrix.example.com;

    ssl on;
    ssl_certificate /etc/letsencrypt/live/matrix.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/matrix.example.com/privkey.pem;

    location / {
        proxy_pass http://localhost:8008;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
}

server {
    listen 8448 ssl default_server;
    listen [::]:8448 ssl default_server;
    server_name matrix.example.com;
            
    ssl on;
    ssl_certificate /etc/letsencrypt/live/matrix.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/matrix.example.com/privkey.pem;
    location / {
        proxy_pass http://localhost:8008;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
}
```

8) The last manual step is to create a cron job script to renew the Lets Encrypt cert. Add the following text in the script:
```
        "sudo vi /etc/cron.daily/letsencrypt-renew"

#!/bin/sh
if certbot renew > /var/log/letsencrypt/renew.log 2>&1 ; then
   nginx -s reload
fi
exit
        
        "sudo chmod +x /etc/cron.daily/letsencrypt-renew"
        "sudo crontab -e"
            - Add "01 02,14 * * * /etc/cron.daily/letsencrypt-renew"
            - Then save and exit
```

9) Start the services with the new cert and register an admin account.
```
        - copy the content from "start_services.sh" file in GitHub repository.
        - create a file with the same name and edit it in Linux terminal with the below command:
        
        "vi start_services.sh"
        
        - Type "i" to switch into insert mode. Then paste all the lines within the terminal. When finished, press the "ESC" key and type ":wq." Press enter to continue. You may perform these steps with your favorite editor.
        - Finally run "sh start_services.sh" to initiate the script.
```

10) Configure admin account.
11) When logging into the IP address for the first time, make sure you use:
```
https://matrix.example.com

```

12) Sign in from the Riot app.

## Clean Up:
When finished with the server and wanting to clean up AWS, send the command within terminal: 
```
terraform destroy
```