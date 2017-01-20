#!/usr/bin/env ruby

require "yaml"
require 'aws-sdk'
require 'thor'

class ManageEC2Instance < Thor

  no_commands{
    def get_instance(kitchen_instance_file=nil)
      if ! File.exists?(kitchen_instance_file)
        puts "ERROR: Kitchen instance file '#{kitchen_instance_file}' does not exist."
        exit 1
      end
      puts "Using kitchen instance file #{kitchen_instance_file}"
      kitchen_instance = YAML.load(IO.read(kitchen_instance_file))
      Aws::EC2::Instance.new(kitchen_instance['server_id'])
    end

    def update_kitchen_instance_file_hostname(kitchen_instance_file=nil, i=nil)
      if i.public_dns_name.empty?
        puts "ERROR: Public DNS Name is not set for instance #{i.id}. Make sure the instance exists and is running."
        puts "Instance #{i.id} is #{i.state.name}"
        exit 1
      end
      puts "Updating hostname for instance #{i.id} to #{i.public_dns_name}"
      kitchen_instance = YAML.load(IO.read(kitchen_instance_file))
      kitchen_instance['hostname'] = i.public_dns_name
      IO.write(kitchen_instance_file, kitchen_instance.to_yaml)
    end
  }    

  desc "status", "Print instance state"
  option :file, :aliases => "-f", :desc => "Specify a kitchen instance file. `.kitchen/default-ubuntu-1610.yml` will be used by default"
  def status
    kitchen_instance_file = options[:file] || '.kitchen/default-ubuntu-1610.yml'
    i = get_instance(kitchen_instance_file)
    puts "Instance #{i.id} is #{i.state.name}"
  end

  desc "start", "Start instance"
  option :file, :aliases => "-f", :desc => "Specify a kitchen instance file. `.kitchen/default-ubuntu-1610.yml` will be used by default"
  def start
    kitchen_instance_file = options[:file] || '.kitchen/default-ubuntu-1610.yml'
    i = get_instance(kitchen_instance_file)
    puts "Starting instance #{i.id}"
    i.start
    i.wait_until_running
    update_kitchen_instance_file_hostname(kitchen_instance_file, i)
  end

  desc "stop", "Stop instance"
  option :file, :aliases => "-f", :desc => "Specify a kitchen instance file. `.kitchen/default-ubuntu-1610.yml` will be used by default"
  def stop
    kitchen_instance_file = options[:file] || '.kitchen/default-ubuntu-1610.yml'
    i = get_instance(kitchen_instance_file)
    puts "Stopping instance #{i.id}"
    i.stop
    i.wait_until_stopped
  end

  desc "update-hostname", "Update hostname in kitchen instance file"
  option :file, :aliases => "-f", :desc => "Specify a kitchen instance file. `.kitchen/default-ubuntu-1610.yml` will be used by default"
  def update_hostname
    kitchen_instance_file = options[:file] || '.kitchen/default-ubuntu-1610.yml'
    i = get_instance(kitchen_instance_file)
    update_kitchen_instance_file_hostname(kitchen_instance_file, i)
  end

end

ManageEC2Instance.start(ARGV)
