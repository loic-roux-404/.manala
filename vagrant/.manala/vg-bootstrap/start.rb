# -*- mode: ruby -*-
# vi: set ft=ruby :

# Ruby modules
require 'json'
# Mother vagrant component model
require_relative "model/component"

class VagrantBootstrap
  # Class Plugin => Array of config keys
  PLUGINS_CONFIGS = {
    Base: false, # false give correct object with function base_config()
    Provider: [:project_name],
    Network: [:domain],
    Ansible: [:git],
    Fs: [:paths]
  }

  # Passing to each module vagrant object and part of the config struct
  def initialize(user_config, vagrant, dir)
    $vagrant = vagrant # Vagrant object
    @user_config = user_config
    $__dir__ = dir

    PLUGINS_CONFIGS.each do |plugin, others_cnf|
      require_relative "plugins/#{plugin.downcase}"
      a = [config(plugin.downcase)]
      others_cnf ? others_cnf.each { |param| a.push(config(param)) } : nil
      Object.const_get(plugin).new(*a) # Launch plugin with their associated config
    end
  end

  # Request a config by index
  def config(index = nil)
    @default ||= JSON.parse(File.read(__dir__+'/default.json'))
    @config ||= JSON.parse(@default.deep_merge(JSON.parse(@user_config)).to_json)

    if !@config[index.to_s] 
      base_config(@config).to_struct
    elsif !@config[index.to_s].is_a?(Hash)
       @config[index.to_s]
    else
      @config[index.to_s].to_struct  
    end
  end

  # Create base from config.json root
  def base_config(config)
    res = {}
    config.each do |key, value|
      !value.is_a?(Hash) && !value.is_a?(Array) ? res[key] = value : nil
    end
    res
  end
  # end class VagrantBootstrap
end

# Add common fixes depending on actuals vagrant issues
# vagrant/vbox dhcp error (v2.2.7)
class VagrantPlugins::ProviderVirtualBox::Action::Network
  def dhcp_server_matches_config?(dhcp_server, config)
    true
  end
end
