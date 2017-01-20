#!/usr/bin/env ruby

require "yaml"
require 'aws-sdk'
require 'thor'

class ManageEC2Instance < Thor

  no_commands{
    def get_instance_id(kitchen_instance_file=nil)
      if ! File.exists?(kitchen_instance_file)
        puts "ERROR: Kitchen instance file '#{kitchen_instance_file}' does not exist."
        exit 1
      end
      kitchen_instance = YAML.load(IO.read(kitchen_instance_file))
      kitchen_instance['server_id']
    end
  }    

  desc "start [KITCHEN_INSTANCE_FILE]", "Start instance"
  def start(kitchen_instance_file)
    i = Aws::EC2::Instance.new(get_instance_id(kitchen_instance_file))
    puts "Starting instance #{i.id}"
    i.start
    i.wait_until_running
  end

  desc "stop [KITCHEN_INSTANCE_FILE]", "Stop instance"
  def stop(kitchen_instance_file)
    i = Aws::EC2::Instance.new(get_instance_id(kitchen_instance_file))
    puts "Stopping instance #{i.id}"
    i.stop
    i.wait_until_stopped
  end

  desc "update-hostname [KITCHEN_INSTANCE_FILE]", "Update hostname in kitchen instance file"
  def update_hostname(kitchen_instance_file)
    i = Aws::EC2::Instance.new(get_instance_id(kitchen_instance_file))
    puts "Updating hostname for instance #{i.id} to #{i.public_dns_name}"
    kitchen_instance = YAML.load(IO.read(kitchen_instance_file))
    kitchen_instance['hostname'] = i.public_dns_name
    IO.write(kitchen_instance_file, kitchen_instance.to_yaml)
  end

end

ManageEC2Instance.start(ARGV)
