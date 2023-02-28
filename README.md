# Prisma Cloud DevSecOps <img src="https://github.com/GBaileyMcEwan/lambdaapp/blob/main/nginx/images/prisma-reverse.png" width=25% height=25% align="right">

Prisma Cloud is a Cloud Native Application Protection Platform (CNAPP).  One of the modules used in Prisma Cloud is Cloud Workload Protection (CWP) which can be used for:

- Vulnerability Management
- Compliance Management
- Runtime Protection
- Web Application and API security
- Open Policy Admission
- Embedding security into DevOps pipelines
- Several other use-cases!

You can find out more about Prisma Cloud [here](https://www.paloaltonetworks/prisma/cloud).

## Purpose

This demo utilizes a Jenkins build server to go through a pipeline which:

- Clones this repository
- Downloads the latest Prisma Cloud "twistcli" tool
- Scans a Terraform plan (IaC) to deploy a Lambda function in AWS Prisma Cloud Security Scanning
- Scans the serverless function itself for vulnerable third-party dependencies <mark>Prisma Cloud Security Scanning</mark>
- Deploys the serverless function into AWS using Terraform
- Scans a Dockerfile for security misconfigurations <mark>Prisma Cloud Security Scanning</mark>
- Builds the custom nginx container image
- Scans the built container image for security misconfigurations <mark>Prisma Cloud Security Scanning</mark>
- Pushes the built container to dockerhub
- Scans the kubernetes manifest for security misconfigurations <mark>Prisma Cloud Security Scanning</mark>
- Finally desploys the application to a k8s cluster
