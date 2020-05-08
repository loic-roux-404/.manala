# -*- mode: ruby -*-
# vi: set ft=ruby :

# Use this class as Mother class for any vagrant component
# Each Component cas use plugins corresponding to a sub method
# Depending on config.json selected choice a plugin is used 
# @example : config.network.type: private => private_network() method 
# PREFIX is used to identify methods of a component (ex "_network")
# To use don't forget to add the super(<YOUR-PREFIX>) method in Child initializer
class Component
  def initialize(cnf, prefix = nil)
    @cnf = cnf
    @PREFIX = prefix
    prefix ? @MapPlugins = self.methods.grep(/#{@PREFIX}/).map(&:to_s) : nil
    p @MapPlugins
    @valid = self.requirements()
  end
  # check if your component has valid plugin type
  # (ex check correct ansible provision process)
  def is_valid_type(plugin)
    plugin && @MapPlugins.include?(@PREFIX+plugin)
  end

  # TODO rename by get_valid_types
  def rm_prefix(glue = "\n")
    str = glue
    @MapPlugins.each { |el| str += el.to_s.sub(/#{@PREFIX}/, '') + glue }
    return str.sub(/#{glue}$/, '')
  end
end

# Simplify errors 
# Show error in concerned config and suggest options
class ConfigError < Exception
  S = "\n"
  BASE_MSG = "[=== Error in config ===]"+S

  def initialize(
    _concerned = "",
    _message = BASE_MSG,
    _type = 'standard',
    _exit = true
  )
		@message ||= _message
		@concerned = _concerned 
    puts self.send(_type)
  end

  def standard()
    @error = @message += "Concerned :#{@concerned}"
  end

	def missing()
    @error = BASE_MSG
    @concerned ? @error += "Concerned : #{self.concerned}"+S : nil
    @message ? @error += "Available Options : #{@message}"+S : nil
  end

  def concerned
    @concerned.is_a?(Array) ? @concerned.join(' '): @concerned
  end
end

# Hash complements
class ::Hash
  def deep_merge(second)
      merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      self.merge(second, &merger)
  end

  def to_struct
    Struct.new(*keys.map(&:to_sym)).new(*values.to_struct)
  end
end

class ::Array
  def to_struct
    map { |value| value.respond_to?(:to_struct) ? value.to_struct : value }
  end
end