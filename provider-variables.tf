################################
## Azure Provider - Variables ##
################################

# Azure authentication variables

variable "azure-subscription-id" {
  type        = string
  description = "Azure Subscription ID. Leave empty to use Azure CLI login or other default credentials."
  default     = ""
}

variable "azure-client-id" {
  type        = string
  description = "Azure Client ID (for service principal). Leave empty for az login / Managed Identity."
  default     = ""
}

variable "azure-client-secret" {
  type        = string
  description = "Azure Client Secret (for service principal). Leave empty for az login / Managed Identity."
  default     = ""
  sensitive   = true
}

variable "azure-tenant-id" {
  type        = string
  description = "Azure Tenant ID. Leave empty for az login / Managed Identity."
  default     = ""
}
