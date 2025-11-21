# Preparing Guardium Data Protection for Terraform Integration

This document outlines the necessary manual configurations required on your Guardium Data Protection instance before using the Terraform modules in this repository.

## Prerequisites

- Access to a Guardium Data Protection instance
- Administrator credentials for the Guardium web interface
- SSH access to the Guardium appliance

## Configuration Steps

### 1. Enable OAuth Client for REST API Access

The modules require API access to Guardium. You need to register an OAuth client using the Guardium command-line interface:

```bash
# SSH into your Guardium Central Manager
ssh cli@your-guardium-server

# Register the OAuth client
# Replace "test1" with your desired client_id name
grdapi register_oauth_client client_id="test1" grant_types="password" user="admin" password="password" 
```

This command will output a client secret. **Make sure to save this client secret** as you'll need it for the `gdp_client_secret` parameter in your Terraform configuration.

### 2. Configure AWS Credentials in Guardium

1. Log in to your Guardium web interface
2. Navigate to **Universal Connector** → **Credential Management**
3. Click **Add Credential**
4. Select **AWS** as the credential type
5. Enter the following information:
  - **Name**: Enter a name for the credential (use this same name for the `udc_aws_credential` parameter)
  - **Access Key ID**: Your AWS access key with full permissions for SQS (`AmazonSQSFullAccess` policy)
  - **Secret Access Key**: Your AWS secret key
6. Click **Save**

### 3. Enable SSH Access for Terraform

The modules use SSH to upload configuration files to Guardium. You need to:

1. **Create an SSH Key Pair** if you don't already have one:
   ```bash
   # Generate a new SSH key pair
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/guardium_key
   ```

2. **Add Your Public Key to Guardium**:
   ```bash
   # Copy your public key to Guardium
   ssh-copy-id -i ~/.ssh/guardium_key.pub root@guardium-server
   ```

3. **Test SSH Access**:
   ```bash
   ssh -i ~/.ssh/guardium_key root@your-guardium-server
   ```

## Troubleshooting

### OAuth Client Registration Issues

If you encounter errors when registering the OAuth client:

1. Ensure you're in CLI mode (`su cli`)
2. Check that you have the necessary permissions
3. Verify the syntax of the `grdapi` command

### SSH Access Issues

If you're having trouble with SSH access:

1. Verify that SSH access is enabled for the user you're trying to use
2. Check that your public key was properly added to the authorized_keys file
3. Ensure the permissions on the `.ssh` directory and `authorized_keys` file are correct

### AWS Credential Issues

If the Universal Connector can't connect to AWS:

1. Verify that the AWS credentials have the necessary permissions for SQS
2. Check that the credential name in Guardium matches the one specified in your Terraform configuration
3. Ensure the AWS region in your Terraform configuration matches the region where your resources are located
