#!/bin/bash

# Deploy Database
ansible-playbook deploy/playbooks/postgresql.yml

# Deploy Redis
ansible-playbook deploy/playbooks/redis.yml

# Deploy Docker deps
ansible-playbook deploy/playbooks/docker.yml

# Deploy Nginx
ansible-playbook deploy/playbooks/nginx.yml

# Configure ufw
ansible-playbook deploy/playbooks/ufw.yml
