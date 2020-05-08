# -*- mode: ruby -*-
# vi: set ft=ruby :

class Provider < Component
  PREFIX = 'provider_'

  def initialize(cnf, project_name = '')
    @project_name = project_name
    super(cnf,PREFIX)

    ENV['VAGRANT_DEFAULT_PROVIDER'] = @cnf.type
    self.send(PREFIX+@cnf.type)
  end

  # create virtualbox config with VboxManage settings
  def provider_virtualbox
    $vagrant.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, "--name", @project_name]
      @cnf.opts.each do |param_id, value|
        vb.customize ['modifyvm', :id, "--#{param_id}", value]
      end
    end
  end

  def provider_libvirt
    raise "libvirt isn't supported for now"
  end

  def provider_vmware
    raise "vmware isn't supported for now"
  end

  def provider_parallels
    raise "parallels isn't supported for now"
  end

  def provider_docker
    raise "docker isn't supported for now"
  end

  def requirements
    if !self.is_valid_type(@cnf.type)
      raise ConfigError.new(
        ['provider.type'], # options concerned
        self.rm_prefix("\n - "), # suggest for option
        'missing'
      )
    end
  end
# end Class Provider#
end
