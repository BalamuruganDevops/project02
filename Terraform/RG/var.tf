variable "location" {
  type = string
  default = "CentralUS"
}

variable "resource_group_name" {
    type = string
    default = "fstudiorg"
}

variable "storage_name" {
    type = string
    default = "fstudiostr"
}

variable "container_name" {
    type = string
    default = "fstudiocon1"
}

variable "storage_blob" {
    type = string
    default = "fstudioblob1"
}

variable "cluster_name" {
    type = string
    default = "fstudiocluster01"
}

variable "agent_count" {
    type = string
    default = "2"
}
variable "client_id" {
    type = string
    default = "f9fab583-23f4-467f-8a48-33938d4c6563"
}
variable "client_secret" {
    type = string
    default = "wr0~hOM_-XNiF0XspsnJ0PE39uRdf-uGxd"
}

variable "appId" {
    type = string
    default = "vmadmin"
}

variable "password" {
    type = string
    default = "April@123456789"
}

variable "dns_prefix" {
    default = "k8stest"
}

variable "mysqlserver" {
    default = "fstusiomysql01"
}




