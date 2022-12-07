variable "databricks_account_id_secret" {}
variable "databricks_google_service_account" {}
variable "databricks_workspace_name" {}

terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.6.5"
    }
  }
}

data "google_client_openid_userinfo" "me" {
}

data "google_secret_manager_secret_version" "account_id" {
  project = var.project_id
  secret  = var.databricks_account_id_secret
}

resource "databricks_mws_workspaces" "this" {
  provider       = databricks.accounts
  account_id     = data.google_secret_manager_secret_version.account_id.secret_data
  workspace_name = var.databricks_workspace_name
  location       = data.google_client_config.current.region

  cloud_resource_bucket {
    gcp {
      project_id = data.google_client_config.current.project
    }
  }
  network {
    network_id = var.network_id
    gcp_common_network_config {
      gke_cluster_master_ip_range = "10.3.0.0/28"
      gke_connectivity_type       = "PRIVATE_NODE_PUBLIC_MASTER"
    }
    gcp_managed_network_config {
      subnet_cidr                  = google_compute_subnetwork.gc_subnet_fsl.ip_cidr_range
      gke_cluster_pod_ip_range     = google_compute_subnetwork.gc_subnet_fsl.secondary_ip_range.0.ip_cidr_range
      gke_cluster_service_ip_range = google_compute_subnetwork.gc_subnet_fsl.secondary_ip_range.1.ip_cidr_range
    }
  }
}

provider "databricks" {
  alias                  = "workspace"
  host                   = databricks_mws_workspaces.this.workspace_url
  google_service_account = var.databricks_google_service_account
}

data "databricks_group" "admins" {
  depends_on   = [databricks_mws_workspaces.this]
  provider     = databricks.workspace
  display_name = "admins"
}

resource "databricks_user" "me" {
  depends_on = [databricks_mws_workspaces.this]

  provider  = databricks.workspace
  user_name = data.google_client_openid_userinfo.me.email
}

resource "databricks_group_member" "allow_me_to_login" {
  depends_on = [databricks_mws_workspaces.this]

  provider  = databricks.workspace
  group_id  = data.databricks_group.admins.id
  member_id = databricks_user.me.id
}

