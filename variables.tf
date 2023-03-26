variable "vpccidr" {
  type = string 
  default = "10.192.0.0/16"
}

variable "publiccidr1" {
  type = string 
  default = "10.192.10.0/24"
}
variable "publiccidr2" {
  type = string 
  default = "10.192.11.0/24"
}
variable "privatecidr1" {
  type = string 
  default = "10.192.20.0/24"
}
variable "privatecidr2" {
  type = string 
  default = "10.192.21.0/24"
}

