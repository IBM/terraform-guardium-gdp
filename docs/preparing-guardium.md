# Preparing Guardium Data Protection for Terraform Integration

This document outlines the necessary manual configurations required on your Guardium Data Protection instance before using the Terraform modules in this repository.

**Supported Versions:** These modules require IBM Guardium Data Protection (GDP) version **12.2.1 and above**.

## Prerequisites

- Access to a Guardium Data Protection instance (version 12.2.1 or above)
- Administrator credentials for the Guardium web interface
- CLI access to the Guardium appliance for OAuth client registration

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

## Configuration Complete

Once you have completed the above steps, you're ready to use the Terraform modules. The modules will use API-based upload to deploy Universal Connector profiles to your Guardium instance.

## Troubleshooting

### OAuth Client Registration Issues

If you encounter errors when registering the OAuth client:

1. Ensure you're in CLI mode (`ssh cli`)
2. Check that you have the necessary permissions
3. Verify the syntax of the `grdapi` command

### AWS Credential Issues

If the Universal Connector can't connect to AWS:

1. Verify that the AWS credentials have the necessary permissions for SQS
2. Check that the credential name in Guardium matches the one specified in your Terraform configuration
3. Ensure the AWS region in your Terraform configuration matches the region where your resources are located

### API Connection Issues

If you encounter errors when connecting to the Guardium API:

**Error: "Failed to authenticate with Guardium API"**
- Verify that the OAuth client is properly registered using `grdapi register_oauth_client`
- Check that `gdp_client_id` and `gdp_client_secret` are correct
- Ensure the Guardium API is accessible from your Terraform execution environment

**Error: "Connection timeout"**
- Check network connectivity to the Guardium server
- Verify firewall rules allow HTTPS (port 8443) from your Terraform environment
- Confirm the Guardium host address is correct

**Error: "Failed to import profiles"**
- Verify the OAuth client has appropriate permissions
- Check Guardium logs for detailed error messages
- Ensure the Universal Connector profile format is correct

## Additional Resources

- [IBM Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Guardium REST API Documentation](https://www.ibm.com/docs/en/guardium/12.2?topic=api-guardium-rest)
- [Universal Connector Guide](https://www.ibm.com/docs/en/guardium/12.2?topic=connectors-universal-connector)
