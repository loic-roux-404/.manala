# -*- mode: ruby -*-
# vi: set ft=ruby :

class Network < Component
  PREFIX = 'network_'
  def initialize(cnf, domain)
    @domain = domain
    super(cnf,PREFIX)
    self.send(PREFIX+@cnf.type)
    redirect_ports
    @cnf.dns ? dns : nil
    @ssl ? ssl : nil
  end

  def network_public
    $vagrant.vm.network :private_network, ip: @cnf.ip
    preferred_interfaces = ['eth0.*', 'eth\d.*', 'enp0s.*', 'enp\ds.*', 'en0.*', 'en\d.*']
    host_interfaces = %x( VBoxManage list bridgedifs | grep ^Name ).gsub(/Name:\s+/, '').split("\n")
    network_interface_to_use = preferred_interfaces.map{ |pi| 
      host_interfaces.find { |vm| vm =~ /#{Regexp.new(pi)}/ } 
    }.compact[0]
    
    $vagrant.vm.network :public_network, bridge: network_interface_to_use #, adapter: "1"
    routing
  end 

  def network_private
    $vagrant.vm.network :private_network, ip: @cnf.ip, dhcp: @cnf.dhcp
  end

  def dns
    $vagrant.landrush.enabled = true
    $vagrant.landrush.tld = @domain
  end

  def redirect_ports
    @cnf.ports.each do |port|
      $vagrant.vm.network :forwarded_port, id: port.id || nil,
        guest: port.guest, 
        host: port.host,
        auto_correct: port.auto_correct || true,
        disabled: port.disabled || false
    end
  end

  def routing
    if Vagrant::Util::Platform.darwin? 
      @gateway = `route -n get default | grep 'gateway' | awk '{print $2}'`.delete("\n")
    elsif Vagrant::Util::Platform.linux? 
      # Not tested
      @gateway = `ip route show`[/default.*/][/\d+\.\d+\.\d+\.\d+/]
    end

    $vagrant.vm.provision :shell, 
      run: "always", 
      path: File.join(__dir__, "../", "/utils/routing.py"),
      args: "#{@gateway}"
  end

  def ssl
    # Not tested
    cert = @cnf.ssl.cert
    host_path = "#{$__dir__}/.vagrant/certs"
    guest_path = @cnf.ssl.path

    Dir.mkdir(host_path) unless File.exists?(host_path)

    $vagrant.trigger.after :up do |t|
      t.run = { inline: "scp -P 22 vagrant@#{@domain}:#{guest_path}/#{cert} #{host_path}"}

      if Vagrant::Util::Platform.darwin? || Vagrant::Util::Platform.linux?
        t.run = { inline: 
          "sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain #{host_path}/#{cert}"
        }
      else
        t.run = { inline: "certutil -enterprise -f -v -AddStore 'Root' '#{host_path}/#{cert}'"}
      end
    end
  end

  def requirements
    p @cnf.type
    if !self.is_valid_type(@cnf.type)
      raise ConfigError.new(
        ["network.type"], # options concerned
        self.rm_prefix("\n - "), # suggest for option
        'missing'
      )
    end

    if @cnf.dns && !Vagrant.has_plugin?('landrush')
			system('vagrant plugin install landrush')
    end
    
    if @cnf.ssl.path && @cnf.ssl.cert
      @ssl = true
    end
  end
 # end class 
end
