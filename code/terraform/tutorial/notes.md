# Chapter 1: Why Terraform
## Ad Hoc scripts:
- Bash, ruby, python
- Run any type of commands
- Unprganized
## Configuration management tools:
- Ansible, puppet, chef
- Run and install software on existing servers
- Organized
## Server templating:
- Packer, docker
- Image of a server
## VM vs containers:
- VM virtualize host resources
- Container emulates the user space of an OS
- Image loc. 418
## Orchestration tools:
- Kubernetes, AWS EKS
- How/Where to run images and update them
## Provisioning tools:
- Terraform, CloudFormation
- Create infrastructure
## Procedural vs delcarative:
- Steps to get to a desired end state
- Desired end state (tools does the steps for you)
## Interesting table that compare all IaC tools loc 939

# Chapter 2: Getting started with Terraform
- `terraform graph` can be used to generate a dependency graph's code that can create an image
- `type` supports complex structural types. See loc 1434
- You can use the `data` structure to search for AWS account default resources, like default VPC or subnets. It can be useful, for example, to retrieve default AZs. See loc 1607  