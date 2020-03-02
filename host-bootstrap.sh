#!/bin/bash

# Install `step`
curl -LO https://github.com/smallstep/cli/releases/download/v0.12.0/step-cli_0.12.0_amd64.deb
sudo dpkg -i step-cli_0.12.0_amd64.deb

# Configure `step` to connect to & trust our `step-ca`
step ca bootstrap --ca-url ec2-54-167-89-236.compute-1.amazonaws.com \
                  --fingerprint 34d7a0c1d8ffc3e52cd7bde990f027622afb957c70b8e0e10fd482db47adc7c5

# Install the CA cert for validating user certificates (from ~/.ssh/certs/ssh_user_key.pub` on the CA).
echo "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBK+28xkD7pKCo5ltgUaebEngnNJZRzr+iN/sxnwSEFL0AFExpzE0FMG2W1PIh8WaHJciSvJaMp3/u00/ZvDYx9U=" > $(step path)/certs/ssh_user_key.pub

# Get an SSH host certificate
export HOSTNAME="$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)"
export TOKEN=$(step ca token $HOSTNAME --ssh --host --provisioner "mike@example.com" --password-file <(echo "pass"))
sudo step ssh certificate $HOSTNAME /etc/ssh/ssh_host_ecdsa_key.pub --host --sign --provisioner "mike@example.com" --token $TOKEN

# Configure `sshd`
sudo tee -a /etc/ssh/sshd_config > /dev/null <<EOF
# SSH CA Configuration
# The path to the CA public key for authenticatin user certificates
TrustedUserCAKeys $(step path)/certs/ssh_user_key.pub
# Path to the private key and certificate
HostKey /etc/ssh/ssh_host_ecdsa_key
HostCertificate /etc/ssh/ssh_host_ecdsa_key-cert.pub
EOF
sudo service ssh restart

# Add user `mike`
sudo adduser --quiet --disabled-password --gecos '' mike
