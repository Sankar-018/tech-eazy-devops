aws_region = "ap-south-1"

instance_type = "t3.micro"      # or t2.micro if all AZs support it
key_name      = "AWS_keypair"

stage = "dev"

stop_after_minutes = 60

s3_object_key       = "app.jar"
local_app_artifact  = "/home/sankar-m/Desktop/app/app.jar"   # Keep empty unless uploading from local

alert_email = "sankar01820@gmail.com"

asg_min_size         = 1
asg_desired_capacity = 2
asg_max_size         = 10
#asg_min_size         = 1
#asg_desired_capacity = 1
#asg_max_size         = 1
