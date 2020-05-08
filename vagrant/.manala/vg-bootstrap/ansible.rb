# -*- mode: ruby -*-
# vi: set ft=ruby :

class Ansible < Component
  PREFIX = 'ans_'
  PLAYBOOK_PATH = "~/.ansible"
  
  def initialize
    super(PREFIX)
    if requirements
      # dispatch
      parse_config
      self.send(@PREFIX+$config.ansible.type)
    end
  end

  def ans_local(ansible_mode_id = 'ansible_local')
    # Put playbook in guest
    if (ansible_mode_id == 'ansible_local')
      $vagrant.vm.provision :shell, inline: @git_clone 
    end
    # Start ansible-playbook command  
    $vagrant.vm.provision ansible_mode_id do |ansible|
      ansible.provisioning_path = "#{PLAYBOOK_PATH}"
      ansible.playbook = $config.ansible.playbook
      ansible.inventory_path = $config.ansible.inventory # TODO : case no inventory
      ansible.extra_vars = $config.ansible.extra_vars
    end
  end

  def ans_classic
    system(git_clone)
    self.ans_local('ansible')
  end

  def ans_worker
    $vagrant.vm.provision :shell,
      run: './utils/playbook-worker.sh',
      args: "#{@git_url} #{$config.ansible.sub_playbook} #{$config.ansible.inventory}"
  end

  def parse_config
    if $config.ansible.playbook
      @git_url = [
        $config.git.provider, 
        $config.git.org,
        $config.ansible.playbook
      ].join('/')
      @git_clone = "git clone #{@git_url} #{PLAYBOOK_PATH}/#{$config.ansible.playbook}"
    end
  end

  def requirements
    if $config.ansible.disabled || !$config.git.org || !$config.ansible.playbook
      ConfigError.new(
        ["$config.ansible.disabled", "$config.git.org", "$config.ansible.playbook"], # options concerned
        "bool | string<git-username> | string<playbook-name>", # suggest for option
        'missing'
      )
      return false
    end

    if !self.is_valid_type($config.ansible.type)
      raise ConfigError.new(
        ["config.ansible.type"], # options concerned
        self.rm_prefix("\n - "), # suggest for valid process of this component
        'missing'
      )
    end
  end
  # end class Ansible
end
