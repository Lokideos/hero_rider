#!/bin/bash

# Setup
ansible-playbook deploy/playbooks/setup.yml

# Deploy application
ansible-playbook deploy/playbooks/app.yml
