# -*- mode: ruby -*-
# vi: set ft=ruby :

# TODO is this really required? 
IP = '10.0.0.10' 

Vagrant.configure("2") do |config|
  config.vm.hostname = "devops"
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.provider :virtualbox do |vb|
    vb.memory = 2048
  end

  config.vm.network "private_network", ip: IP

  # before anything else, make sure we have the latest sources list
  config.vm.provision "updating sources", type: "shell", inline: "apt-get update"

  # installs debian cache so any additional box running in this network can avoid the internet
  # this is particularly useful if running this box on a laptop, so you can start boxes while offline
  # TODO apparently apt-cacher-ng doesn't support using /vagrant for its cache. This means all cached data will
  # live inside the box and be purged when we destroy it.
  config.vm.provision "installing apt-cacher", type: "shell", inline: "apt-get install -y apt-cacher-ng"
  config.vm.network "forwarded_port", guest: 3142, host: 3143
  # config.vm.provision "config apt-cacher", type: "shell", inline: "echo 'Acquire::http { Proxy \"http://localhost:3142\"; };' > /etc/apt/apt.conf.d/02proxy"

  config.vm.provision "installing docker", type: "shell", path: "scripts/install-docker.sh"
  config.vm.provision "installing registry", type: "shell", inline: "docker run -d -p 5000:5000 -v /vagrant/docker-registry/data:/var/lib/registry --restart=always --name registry registry:2"
  config.vm.network "forwarded_port", guest: 5000, host: 5000
end

def provision_image (box, registry, image, version)
  args = [registry, image, version]
  if DOCKER_REGISTRY != nil then
    args.push DOCKER_REGISTRY['url']
  end
  box.vm.provision "pulling #{image}", type: "shell" do |shell|
    shell.path = "scripts/pull-image.sh"
    shell.args = args
  end
end