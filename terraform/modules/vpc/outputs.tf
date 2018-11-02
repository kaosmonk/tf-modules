output "vpc_name" {
  value = "${google_compute_network.vpc.name}"
}

output "vpc_subnet_name" {
  value = "${google_compute_subnetwork.subnet.name}"
}
