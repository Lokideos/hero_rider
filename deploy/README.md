Deployment readme
1) Copy hosts.sample to hosts and change database_password and domain_name to correct values
2) Copy playbooks/files/env/vars.sample to playbooks/files/env/vars and change var values accordingly
3) Prepare sudo passwordless deployer user on the server
4) From project root directory use command sh deploy/deploy_infrastructure.sh
5) Install https certificate using instructions from https://certbot.eff.org/
6) From project root directory use command sh deploy/enable_https.sh
7) From project root directory use command sh deploy/deploy_application.sh