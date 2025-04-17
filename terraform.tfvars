region           = "us-east-1"
profile          = "default"
nodejs_image     = "node:18"
mongodb_image    = "mongo:latest"
instance_type    = "t3.micro"
desired_capacity = 1
max_size         = 2
min_size         = 1
key_name         = "N.virginia-key"
