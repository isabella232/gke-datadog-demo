/*
Copyright 2018 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Provides access to available Google Container Engine versions in a zone for a given project.
// https://www.terraform.io/docs/providers/google/d/google_container_engine_versions.html
data "google_container_engine_versions" "on-prem" {
  zone    = var.zone
  project = var.project
}

// https://www.terraform.io/docs/providers/google/d/google_container_cluster.html
// Create the primary cluster for this project.
// Node count is 2 to better illustrate that DaemonSet deploys datadog agent to
// each node
resource "google_container_cluster" "primary" {
  name               = var.clusterName
  zone               = var.zone
  initial_node_count = 2
  min_master_version = data.google_container_engine_versions.on-prem.latest_master_version

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.zone} --project ${var.project}"
  }
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "primary_zone" {
  value = google_container_cluster.primary.zone
}
