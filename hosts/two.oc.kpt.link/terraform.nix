{ config, pkgs, ... }:
let
  shared = import ../_modules/terraform.nix;
in
{
  terraform.required_providers.oci = {
    source = "oracle/oci";
    version = "~> 5.0";
  };
  provider.oci = {};
  variable.compartment_ocid = {
    description = "The OCID of the compartment";
    type = "string";
  };
  variable.ssh_source_ip = {
    description = "The source IP for SSH access";
    type = "string";
  };
  data.oci_core_vcns.my_vcns = {
    compartment_id = "\${var.compartment_ocid}";
  };
  data.oci_core_subnets.my_subnets = {
    compartment_id = "\${var.compartment_ocid}";
    vcn_id = "\${data.oci_core_vcns.my_vcns.virtual_networks[0].id}";
  };
  data.oci_core_images.oracle_arm = {
    compartment_id = "\${var.compartment_ocid}";
    operating_system = "Oracle Linux";
    operating_system_version = "9";
    shape = "VM.Standard.A1.Flex";
    sort_by = "TIMECREATED";
    sort_order = "DESC";
  };
  data.oci_identity_availability_domains.ads = {
    compartment_id = "\${var.compartment_ocid}";
  };
  resource.oci_core_instance.two_oc = {
    availability_domain = "\${data.oci_identity_availability_domains.ads.availability_domains[0].name}";
    fault_domain = "FAULT-DOMAIN-2";
    compartment_id = "\${var.compartment_ocid}";
    shape = "VM.Standard.A1.Flex";
    display_name = "two-oc-kpt-link";
    shape_config = {
      ocpus = 1;
      memory_in_gbs = 6;
    };
    source_details = {
      source_id = "\${data.oci_core_images.oracle_arm.images[0].id}";
      source_type = "image";
      boot_volume_size_in_gbs = 50;
    };

    create_vnic_details = {
      subnet_id = "\${data.oci_core_subnets.my_subnets.subnets[0].id}";
      assign_public_ip = true;
      nsg_ids = [ "\${oci_core_network_security_group.ssh_nsg.id}" ];
    };
    metadata = {
      ssh_authorized_keys = shared.sshKey;
    };
  };
  resource.oci_core_network_security_group.ssh_nsg = {
    compartment_id = "\${var.compartment_ocid}";
    vcn_id = "\${data.oci_core_vcns.my_vcns.virtual_networks[0].id}";
    display_name = "allow-ssh-127-two-oc";
  };
  resource.oci_core_network_security_group_security_rule.ssh_rule = {
    network_security_group_id = "\${oci_core_network_security_group.ssh_nsg.id}";
    direction = "INGRESS";
    protocol = "6";
    source = "\${var.ssh_source_ip}";
    source_type = "CIDR_BLOCK";
    tcp_options = {
      destination_port_range = {
        max = 22;
        min = 22;
      };
    };
  };
  resource.oci_core_network_security_group_security_rule.p2p_tcp = {
    network_security_group_id = "\${oci_core_network_security_group.ssh_nsg.id}";
    direction = "INGRESS";
    protocol = "6";
    source = "0.0.0.0/0";
    source_type = "CIDR_BLOCK";
    tcp_options = {
      destination_port_range = { max = 4002; min = 4002; };
    };
  };
  resource.oci_core_network_security_group_security_rule.p2p_udp = {
    network_security_group_id = "\${oci_core_network_security_group.ssh_nsg.id}";
    direction = "INGRESS";
    protocol = "17";
    source = "0.0.0.0/0";
    source_type = "CIDR_BLOCK";
    udp_options = {
      destination_port_range = { max = 4002; min = 4002; };
    };
  };
}
