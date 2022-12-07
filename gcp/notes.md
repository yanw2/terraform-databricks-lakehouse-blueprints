# Notes

## How to get network id
This is place to manually add network configure: https://accounts.gcp.databricks.com/cloud-resources/network/network-configurations/

for the step 3 on this doco: https://docs.gcp.databricks.com/administration-guide/cloud-configurations/gcp/customer-managed-vpc.html#network-requirements-1

Once created, click on the name of VPC network and you can get the `network_id` at the end of the URL. For example, the `network_id` is `584f59d3-b43c-49b5-9a28-84765fb0f905` in this URL: https://accounts.gcp.databricks.com/cloud-resources/network/network-configurations/584f59d3-b43c-49b5-9a28-84765fb0f905

## Missing network permission issue

│ Error: cannot create mws workspaces: PERMISSION_DENIED: Insufficient permissions: please make sure you have the following permissions on GCP project sandbox-cuusoo: compute.networks.get, compute.projects.get, compute.subnetworks.get. Using google-accounts auth: host=https://accounts.gcp.databricks.com, google_service_account=cuusoo-sa2@sandbox-cuusoo.iam.gserviceaccount.com

Add the following roles to `cuusoo-sa2@sandbox-cuusoo.iam.gserviceaccount.com`:

- Databricks Workspace Creator (already exist)
- Compute Network Viewer
- Project Viewer
