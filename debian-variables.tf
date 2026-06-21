######################
## Debian Variables ##
######################

variable "linux_vm_image_publisher" {
  type        = string
  description = "Virtual machine source image publisher"
  default     = "Debian"
}

variable "linux_vm_image_offer" {
  type        = string
  description = "Virtual machine source image offer"
  default     = "debian-13"
}

variable "debian_13_sku" {
  type        = string
  description = "SKU for Debian 13 (Trixie) - recommended Gen2"
  default     = "13-gen2"
}

variable "debian_13_sku_v1" {
  type        = string
  description = "SKU for Debian 13 (Trixie) Gen1 / compatibility"
  default     = "13"
}
