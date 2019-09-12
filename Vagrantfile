Vagrant.configure("2") do |config|

	config.vm.define "testhost" do |host|
		host.vm.box = "ubuntu/bionic64"
		host.vm.hostname = "testhost"
        config.vm.provision "shell", inline: <<-SHELL
            sudo adduser --quiet --disabled-password --gecos '' testuser 2>/dev/null
            echo 'TrustedUserCAKeys /keys/ssh_user_key.pub' >> /etc/ssh/sshd_config
            echo 'HostKey /keys/ssh_host_ecdsa_key' >> /etc/ssh/sshd_config
            echo 'HostCertificate /keys/ssh_host_ecdsa_key-cert.pub' >> /etc/ssh/sshd_config
            service ssh restart
            echo 'Add following line to your local hosts ~/.ssh/known_hosts file to accept host certs'
            echo "@cert-authority * $(cat /keys/ssh_host_key.pub | tr -d '\n')"
            echo 'Add a /etc/hosts file entry `testhost` to resolve to 192.168.0.101'
            echo 'Check out README.md to learn how to grab user ssh certs to log into testhost'
        SHELL
		host.vm.network "private_network", ip: "192.168.0.101"
        host.vm.synced_folder "keys", "/keys"
    end

end
