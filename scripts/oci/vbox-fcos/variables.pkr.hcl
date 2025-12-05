variable "ova_props" {
	type = object({
		release = string
		version = string
		arch = string
	})
	default = {
		release = "stable"
		version = "40.20240808.3.0"
		arch = "x86_64"
	}
}
variable "ova_checksum" {
	type = string
	default = "5336a4efb06cf912a9ad9790b6eba67465d1bea46d701b26bb369df622b107c7"
}
variable "template_name" {
	type = string
	default = "fcos-ansible"
}
variable "ignition_file" {
	type = string
	default = "config.ign"
}

variable "username" {
	type = string
	default = "core"
}
# This would be more reusable as a ssh_key
variable "password" {
	type = string
	default = "confirm"
}

locals {
	ova_url = "https://builds.coreos.fedoraproject.org/prod/streams/${var.ova_props.release}/builds/${var.ova_props.version}/${var.ova_props.arch}/fedora-coreos-${var.ova_props.version}-virtualbox.${var.ova_props.arch}.ova"
	http_directory = "template"
	build_directory = ".build"
	ignition_source = "{\"ignition\":{\"config\":{\"replace\":{\"source\":\"http://{{.HTTPIP}}:{{.HTTPPort}}/${var.ignition_file}\"}},\"version\":\"3.4.0\"}}"
	cpus = 2
	memory = 1024
	headless = false
	ssh_timeout = "45m"
}