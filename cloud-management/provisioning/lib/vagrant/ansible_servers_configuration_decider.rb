class AnsibleServersConfigurationDecider
  # @param [ServicesList] servers
  def initialize(servers:)
    @servers = servers
  end

  def decide(vagrant_context:)
    ansible_host_vars = {}

    @servers.all.each do |server|
      ansible_host_vars[server.name] = {
        'ip' => server.ip
      }
    end

    vagrant_context.vm.provision 'ansible' do |ansible|
      ansible.playbook = File.join(File.dirname(__FILE__), 'inventory-playbook.yml')
      ansible.host_vars = ansible_host_vars
      ansible.groups = {
        'etcd' => @servers.names_for_tag('etcd'),
        'kube-master' => @servers.names_for_tag('kube-master'),
        'kube-node' => @servers.names_for_tag('kube-node'),
        'k8s-cluster:children' => ['kube-master', 'kube-node']
      }
      ansible.become = true
      ansible.become_user = 'root'
      ansible.limit = 'all'
      ansible.host_key_checking = false
    end
  end
end