This folder contains all the files required (and possibly some unneeded ones):

- To use Terraform to successfully deploy a functional CodeBuild project to AWS
- Build 3 EC2 Windows Servers and 1 Ansible controller
- Run a Powershell script to install WinRM prerequisites for Ansible on each Windows Server

When the CodeBuild project is manually executed, it will:

- Run an Ansible playbook that will promote 1 target server to a Windows domain controller

Next steps:

Configure the playbook to join the other 2 Windows servers to the domain and promote them to domain controllers

This folder also contains a Codepipeline.tf file which would successfully deploy a CodePipeline using Terraform that integrates with GitHub using AWS CodeStar Connections.
However, CodeStar Connections have an explicit Deny set via SCP so while the code works, it can't be used with my sandbox. :-(

That being said, a manually configured web hook in the repo the pipeline is pulling from will accomplish the same thing.