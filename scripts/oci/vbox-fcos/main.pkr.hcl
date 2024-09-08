packer {
	required_plugins {
		virtualbox = {
			version = "~> 1"
			source = "github.com/hashicorp/virtualbox"
		}
	}
}

source "virtualbox-ovf" "fcos-host" {
	vm_name = var.template_name
	source_path = local.ova_url
	checksum = var.ova_checksum
	output_directory = "${local.build_directory}/${var.template_name}-vbox"

	headless = local.headless

	http_directory = local.http_directory
	vboxmanage = [
		["modifyvm", "{{.Name}}", "--memory", "${local.memory}"],
		["modifyvm", "{{.Name}}", "--cpus", "${local.cpus}"],
		["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
		["guestproperty", "set", "{{.Name}}", "/Ignition/Config", "${local.ignition_source}"],
	]

	ssh_timeout = local.ssh_timeout
	ssh_username = var.username
	ssh_password = var.password

	shutdown_command = "echo '${var.username}' | sudo -S shutdown -P now"
}

build {
	sources = ["sources.virtualbox-ovf.fcos-host"]
}
