variable "project_name" {
  type        = string
  default     = "mbv"
  description = "Project name"
}

variable "key_pair" {
  type        = string
  default     = "mbv-key"
  description = "Key pair Name"
}

###########################################################################################
###################################### Subnet, SG #########################################
###########################################################################################

variable "public_subnet_id_01" {
  type        = string
  description = "public_subnet_id_01"
}

variable "security_group_id" {
  type        = string
  description = "security_group_id"
}

