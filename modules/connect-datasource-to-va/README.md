# Connect Datasource to GDP Module

This Terraform module registers a data source with Guardium Data Protection using the official Guardium provider and configures vulnerability assessment for the data source.

## Features

- Authenticates with Guardium Data Protection using the official provider
- Registers a new data source (e.g., PostgreSQL database) using the Guardium API
- Configures vulnerability assessment with customizable schedule
- Sets up email notifications for assessment results
- Supports tagging of data sources

## Prerequisites

- Guardium Data Protection instance with API access (v9.5 or later)
- API credentials with appropriate permissions
- Network connectivity to the Guardium instance
- Terraform with the Guardium Data Protection provider configured

## Provider Configuration

Before using this module, you need to configure Terraform to access the private registry:

1. Create a `~/.terraformrc` file with the following content:
```
provider_installation {
  network_mirror {
    url = "https://na.artifactory.swg-devops.com/artifactory/api/terraform/sec-guardium-next-gen-terraform-local/providers/"
    include = ["na.artifactory.swg-devops.com/*/*"]
  }
  direct {
    exclude = ["na.artifactory.swg-devops.com/*/*"]
  }
}

credentials "na.artifactory.swg-devops.com" {
  token = "YOUR_ARTIFACTORY_API_TOKEN"
}
```

2. Set the environment variables for provider authentication:
```bash
export GUARDIUM_USERNAME="your_username"
export GUARDIUM_PASSWORD="your_password"
export GUARDIUM_HOST="guardium.example.com"
export GUARDIUM_PORT="8443"
export GUARDIUM_CLIENT_ID="client1"
export GUARDIUM_CLIENT_SECRET="your_client_secret"
```

3. Configure the provider in your Terraform configuration:
```hcl
terraform {
  required_providers {
    guardium-data-protection = {
      source = "na.artifactory.swg-devops.com/ibm/guardium-data-protection"
    }
  }
}
```

## Usage

```hcl
module "connect_datasource" {
  source = "../../modules/vulnerability-assessment/connect-datasource-to-gdp"

  # Guardium Connection
  gdp_server            = "guardium.example.com"
  gdp_port              = "8443"
  gdp_username          = "api_user"
  gdp_password          = "api_password"
  client_id             = "client1"
  client_secret         = "client_secret_value"

  # Data Source Details
  datasource_name        = "postgres-prod-db"
  datasource_hostname    = "postgres.example.com"
  datasource_port        = 5432
  datasource_database    = "mydb"
  datasource_type        = "PostgreSQL"
  datasource_description = "Production PostgreSQL database"
  application            = "Security Assessment"  # Must be one of the valid application types
  severity_level         = "MED"  # Must be one of: LOW, NONE, MED, HIGH
  
  # Connection Options
  save_password         = true
  use_ssl               = true
  import_server_ssl_cert = true
  service_name          = ""  # Required for Oracle, Informix, Db2, and IBM i
  shared_datasource     = "Not Shared"
  connection_properties = "charSet=utf8"
  compatibility_mode    = "Default"
  custom_url            = ""
  
  # External Password Management (if needed)
  use_external_password = false
  external_password_type_name = ""
  
  # CyberArk Integration (if needed)
  cyberark_config_name  = ""
  cyberark_object_name  = ""
  
  # HashiCorp Vault Integration (if needed)
  hashicorp_config_name = ""
  hashicorp_path        = ""
  hashicorp_role        = ""
  hashicorp_child_namespace = ""
  
  # AWS Integration (if needed)
  aws_secrets_manager_config_name = ""
  region                = ""
  secret_name           = ""
  
  # Authentication Options
  use_kerberos          = false
  kerberos_config_name  = ""
  use_ldap              = false

  # Connection Credentials
  connection_username = "sqlguard"
  connection_password = "sqlguard_password"

  # Vulnerability Assessment Configuration
  enable_vulnerability_assessment = true
  assessment_schedule             = "weekly"
  assessment_day                  = "Monday"
  assessment_time                 = "02:00"

  # Notification Configuration
  enable_notifications = true
  notification_emails  = ["security@example.com", "dba@example.com"]
  notification_severity = "HIGH"  # Must be one of: LOW, NONE, MED, HIGH

  # Tags
  tags = {
    Environment = "Production"
    Owner       = "Database Team"
    Application = "Customer Portal"
  }
}
```

## How It Works

1. **Authentication**: The module authenticates with the Guardium API using the official provider.
2. **Data Source Registration**: It registers the data source using the Guardium API endpoint `/restAPI/datasource`.
3. **VA Configuration**: If enabled, it configures vulnerability assessment with the specified schedule.
4. **Notification Setup**: If enabled, it configures email notifications for assessment results.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| guardium-data-protection | latest |
| null | >= 3.0.0 |
| local | >= 2.0.0 |

## Inputs

### Guardium Connection

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| gdp_server | Hostname or IP of the Guardium server | `string` | n/a | yes |
| gdp_port | Port of the Guardium server | `string` | `"8443"` | no |
| gdp_username | Username for Guardium API authentication | `string` | n/a | yes |
| gdp_password | Password for Guardium API authentication | `string` | n/a | yes |
| client_id | Client ID for OAuth authentication | `string` | `"client1"` | no |
| client_secret | Client secret for OAuth authentication | `string` | n/a | yes |
| gdp_mu_host | Comma-separated list of Managed Units | `string` | `""` | no |

