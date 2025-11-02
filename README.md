# IBM Guardium Data Protection Terraform Module

Terraform module which creates IBM Guardium Data Protection (GDP) integration resources for AWS datastores.

## Scope

This project provides Terraform modules for automating the integration of various AWS data stores with IBM Guardium Data Protection. It enables audit logging, vulnerability assessment, and security monitoring for AWS databases including RDS PostgreSQL, RDS MariaDB, DynamoDB, DocumentDB, and Redshift.

## Related Modules

This module is used by the following higher-level Guardium Terraform modules:

- **[IBM Guardium Datastore Vulnerability Assessment Module](https://registry.terraform.io/modules/IBM/datastore-va/guardium/latest)** - Provides comprehensive vulnerability assessment capabilities for AWS datastores
- **[IBM Guardium Datastore Audit Module](https://registry.terraform.io/modules/IBM/datastore-audit/guardium/latest)** - Provides audit logging and monitoring capabilities for AWS datastores

These modules build upon the foundational integration capabilities provided by this module to deliver complete end-to-end solutions for database security and compliance.

## Usage

### Prerequisites

Before using these modules, ensure you have:

1. **Guardium Data Protection Cluster**: You must have your own Guardium Data Protection (GDP) cluster set up and running.

2. **Guardium Configuration**: Complete the one-time manual configurations on your Guardium Data Protection instance as described in the [Preparing Guardium Documentation](docs/preparing-guardium.md). These configurations include:
    - Enabling OAuth client for REST API access
    - Configuring AWS credentials in Universal Connector
    - Setting up SSH access for Terraform

3. **Terraform Setup**:

   a. **Install Terraform** (version v1.9.8 or later required):
    - For macOS:
      ```bash
      brew install terraform
      ```
    - For Linux (Ubuntu/Debian):
      ```bash
      sudo apt-get update && sudo apt-get install -y software-properties-common
      sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
      sudo apt-get update && sudo apt-get install terraform
      ```
    - For Linux (Amazon Linux/RHEL/CentOS):
      ```bash
      sudo yum install -y yum-utils
      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
      sudo yum -y install terraform
      ```
    - For Windows:
      Download and run the installer from [Terraform Download Page](https://www.terraform.io/downloads)

   b. **Verify Terraform Installation**:
   ```bash
   terraform version
   ```
   Ensure the output shows version v1.9.8 or later.

### Connect Datasource to Universal Connector

Configures AWS datastores for audit logging and integrates with Guardium Universal Connector.

```hcl
module "connect_datasource_to_uc" {
  source = "terraform-ibm-modules/guardium-gdp/ibm//modules/connect-datasource-to-uc"

  # Datastore configuration
  datastore_type = "aws-dynamodb"  # or "aws-documentdb", "aws-mariadb", "aws-postgresql"
  datastore_name = "my-database"
  
  # AWS configuration
  aws_region     = "us-east-1"
  aws_account_id = "123456789012"
  
  # Guardium configuration
  guardium_host     = "guardium.example.com"
  guardium_username = "admin"
  guardium_password = var.guardium_password
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Connect Datasource to Vulnerability Assessment

Configures AWS datastores for vulnerability assessment and integrates with Guardium.

```hcl
module "connect_datasource_to_va" {
  source = "terraform-ibm-modules/guardium-gdp/ibm//modules/connect-datasource-to-va"

  # Datastore configuration
  datastore_type = "aws-rds-postgresql"  # or "aws-dynamodb", "aws-redshift"
  datastore_name = "my-database"
  
  # Database connection details
  db_host     = "mydb.cluster-abc123.us-east-1.rds.amazonaws.com"
  db_port     = 5432
  db_name     = "postgres"
  db_username = "sqlguard"
  db_password = var.db_password
  
  # Guardium configuration
  guardium_host     = "guardium.example.com"
  guardium_username = "admin"
  guardium_password = var.guardium_password
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## High-Level Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│              Guardium Data Protection Terraform Module           │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              │
                ┌─────────────┴─────────────┐
                │                           │
                ▼                           ▼
    ┌───────────────────────┐   ┌───────────────────────┐
    │  Universal Connector  │   │ Vulnerability         │
    │  Integration          │   │ Assessment            │
    │  (Audit Logging)      │   │ Integration           │
    └───────────────────────┘   └───────────────────────┘
                │                           │
                │                           │
                ▼                           ▼
    ┌───────────────────────┐   ┌───────────────────────┐
    │  AWS Datastores       │   │  AWS Datastores       │
    │  - DynamoDB           │   │  - RDS PostgreSQL     │
    │  - DocumentDB         │   │  - DynamoDB           │
    │  - RDS MariaDB        │   │  - Redshift           │
    │  - RDS PostgreSQL     │   │                       │
    └───────────────────────┘   └───────────────────────┘
                │                           │
                └─────────────┬─────────────┘
                              │
                              ▼
                ┌─────────────────────────┐
                │                         │
                │  Guardium Data          │
                │  Protection (GDP)       │
                │                         │
                └─────────────────────────┘
```

This architecture shows how the Terraform module integrates AWS datastores with IBM Guardium Data Protection through two main integration paths:

1. **Universal Connector (UC)**: Provides audit logging and monitoring for AWS datastores
2. **Vulnerability Assessment (VA)**: Enables security scanning and assessment capabilities

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Support

For issues and questions:
- Create an issue in this repository
- Contact the maintainers listed in [MAINTAINERS.md](MAINTAINERS.md)

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

```text
#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#
```

## Authors

Module is maintained by IBM with help from [these awesome contributors](https://github.com/IBM/terraform-guardium-datastore-va/graphs/contributors).
