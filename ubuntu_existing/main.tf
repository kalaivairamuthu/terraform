resource "null_resource" "web" {
  connection {
    user = "ubuntu"
    password = var.password
    //private_key = var.key_name
    agent = false
    host = var.public_ip
  }

  provisioner "file" {
    source = "install_arc_agent.sh"
    destination = "/tmp/install_arc_agent.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y python-ctypes",
      "sudo chmod +x /tmp/install_arc_agent.sh",
      "/tmp/install_arc_agent.sh",
    ]
  }
  provisioner "file" {
    source = "log_analytics_agent.sh"
    destination = "/tmp/log_analytics_agent.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/log_analytics_agent.sh",
      "/tmp/log_analytics_agent.sh",
    ]
  }

}

resource "local_file" "install_arc_agent_sh" {
  content = templatefile("install_arc_agent.sh.tmpl", {
    resourceGroup = var.azure_resource_group
    location = var.azure_location
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
    subscription_id = var.subscription_id
  }
  )
  filename = "install_arc_agent.sh"
}

resource "local_file" "log_analytics_agent_sh" {
  content = templatefile("log_analytics_agent.sh.tmpl", {
    Workspace_Id = var.Workspace_Id
    Workspace_Key = var.Workspace_Key
  }
  )
  filename = "log_analytics_agent.sh"
}



// A variable for extracting the external ip of the instance
output "ip" {
  value = var.public_ip
}

