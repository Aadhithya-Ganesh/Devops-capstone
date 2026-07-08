output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.k8s_vpc.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "k8s_instance_1_public_ip" {
  description = "The public IP address of the Kubernetes instance"
  value       = aws_instance.k8s_public_instance1.public_ip
}

output "k8s_instance_1_private_ip" {
  description = "The private IP address of the Kubernetes instance"
  value       = aws_instance.k8s_public_instance1.private_ip
}

output "k8s_instance_2_public_ip" {
  description = "The public IP address of the second Kubernetes instance"
  value       = aws_instance.k8s_public_instance2.public_ip
}

output "k8s_instance_2_private_ip" {
  description = "The private IP address of the second Kubernetes instance"
  value       = aws_instance.k8s_public_instance2.private_ip
}

