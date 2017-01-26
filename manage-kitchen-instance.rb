#!/usr/bin/env ruby

require "yaml"
require 'aws-sdk'
require 'thor'

class ManageInstance < Thor

  no_commands{
    def get_instance_config(kitchen_instance_file=nil)
      if ! File.exists?(kitchen_instance_file)
        puts "ERROR: Kitchen instance file '#{kitchen_instance_file}' does not exist."
        exit 1
      end
      puts "Using kitchen instance file #{kitchen_instance_file}"
      instance_config = YAML.load(IO.read(kitchen_instance_file))
    end

    def get_instance_type(instance_config=nil)
      if instance_config['server_id']
        return 'ec2'
      elsif instance_config['hostname'] == '127.0.0.1' && instance_config['username'] == 'vagrant'
        return 'vagrant'
      else
        puts "ERROR: Unable to determine instance type."
        exit 1
      end
    end

    def get_ec2_instance(instance_config=nil)
      Aws::EC2::Instance.new(instance_config['server_id'])
    end

    def get_vagrant_instance_path(kitchen_instance_file=nil)
      File.join(Dir.pwd, %w{.kitchen kitchen-vagrant}, "kitchen-#{File.basename(Dir.pwd)}-#{File.basename(kitchen_instance_file, '.yml')}")
    end

    def update_kitchen_instance_file_hostname(kitchen_instance_file=nil, i=nil)
      if i.public_dns_name.empty?
        puts "ERROR: Public DNS Name is not set for EC2 instance #{i.id}. Make sure the instance exists and is running."
        puts "Instance #{i.id} is #{i.state.name}"
        exit 1
      end
      puts "Updating hostname for EC2 instance #{i.id} to #{i.public_dns_name}"
      kitchen_instance = YAML.load(IO.read(kitchen_instance_file))
      kitchen_instance['hostname'] = i.public_dns_name
      IO.write(kitchen_instance_file, kitchen_instance.to_yaml)
    end
  }    

  desc "status", "Print instance state"
  option :file, :aliases => "-f", :desc => "Specify a kitchen instance file. `.kitchen/default-ubuntu-1610.yml` will be used by default"
  def status
    kitchen_instance_file = options[:file] || '.kitchen/default-ubuntu-1610.yml'
    instance_config = get_instance_config(kitchen_instance_file)
    case get_instance_type(instance_config)
    when 'ec2'
      i = get_ec2_instance(instance_config)
      puts "EC2 instance #{i.id} is #{i.state.name}"
    when 'vagrant'
      p = get_vagrant_instance_path(kitchen_instance_file)
      puts "Getting status of Vagrant instance at path #{p}"
      Dir.chdir(p) do
        system('vagrant status')
      end
    end
  end

  desc "start", "Start instance"
  option :file, :aliases => "-f", :desc => "Specify a kitchen instance file. `.kitchen/default-ubuntu-1610.yml` will be used by default"
  def start
    kitchen_instance_file = options[:file] || '.kitchen/default-ubuntu-1610.yml'
    instance_config = get_instance_config(kitchen_instance_file)
    case get_instance_type(instance_config)
    when 'ec2'
      i = get_instance(kitchen_instance_file)
      puts "Starting EC2 instance #{i.id}"
      i.start
      i.wait_until_running
      update_kitchen_instance_file_hostname(kitchen_instance_file, i)
    when 'vagrant'
      p = get_vagrant_instance_path(kitchen_instance_file)
      puts "Starting Vagrant instance at path #{p}"
      Dir.chdir(p) do
        system('vagrant up')
      end
    end
  end

  desc "stop", "Stop instance"
  option :file, :aliases => "-f", :desc => "Specify a kitchen instance file. `.kitchen/default-ubuntu-1610.yml` will be used by default"
  def stop
    kitchen_instance_file = options[:file] || '.kitchen/default-ubuntu-1610.yml'
    instance_config = get_instance_config(kitchen_instance_file)
    case get_instance_type(instance_config)
    when 'ec2'
      i = get_instance(kitchen_instance_file)
      puts "Stopping EC2 instance #{i.id}"
      i.stop
      i.wait_until_stopped
    when 'vagrant'
      p = get_vagrant_instance_path(kitchen_instance_file)
      puts "Stopping Vagrant instance at path #{p}"
      Dir.chdir(p) do
        system('vagrant halt --force')
      end
    end
  end

end

ManageInstance.start(ARGV)
