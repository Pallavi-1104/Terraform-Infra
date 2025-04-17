#!/bin/bash
echo "ECS_CLUSTER=my-ecs-cluster" >> /etc/ecs/ecs.config
yum update -y
yum install -y docker
service docker start
systemctl enable docker
yum install -y ecs-init
systemctl enable --now ecs
mkdir -p /ecs/mongo-data
mkdir -p /ecs/prometheus
