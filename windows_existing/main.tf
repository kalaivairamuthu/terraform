resource "local_file" "install_arc_agent_ps1" {
  content = templatefile("install_arc_agent.ps1.tmpl", {
    resourceGroup            = var.resourceGroup
    location                 = var.location
    admin_user               = var.admin_user
    subId                    = var.subId
    servicePrincipalAppId    = var.servicePrincipalAppId
    servicePrincipalSecret   = var.servicePrincipalSecret
    servicePrincipalTenantId = var.servicePrincipalTenantId
    }
  )
  filename = "install_arc_agent.ps1"
}

resource "local_file" "install_mma_agent_ps1" {
  content = templatefile("install_mma_agent.ps1.tmpl", {
    workspaceId             = var.workspaceId
    workspaceKey            = var.workspaceKey
    }
  )
  filename = "install_mma_agent.ps1"
}

resource "null_resource" "web" {
  provisioner "file" {
    source      = "install_arc_agent.ps1"
    destination = "C:/tmp/install_arc_agent.ps1"

    connection {
      type     = "winrm"
      host     = var.public_ip
      port     = 5985
      user     = var.admin_user
      password = var.admin_password
      https    = false
      insecure = true
      timeout  = "10m"
    }
  }

  provisioner "file" {
    source      = "install_mma_agent.ps1"
    destination = "C:/tmp/install_mma_agent.ps1"

    connection {
      type     = "winrm"
      host     = var.public_ip
      port     = 5985
      user     = var.admin_user
      password = var.admin_password
      https    = false
      insecure = true
      timeout  = "10m"
    }
  }



  provisioner "remote-exec" {
    inline = [
      "powershell.exe -File C://tmp//install_arc_agent.ps1"
    ]

    connection {
      type     = "winrm"
      host     = var.public_ip
      port     = 5985
      user     = var.admin_user
      password = var.admin_password
      https    = false
      insecure = true
      timeout  = "10m"
    }

  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -File C://tmp//install_mma_agent.ps1"
    ]

    connection {
      type     = "winrm"
      host     = var.public_ip
      port     = 5985
      user     = var.admin_user
      password = var.admin_password
      https    = false
      insecure = true
      timeout  = "10m"
    }

  }
}
output "public_ip" {
  value = "var.public_ip"
}
