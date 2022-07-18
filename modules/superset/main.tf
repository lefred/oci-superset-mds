## DATASOURCE
# Init Script Files

locals {
  superset_script            = "~/install_superset.sh"
  security_script            = "~/configure_local_security.sh"
  create_superset_db         = "~/create_superset_db.sh"
  superset_service_script    = "~/superset.service"
  superset_httpd_script      = "~/25-superset.conf"
  superset_sepolicy_script   = "~/superset.te"
}

data "template_file" "install_superset_httpd" {
  template = file("${path.module}/scripts/25-superset.conf")
}

data "template_file" "install_superset_policy" {
  template = file("${path.module}/scripts/superset.te")
}

data "template_file" "install_superset_service" {
  template = file("${path.module}/scripts/superset.service")
}

data "template_file" "install_superset" {
  template = file("${path.module}/scripts/install_superset.sh")
  vars = {
    load_samples = var.load_samples
    admin_password    = var.admin_password
    admin_username    = var.admin_username
    mds_ip            = var.mds_ip
    superset_schema   = var.superset_schema
    superset_admin_username = var.superset_admin_username
    superset_admin_password = var.superset_admin_password
  }
}

data "template_file" "configure_local_security" {
  template = file("${path.module}/scripts/configure_local_security.sh")
}

data "template_file" "create_superset_db" {
  template = file("${path.module}/scripts/create_superset_db.sh")
  vars = {
    admin_password    = var.admin_password
    admin_username    = var.admin_username
    superset_password = var.superset_password
    mds_ip            = var.mds_ip
    superset_name     = var.superset_name
    superset_schema   = var.superset_schema
    mysql_version     = var.mysql_version
    user              = var.vm_user
  }
}


resource "oci_core_instance" "Superset" {
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.display_name}"
  shape               = var.shape
  availability_domain = var.availability_domains[0]

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.flex_shape_memory
      ocpus = var.flex_shape_ocpus
    }
  }


  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "${var.label_prefix}${var.display_name}"
    assign_public_ip = var.assign_public_ip
    hostname_label   = "${var.display_name}"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  provisioner "file" {
    content     = data.template_file.install_superset.rendered
    destination = local.superset_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content     = data.template_file.install_superset_service.rendered
    destination = local.superset_service_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content     = data.template_file.install_superset_httpd.rendered
    destination = local.superset_httpd_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content     = data.template_file.install_superset_policy.rendered
    destination = local.superset_sepolicy_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }


  provisioner "file" {
    content     = data.template_file.configure_local_security.rendered
    destination = local.security_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

 provisioner "file" {
    content     = data.template_file.create_superset_db.rendered
    destination = local.create_superset_db

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }


   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }

    inline = [
       "chmod +x ${local.security_script}",
       "sudo ${local.security_script}",
       "chmod +x ${local.create_superset_db}",
       "sudo ${local.create_superset_db}",
       "chmod +x ${local.superset_script}",
       "${local.superset_script}"
    ]

   }

  timeouts {
    create = "10m"

  }
}
