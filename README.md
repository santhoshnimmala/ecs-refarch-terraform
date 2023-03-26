![build-status](https://codebuild.eu-west-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiKzBuNjJCUFk2STRvbDZENXlMUFJOenF2V2EyQ3FMbEtuWDlQeVp6TWlxdXhNMGVOZGo5bG9jdTl1YU16RmZIVVNxa3VqTVg3V3drSnJxOUQwSmhqV2g0PSIsIml2UGFyYW1ldGVyU3BlYyI6IlJJRE4wZGJaS25LL0s0dzkiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)

# Deploying Microservices with Amazon ECS, using Terraform, and an Application Load Balancer

This reference architecture provides a set of YAML templates for deploying microservices to [Amazon EC2 Container Service (Amazon ECS)](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html) with [Terraform](https://www.terraform.io/).



## Overview

![infrastructure-overview](images/architecture-overview.png)

The repository consists of a set of nested templates that deploy the following:

 - A tiered [VPC](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Introduction.html) with public and private subnets, spanning an AWS region.
 - A highly available ECS cluster deployed across two [Availability Zones](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) in an [Auto Scaling](https://aws.amazon.com/autoscaling/) group and that are AWS SSM enabled.
 - A pair of [NAT gateways](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-gateway.html) (one in each zone) to handle outbound traffic.
 - Two interconnecting microservices deployed as [ECS services](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) (website-service and product-service). 
 - An [Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/applicationloadbalancer/) to the public subnets to handle inbound traffic.
 - ALB path-based routes for each ECS service to route the inbound traffic to the correct service.
 - Centralized container logging with [Amazon CloudWatch Logs](http://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html).
 - A [Lambda Function](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) and [Auto Scaling Lifecycle Hook](https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html) to [drain Tasks from your Container Instances](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-draining.html) when an Instance is selected for Termination in your Auto Scaling Group.


#### Infrastructure-as-Code

Terraform is a tool developed by HashiCorp that allows you to define and manage your infrastructure as code. It is part of the larger Infrastructure as Code (IaC) movement, which aims to make infrastructure more manageable and reproducible by treating it as code.

With Terraform, you can define your infrastructure using a simple and declarative language called HCL (HashiCorp Configuration Language). This language allows you to describe the desired state of your infrastructure, and Terraform will take care of figuring out the steps necessary to get it there.

Terraform supports a wide range of providers, which are plugins that allow it to interact with various infrastructure platforms such as AWS, GCP, Azure, and more. With these providers, you can manage resources such as virtual machines, networks, storage, and more. 




## Template details

The templates below are included in this repository and reference architecture:

| Template | Description |
| --- | --- | 

| [vpc.tf](vpc.tf) | This template deploys a VPC with a pair of public and private subnets spread across two Availability Zones. It deploys an [Internet gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Internet_Gateway.html), with a default route on the public subnets. It deploys a pair of NAT gateways (one in each zone), and default routes for them in the private subnets. |
| [iam.tf](iam.tf) | This template contains the [security groups](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html) required by the entire stack. They are created in a separate nested template, so that they can be referenced by all of the other nested templates. |
| [loadbalancers.tf](loadbalancers.tf) | This template deploys an ALB to the public subnets, which exposes the various ECS services. It is created in in a separate nested template, so that it can be referenced by all of the other nested templates and so that the various ECS services can register with it. |
| [ecs.tf](ecs.tf) | This template deploys an ECS cluster to the private subnets using an Auto Scaling group and installs the AWS SSM agent with related policy requirements. |


### Terraform apply 
how to deploy this sample ecs cluster in you account , before you follow below steps please get AWS Role/Creds on the system 

#### Clone the Git repository containing the solution source code
```bash
git clone https://github.com/santhoshnimmala/ecs-refarch-terraform.git
```

#### Terraform Init , Plan, and Apply
```bash

terraform init 
terraform plan 
terraform apply 

```

#### Cleaning Infra 
```bash

terraform destroy

```

## Contributing

Please [create a new GitHub issue](https://github.com/awslabs/ecs-refarch-cloudformation/issues/new) for any feature requests, bugs, or documentation improvements. 

Where possible, please also [submit a pull request](https://help.github.com/articles/creating-a-pull-request-from-a-fork/) for the change. 

## License

Copyright 2011-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

[http://aws.amazon.com/apache2.0/](http://aws.amazon.com/apache2.0/)

or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

