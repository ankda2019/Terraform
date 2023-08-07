#This Terraform script is designed to create a virtual machine running Windows Server 2019 on the Microsoft Azure cloud platform. To ensure secure access and authorization with my Azure account, I have utilized a separate Terraform configuration file named "provider.tf" to configure the necessary provider settings.

To use this script successfully, you need to update specific fields in the code to align with the details of your Microsoft Azure account. By doing so, you can effectively deploy a Windows Server 2019 virtual machine with the desired configurations tailored to your requirements:

You can modify the username and password for the virtual machine on line numbers 123 and 124. Simply make the necessary changes to these lines to set the desired username and password for the VM.

========================================================================================================================================

Linux Virtual Machine Script:

In this script, I used tls_private_key and local_file modules.

tls_private_key module generates a secure private key and encodes it in PEM (RFC 1421) and OpenSSH PEM (RFC 4716) formats.
More Details: https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key

local_file generates a local file with the given content. In the script, this module will help store the private key's content locally.
More Details: https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file.html









