require 'json'
require 'ostruct'

class VagrantServerConfigurationDecider
  def initialize(server:)
    @server = server
  end

  def decide(vagrant_context:)
    vagrant_context.vm.define @server.name do |server_config|

      server_config.vm.hostname = @server.name
      server_config.vm.network :private_network, ip: @server.ip

      server_config.vm.provider :virtualbox do |vb|
        vb.name = @server.name
        vb.gui = false

        vb.memory = @server.settings.memory
        vb.cpus = @server.settings.cpus
        vb.linked_clone = true
        disks = 1
        size_in_gb = 10
        disk_controller = "SATA Controller"

        vb.customize ['storagectl', :id, '--name', disk_controller, '--add', 'sata', '--portcount', 8]

        0.upto(disks-1).each do |d|
          disk_name = "disk-#{d}.vdi"
          disk_location = File.join(ENV['WORKING_DIR'],
                                    '.volumes',
                                    @server.name,
                                    disk_name)
          vb.customize ['createmedium', '--filename', disk_location, '--size', 1024*size_in_gb] unless File.exist?(disk_location)
          vb.customize ['storageattach', :id, '--storagectl', disk_controller, '--port', 3+d, '--device', 0, '--type', 'hdd', '--medium', disk_location]
        end
      end
      server_config.vm.provision "shell", inline: "swapoff -a"
    end
  end


  def find_or_create_disk_controller(server_name)
    disk_controllers_table = `VBoxManage showvminfo #{server_name} --machinereadable | grep storagecontroller`
      .split("\n")
      .map { |el| el.split("=") }
    sata_controller_type = disk_controllers_table.find { |el| el[1].include?("IntelAhci") }
    if sata_controller_type
      sata_controller_id = sata_controller_type[0][-1]
      sata_controller_name = disk_controllers_table.find { |el| el[0] == "storagecontrollername#{sata_controller_id}" }[1].gsub("\"", "")
    else
      sata_controller_name = "SATA Controller"
      puts "Creating #{sata_controller_name} on #{server_name}"
      `VBoxManage storagectl #{server_name} --add sata --portcount 8 --name "#{sata_controller_name}"`
    end
    return sata_controller_name
  end

  private :find_or_create_disk_controller
end