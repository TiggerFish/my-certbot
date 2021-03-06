# my-certbot
Ansible playbook to build and run the my-certbot container.

A week or so ago I completed a small project to build a container using the buildah and podman tools to retrieve ssl certificates from letsencrypt. This was all done with bash scripting and I have since read the Ansible for Devops book by Jeff Geerling. I thought it would be a good challenge to try and ansibalise the install. This is the result.
* This playbook has been tested with a current basic install of **CentOS** (CentOS Linux release 7.6.1810 (Core)) and **Fedora** (Fedora release 29 (Twenty Nine))

### Basic usage
1.  Clone the repository and cd in to the my-certbot directory
1.  Set the variables in **my_certbot_vars.yml**
1. If you are running on localhost change the hosts variable at the top of the **my_certbot_setup.yml** playbook from **all** to **localhost** otherwise use a suitable inventory file.
1.  Run the **my_certbot_setup.yml** playbook
1.  On the tarhget host, run the **buildit.sh** script found in the directory set by the **container_control** variable in the **my_certbot_vars.yml** file
1.  On the target host, run the **run-certbot.sh** script found in the directory set by the **container_control** variable in the **my_certbot_vars.yml** file
1.  Collect your certificates from the **letsencrypt/archive/<domain_name>** directory found in the directory set buy the **certbot_working variable** in the **my_certbot_vars.yml** file

### **my_certbot_vars.yml** file in a bit more detail.

#### certbot_working: "/a_directory_without_a_trailing_slash"
  * All of the output from the certbot agent will end up here.
  * The certbot **cli.ini** file can be found in here **.config/letsencrypt/cli.ini**
  * The AWS **credentials** file if used can be found in here **.aws/credentials**
  * The script that runs inside the container when it starts can be found in here
  * Everything in this location is owned by the certbot user.

#### container_control: "/a_directory_without_a_trailing_slash"
  * Two scripts end up in here, **buildit.sh** and **run-certbot.sh**
  * **buildit.sh** builds the my-certbot container from scratch using buildah
  * **run-certbot.sh** runs the container and then cleans the image up once it has completed.

#### update_firewall: true | false
* controls the running of the my_certbot_firewall play.
* ####IMPORTANT##### The my_certbot_firewall play will delete all existing firewall rules and enable only the minimum configuration required to run the container.
 * ####IMPORTANT##### Do not run this play if you have a preconfigured firewall that you want to keep.

#### loclan: ['A', 'List', 'of', 'values']
  * networks or IP's that will allow ssh in to the host, only applies if update_firewall: true

#### Certbot ini settings
* See this url for more detail https://certbot.eff.org/docs/using.html#configuration-file
* **rsa_key_size:** = certbot cli.ini setting rsa-key-size
* **email:** = certbot cli.ini setting email
* **no_eff_email:** = certbot cli.ini setting no-eff-email
* **agree_tos:** = certbot cli.ini setting agree-tos
* **le_server:** = certbot cli.ini setting server

#### aws_used: true | false
*  controls if the aws route53 dns method of obtaining certificates runs
  
#### aws_access_key_id:
*  aws access key required to authenticate with aws so that the route53 dns method of obtaining certificates can run

#### aws_secret_access_key:
*  aws secret access  key required to authenticate with aws so that the route53 dns method of obtaining certificates can run

#### aws_domains: ['A', 'List', 'of', 'values']
*  a list of the domains that will use the route53 dns method of obtaining certificates

#### web_root_used: true | false
*  controls if the webroot method of obtaining certificates runs

#### web_root_domains: ['A', 'List', 'of', 'values']
*  a list of the domains that will use the webroot method of obtaining certificates



