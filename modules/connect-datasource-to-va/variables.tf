# Connect Datasource to GDP Module Variables

#------------------------------------------------------------------------------
# Guardium Connection Configuration
#------------------------------------------------------------------------------

variable "gdp_server" {
  description = "The hostname or IP address of the Guardium server"
  type        = string
}

variable "gdp_port" {
  description = "The port of the Guardium server"
  type        = string
  default     = "8443"
}

variable "gdp_username" {
  description = "The username to login to Guardium"
  type        = string
}

variable "gdp_password" {
  description = "The password for logging in to Guardium"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "The client ID used to create the GDP register_oauth_client client_secret"
  type        = string
  default     = "client1"
}

variable "client_secret" {
  description = "The client secret output from grdapi register_oauth_client client_id=client1 grant_types=password"
  type        = string
}


variable "gdp_ssh_username" {
  description = "The SSH user for logging in to Guardium (required for file operations)"
  type        = string
  default     = "root"
}

variable "gdp_ssh_privatekeypath" {
  description = "The path to the SSH private key for logging in to Guardium (not required for VA)"
  type        = string
  default     = ""
}

variable "gdp_mu_host" {
  description = "Comma separated list of Guardium Managed Units to deploy profile"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Vulnerability Assessment Configuration
#------------------------------------------------------------------------------


variable "datasource_name" {
  description = "Required. A unique name for the datasource on the Guardium system"
  type        = string
}

variable "enable_vulnerability_assessment" {
  description = "Whether to enable vulnerability assessment for the data source"
  type        = bool
  default     = true
}

variable "assessment_schedule" {
  description = "Schedule for vulnerability assessments (e.g., daily, weekly, monthly)"
  type        = string
  default     = "weekly"
}

variable "assessment_day" {
  description = "Day to run the assessment (e.g., Monday, 1)"
  type        = string
  default     = "Monday"
}

variable "assessment_time" {
  description = "Time to run the assessment in 24-hour format (e.g., 02:00)"
  type        = string
  default     = "02:00"
}

#------------------------------------------------------------------------------
# Notification Configuration
#------------------------------------------------------------------------------

variable "enable_notifications" {
  description = "Whether to enable notifications for assessment results"
  type        = bool
  default     = true
}

variable "notification_emails" {
  description = "List of email addresses to notify about assessment results"
  type        = list(string)
  default     = []
}

variable "notification_severity" {
  description = "Minimum severity level for notifications (e.g., HIGH, MED, LOW)"
  type        = string
  default     = "HIGH"

  validation {
    condition     = contains(["LOW", "NONE", "MED", "HIGH"], var.notification_severity)
    error_message = "The notification_severity must be one of: LOW, NONE, MED, HIGH."
  }
}

#------------------------------------------------------------------------------
# Payload Configuration
#------------------------------------------------------------------------------

variable "datasource_payload" {
  description = "A JSON payload containing all datasource configuration parameters"
  type        = string
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to the data source in Guardium"
  type        = map(string)
  default     = {}
}