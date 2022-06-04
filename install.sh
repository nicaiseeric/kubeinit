#!/bin/bash
set -ev

echo "updating deps ..."
pip3 install \
        --upgrade \
        pip \
        shyaml \
        ansible \
        netaddr

echo "installing ki/okd ..."

# Install the Ansible collection requirements
ansible-galaxy collection install --force --requirements-file kubeinit/requirements.yml

# Build and install the collection
rm -rf ~/.ansible/collections/ansible_collections/kubeinit/kubeinit
ansible-galaxy collection build kubeinit --verbose --force --output-path releases/
ansible-galaxy collection install --force --force-with-deps releases/kubeinit-kubeinit-`cat kubeinit/galaxy.yml | shyaml get-value version`.tar.gz

# Run the playbook
ansible-playbook \
    -v --user root \
    -e kubeinit_spec=okd-libvirt-3-1-1 \
    -i ./kubeinit/inventory.yml \
    ./kubeinit/playbook.yml

