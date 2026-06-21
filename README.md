# Terraform Azure Debian VM

Deploy a Debian 13 (Trixie) virtual machine in Azure using Terraform.

This project provisions:

- Resource Group
- Virtual Network + Subnet
- Network Security Group (SSH + HTTP open)
- Public IP
- Linux VM (Debian 13 Gen2) with Apache2 installed via cloud-init

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ~> 1.15 (latest stable recommended)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (recommended)
- An Azure subscription

## Authentication

The configuration uses service principal credentials via variables.

1. Create a service principal (or use your own):

   ```bash
   az ad sp create-for-rbac --name tf-sp --role Contributor --scopes /subscriptions/<SUBSCRIPTION_ID>
   ```

2. Fill in the values in `terraform.tfvars`:
   - `azure-tenant-id`
   - `azure-subscription-id`
   - `azure-client-id`
   - `azure-client-secret`

Alternative (recommended for interactive use): use `az login` and authenticate via the Azure provider (remove or comment the explicit credentials and let the provider use CLI / Managed Identity).

## Usage

```bash
# 1. Initialize Terraform
terraform init

# 2. Review the planned changes
terraform plan

# 3. Deploy the VM
terraform apply
```

After `apply` succeeds, Terraform will output:

- VM name
- Public IP address
- Admin username
- Admin password (marked sensitive)

## Connect to the VM

```bash
ssh tfadmin@<PUBLIC_IP>
```

Enter the password shown in the Terraform output (or retrieve it with `terraform output -raw linux_vm_admin_password`).

Once connected:

```bash
# Test the web server
curl http://localhost
```

The VM serves a simple "Azure Virtual Machine deployed with Terraform" page on port 80.

## Cleanup

```bash
# Recommended: see what will be deleted first
terraform plan -destroy

terraform destroy
```

> **Note**: See the [Troubleshooting](#troubleshooting---destroy-errors) section below if you get errors about resources still in use (very common with Bastion, Firewall, etc.).

## Troubleshooting - Destroy errors

### "InUseVirtualNetworkCannotBeDeleted" / VNet cannot be deleted

This error usually happens because **another Azure resource** (not managed by this Terraform project) is still attached to the Virtual Network.

Common cause in this project: **Azure Bastion** was created (manually via portal or another process).

Example error:
> Virtual network ... cannot be deleted because it is in use by the following resources: .../bastionHosts/linux-iac-test-dev-vnet-bastion

**Solution:**

1. Delete the Bastion first:

   ```bash
   # Confirm it exists
   az network bastion list \
     --resource-group linux-iac-test-dev-rg \
     --output table

   # Delete the Bastion (use the exact name from your error)
   az network bastion delete \
     --resource-group linux-iac-test-dev-rg \
     --name linux-iac-test-dev-vnet-bastion
   ```

2. Once the Bastion is deleted, re-run destroy:

   ```bash
   terraform destroy
   ```

If the destroy was partially completed, Terraform may still have the VNet in its state. Running `terraform destroy` again after removing the Bastion will clean it up.

### Other resources blocking deletion

- Azure Firewall
- Application Gateway / WAF
- Private Endpoints
- VPN/ExpressRoute gateways
- Any manually created subnets (especially `AzureBastionSubnet`, `AzureFirewallSubnet`, `GatewaySubnet`)

**Prevention:**
- Do not create Azure networking services manually on VNets managed by Terraform.
- If you need Bastion, add an `azurerm_bastion_host` resource to this project so Terraform manages its full lifecycle.
- For learning/experiments, use a dedicated resource group or a throwaway subscription.

### Force cleanup (last resort)

If you just want to remove everything quickly:

```bash
# Remove VNet from Terraform state (it will no longer be managed)
terraform state rm azurerm_virtual_network.network-vnet

# Then delete the whole resource group from Azure
az group delete --name linux-iac-test-dev-rg --yes --no-wait
```

## Image Details

- Publisher: `Debian`
- Offer: `debian-13`
- SKU: `13-gen2` (Gen2 recommended)
- Version: `latest`

To use a different Debian SKU, edit the `source_image_reference` block in [linux-vm-main.tf](linux-vm-main.tf).

---

Originally based on: https://gmusumeci.medium.com/how-to-deploy-an-ubuntu-linux-vm-in-azure-using-terraform-d523731c39d3
