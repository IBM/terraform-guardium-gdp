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

2. Follow the steps document at [Enabling SSH key pairs for data archive, data export, data mart](https://www.ibm.com/docs/en/gdp/12.x?topic=mdarasb-enabling-ssh-key-pairs-data-archive-data-export-data-mart) to enable data transfer to Central manager.

### 4. Configure Directory for Universal Connector CSV Upload

For Universal Connector modules that upload CSV profile files, you need to ensure the upload directory is accessible. The modules support two configurations:

#### Option 1: Using CLI User (Recommended)

After following the [IBM documentation for enabling SSH key pairs](https://www.ibm.com/docs/en/gdp/12.x?topic=mdarasb-enabling-ssh-key-pairs-data-archive-data-export-data-mart), configure your `terraform.tfvars`:

```hcl
# SSH Configuration for CLI user
gdp_ssh_username = "cli"
gdp_ssh_privatekeypath = "~/.ssh/guardium_key"

# Directory Configuration
# Leave empty to use module defaults (CLI-compatible paths)
profile_upload_directory = ""  # Module default: /upload
profile_api_directory = ""     # Module default: /var/IBM/Guardium/file-server/upload
```

**Default Paths:**
- `profile_upload_directory`: `/upload` (CLI user's chroot-relative path for SFTP upload)
- `profile_api_directory`: `/var/IBM/Guardium/file-server/upload` (Full filesystem path for Guardium API)

#### Option 2: Using Root User (Not Recommended)

If you must use root user, configure your `terraform.tfvars`:

```hcl
# SSH Configuration for root user
gdp_ssh_username = "root"
gdp_ssh_privatekeypath = "~/.ssh/guardium_key"

# Directory Configuration (same path for both when using root)
profile_upload_directory = "/var/IBM/Guardium/file-server/upload"
profile_api_directory = "/var/IBM/Guardium/file-server/upload"
```

**Important Notes:**
- The CLI user option is more secure as it provides restricted access
- The upload directory `/var/IBM/Guardium/file-server/upload` must exist and be writable
- Files uploaded by CLI user will have `cli:cli` ownership
- Files uploaded by root user will have `root:root` ownership

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

### File Upload Issues for Universal Connector

If you encounter errors when uploading CSV files:

**Error: "Permission denied" when uploading files**
- Verify that SSH key pairs are properly configured following the [IBM documentation](https://www.ibm.com/docs/en/gdp/12.x?topic=mdarasb-enabling-ssh-key-pairs-data-archive-data-export-data-mart)
- Check that your public key is added to the user's authorized_keys
- Test SFTP access manually: `sftp -i ~/.ssh/guardium_key <user>@your-guardium-server`

**Error: "Couldn't canonicalize: No such file or directory"**
- The upload directory doesn't exist or isn't accessible
- Verify the directory exists: `/var/IBM/Guardium/file-server/upload`
- Ensure the user has write permissions to the directory

**Error: "Failed to import profiles" in Guardium API**
- Check that `profile_api_directory` points to the correct filesystem path
- For CLI user: Use `/var/IBM/Guardium/file-server/upload` for API directory
- Verify files were successfully uploaded to the directory

**Testing File Upload**

To verify your setup is working correctly:

```bash
# 1. Test SFTP connection
sftp -i ~/.ssh/guardium_key <user>@your-guardium-server

# 2. Try uploading a test file
sftp> put test.csv /var/IBM/Guardium/file-server/upload/test.csv

# 3. Exit SFTP
sftp> bye

# 4. Verify the file was uploaded successfully
# Contact your Guardium administrator to verify file presence and permissions
```