### Data Source Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| datasource_name | Required. A unique name for the datasource | `string` | n/a | yes |
| datasource_description | Description of the datasource | `string` | `"PostgreSQL data source onboarded via Terraform"` | no |
| datasource_type | Required. The type of datasource | `string` | `"PostgreSQL"` | no |
| datasource_hostname | Host name or IP address of the database | `string` | n/a | yes |
| datasource_port | Database port number | `number` | `5432` | no |
| datasource_database | Database name or schema name | `string` | n/a | yes |
| application | Required. Application type. Valid values: Application User Translation, Audit Task, Big Data Intelligence, Change Audit System, Classifier, Custom Domain, Database Analyzer, Monitor Values, Security Assessment, Stap Verification | `string` | `"Security Assessment"` | no |
| severity_level | Severity classification for the datasource. Valid values: LOW, NONE, MED, HIGH | `string` | `"MED"` | no |

### Connection Options

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| save_password | Save and encrypt database credentials | `bool` | `true` | no |
| use_ssl | Enable to use SSL authentication | `bool` | `false` | no |
| import_server_ssl_cert | Whether to import the server SSL certificate | `bool` | `false` | no |
| service_name | Required for Oracle, Informix, Db2, and IBM i | `string` | `""` | no |
| shared_datasource | Whether to share the datasource | `string` | `"Not Shared"` | no |
| connection_properties | Additional JDBC connection properties | `string` | `""` | no |
| compatibility_mode | Compatibility mode for monitoring | `string` | `"Default"` | no |
| custom_url | Custom connection string | `string` | `""` | no |

### External Password Management

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| use_external_password | Enable external password management | `bool` | `false` | no |
| external_password_type_name | External password type | `string` | `""` | no |
| cyberark_config_name | CyberArk configuration name | `string` | `""` | no |
| cyberark_object_name | CyberArk object name | `string` | `""` | no |
| hashicorp_config_name | HashiCorp configuration name | `string` | `""` | no |
| hashicorp_path | HashiCorp path | `string` | `""` | no |
| hashicorp_role | HashiCorp role | `string` | `""` | no |
| hashicorp_child_namespace | HashiCorp child namespace | `string` | `""` | no |
| aws_secrets_manager_config_name | AWS Secrets Manager config name | `string` | `""` | no |
| region | AWS region | `string` | `""` | no |
| secret_name | Secret name | `string` | `""` | no |

### Authentication Options

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| use_kerberos | Enable Kerberos authentication | `bool` | `false` | no |
| kerberos_config_name | Kerberos configuration name | `string` | `""` | no |
| use_ldap | Enable LDAP | `bool` | `false` | no |
| connection_username | Database user name | `string` | `"sqlguard"` | no |
| connection_password | Database user password | `string` | n/a | yes |

### Vulnerability Assessment Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_vulnerability_assessment | Enable vulnerability assessment | `bool` | `true` | no |
| assessment_schedule | Schedule for assessments | `string` | `"weekly"` | no |
| assessment_day | Day to run the assessment | `string` | `"Monday"` | no |
| assessment_time | Time to run the assessment | `string` | `"02:00"` | no |

### Notification Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_notifications | Enable notifications | `bool` | `true` | no |
| notification_emails | Email addresses to notify | `list(string)` | `[]` | no |
| notification_severity | Minimum severity level for notifications. Valid values: LOW, NONE, MED, HIGH | `string` | `"HIGH"` | no |
| tags | Tags to apply to the data source | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| datasource_name | Name of the registered data source |
| datasource_type | Type of the registered data source |
| datasource_hostname | Hostname of the registered data source |
| datasource_port | Port of the registered data source |
| vulnerability_assessment_enabled | Whether vulnerability assessment is enabled |
| assessment_schedule | Schedule for vulnerability assessments |
| notifications_enabled | Whether notifications are enabled |
| notification_recipients | Email addresses that will receive notifications |
| notification_severity | Minimum severity level for notifications |
| guardium_server | Hostname of the Guardium Data Protection server |
| access_token | Access token for Guardium API (sensitive) |

## Notes

- The Guardium API credentials are sensitive and should be handled securely (e.g., using Terraform variables or environment variables).
- The module uses the official Guardium Data Protection provider for authentication and the Guardium API for data source registration.
- For vulnerability assessment and notification configuration, the module uses the Guardium API endpoints.
- This module requires Guardium Data Protection v9.5 or later.
- For valid values of `datasource_type` and other parameters with constant value lists, you can run the command: `grdapi create_datasource --get_param_values=<param-name>`
- The `application` parameter must be one of: Application User Translation, Audit Task, Big Data Intelligence, Change Audit System, Classifier, Custom Domain, Database Analyzer, Monitor Values, Security Assessment, Stap Verification.
- The `severity_level` and `notification_severity` parameters must be one of: LOW, NONE, MED, HIGH.