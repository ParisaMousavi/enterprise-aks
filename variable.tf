variable "location" {
  type    = string
  default = "westeurope"
}

variable "prefix" {
  type    = string
  default = "proja"
}

variable "stage" {
  type    = string
  default = "dev"
}

variable "name" {
  type    = string
  default = "app"
}

variable "location_shortname" {
  type    = string
  default = "weu"
}

variable "tenant_id" {
  type = string
}

variable "connect_to_arc" {
  type    = bool
  default = true
}

variable "install_arc_monitor" {
  type    = bool
  default = true
}
