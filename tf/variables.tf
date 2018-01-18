variable "code_version" {
  description = "Version of the code used to tag resources"
  default = "latest"
}

variable "env" {
  description = "Name of environment"
  default = "demo"
}

variable "region" {
  description = "The region to deploy the cluster in, e.g: us-east-1."
  default = "eu-west-1"
}

variable "amisize" {
  description = "The size of the cluster nodes, e.g: t2.large. Note that OpenShift will not run on anything smaller than t2.large"
  default = "t2.micro"
}

variable "key_name" {
  description = "The name of the key to user for ssh access, e.g: consul-cluster"
  default = "iac-demo"
}

variable "ssh_access_cidr" {
  description = "CIDR range for ssh access"
  default = "127.0.0.1/32"
}

variable "public_key_path" {
  description = "The local public key path, e.g. ~/.ssh/id_rsa.pub"
  default = "~/.ssh/id_rsa.pub"
}

variable "public_key" {
  description = "The public key for ssh access"
  default = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC88zGC1zwsgFliy6q4etLu2IBFM58LlFyiMhJt1J4ta5/n93hL/EIg9dVFhE2IIuU59hFgwv0qDx4/MEVhuesM5SwRNE9exxEOunzpUjQZWG1hAyF2Xlid+11mJBK+wLZnqqB+PL3lWtHk8Udg0skgbQKaWLWPV2H7euKLylDxEWhZrK3JzrGKUtkWGevTFM5b0NTkJYSN5tOHILYmOmlHAIb/IUPqoQi4w5U4Kft7+Cix+Zo2Z5Wm+fjyWPiuwdHTIl+E5d1+edx6+0JNwYS95LGgprF4fN3vWr2r8gAMjYASBYJ3i3MJuVzJTvUE2SMMDJglbD6yHpVUu3jzaAC7 tomasz@cloudowski.com
EOF
}
