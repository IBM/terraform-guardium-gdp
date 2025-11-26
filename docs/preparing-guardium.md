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

### 4. Configure SFTP for Universal Connector CSV Upload (CLI User)

For Universal Connector modules that upload CSV profile files, you need to configure SFTP access for the CLI user. This is required because:
- The CLI user has a restricted shell that only allows Guardium CLI commands
- Terraform needs to upload CSV files via SFTP (not SCP)
- The files must be accessible to both the CLI user (for upload) and the Guardium API (for import)

#### Step 1: Configure SSH for SFTP-only Access

SSH into your Guardium server as CLI user and configure SFTP:

```bash
# SSH as CLI user
ssh cli@your-guardium-server

# Edit SSH configuration using grdapi
grdapi edit_file_content file_name=/etc/ssh/sshd_config
```

Add the following configuration at the end of the file:

```
Match User cli
  ForceCommand internal-sftp
  ChrootDirectory /var/IBM/Guardium/file-server
```

**Important Notes:**
- `ForceCommand internal-sftp` restricts the CLI user to SFTP-only access (no shell commands)
- `ChrootDirectory` restricts the CLI user's view to `/var/IBM/Guardium/file-server`
- From the CLI user's perspective, `/upload` maps to `/var/IBM/Guardium/file-server/upload` on the filesystem

#### Step 2: Set Correct Permissions for Chroot Directory

Use grdapi commands to set permissions (no root access required):

```bash
# Set ownership of chroot directory to root
grdapi run_command command="chown root:root /var/IBM/Guardium/file-server"

# Verify the upload directory exists and has correct permissions
grdapi run_command command="ls -ld /var/IBM/Guardium/file-server/upload"
# Should show: drwxrwxr-x 2 tomcat cli
```

#### Step 3: Restart SSH Service

```bash
# Restart SSH to apply changes
grdapi restart_sshd
```

#### Step 4: Add Your Public Key to CLI User

```bash
# Add your public key to CLI user's authorized_keys
# Replace with your actual public key
grdapi add_ssh_pubkey user=cli pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC..."
```

#### Step 5: Test SFTP Access

From your local machine, test SFTP access:

```bash
# Test SFTP connection
sftp -i ~/.ssh/guardium_key cli@your-guardium-server

# Once connected, you should see the chroot directory
# Try listing files (should show 'upload' directory)
sftp> ls
upload

# Try uploading a test file
sftp> put test.csv /upload/test.csv

# Exit
sftp> bye
```

#### Step 6: Verify File Permissions

Verify the uploaded file has correct ownership using grdapi:

```bash
# Still connected as CLI user, verify file ownership
grdapi run_command command="ls -l /var/IBM/Guardium/file-server/upload/test.csv"
# Should show: -rw-r--r-- 1 cli cli
```

#### Terraform Configuration

When using Universal Connector modules with CLI user, configure your `terraform.tfvars`:

```hcl
# SSH Configuration for CLI user
gdp_ssh_username = "cli"
gdp_ssh_privatekeypath = "~/.ssh/guardium_key"

# Directory Configuration
# For CLI user with chroot: use /upload (chroot path)
profile_upload_directory = "/upload"

# For Guardium API: use full filesystem path
profile_api_directory = "/var/IBM/Guardium/file-server/upload"
```

**Path Mapping Explanation:**
- **CLI User (SFTP upload)**: Uses `/upload` because of chroot at `/var/IBM/Guardium/file-server`
- **Guardium API (file import)**: Uses `/var/IBM/Guardium/file-server/upload` (full filesystem path)
- Both paths point to the same physical location on disk

#### Alternative: Using Root User (Not Recommended)

If you prefer to use the root user instead of CLI user (not recommended for security reasons):

```hcl
# SSH Configuration for root user
gdp_ssh_username = "root"
gdp_ssh_privatekeypath = "~/.ssh/guardium_key"

# Directory Configuration (same path for both)
profile_upload_directory = "/var/IBM/Guardium/file-server/upload"
profile_api_directory = "/var/IBM/Guardium/file-server/upload"
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

### SFTP/SCP Issues for Universal Connector

If you encounter errors when uploading CSV files:

**Error: "subsystem request failed on channel 0"**
- This means SCP is being used but the CLI user is configured for SFTP-only
- Solution: Ensure your Terraform module uses SFTP (not SCP) for file upload
- The `connect-datasource-to-uc` module uses `local-exec` provisioner with SFTP command

**Error: "Permission denied" when uploading files**
- Check that your public key is added to CLI user's authorized_keys:
  ```bash
  grdapi add_ssh_pubkey user=cli pubkey="your-public-key"
  ```
- Verify SSH configuration has the Match directive for CLI user
- Test SFTP access manually: `sftp -i ~/.ssh/guardium_key cli@your-guardium-server`

**Error: "Couldn't canonicalize: No such file or directory"**
- The upload directory doesn't exist or isn't accessible
- Verify: `ls -ld /var/IBM/Guardium/file-server/upload` (should exist)
- Check chroot directory ownership: `ls -ld /var/IBM/Guardium/file-server` (should be `root:root`)

**Error: "Failed to import profiles" in Guardium API**
- The file path mismatch between SFTP upload and API read
- Ensure `profile_upload_directory` uses chroot path (e.g., `/upload`)
- Ensure `profile_api_directory` uses full filesystem path (e.g., `/var/IBM/Guardium/file-server/upload`)

**Files uploaded but have wrong ownership**
- Files should be owned by `cli:cli` when uploaded via CLI user
- Check: `ls -l /var/IBM/Guardium/file-server/upload/*.csv`
- If ownership is wrong, verify you're using CLI user (not root) for upload

**Testing SFTP Configuration**

To verify your SFTP setup is working correctly:

```bash
# 1. Test SFTP connection
sftp -i ~/.ssh/guardium_key cli@your-guardium-server

# 2. List files (should see 'upload' directory)
sftp> ls

# 3. Upload a test file
sftp> put test.csv /upload/test.csv

# 4. Exit SFTP
sftp> bye

# 5. Verify file using grdapi (no root access needed)
ssh cli@your-guardium-server
grdapi run_command command="ls -l /var/IBM/Guardium/file-server/upload/test.csv"
# Should show: -rw-r--r-- 1 cli cli

# 6. Clean up test file using grdapi
grdapi run_command command="rm /var/IBM/Guardium/file-server/upload/test.csv"
```
