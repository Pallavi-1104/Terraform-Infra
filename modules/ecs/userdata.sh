#!/bin/bash
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

#!/bin/bash
mkdir -p /ecs/mongo-data

#!/bin/bash
yum update -y
yum install -y docker
systemctl enable docker
systemctl start docker

mkdir -p /ecs/mongo-data

# Install ECS agent
echo "ECS_CLUSTER=your-cluster-name" >> /etc/ecs/ecs.config
yum install -y ecs-init
systemctl enable ecs
systemctl start ecs

{
  "Effect": "Allow",
  "Action": [
    "ecs:CreateCluster",
    "ecs:RegisterContainerInstance",
    "ecs:DeregisterContainerInstance",
    "ecs:DiscoverPollEndpoint",
    "ecs:Submit*",
    "ecs:Poll"
  ],
  "Resource": "*"
}
