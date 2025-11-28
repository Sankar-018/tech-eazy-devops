#############################################
# LAUNCH TEMPLATE – used by ASG
#############################################

resource "aws_launch_template" "app_lt" {
  name_prefix   = "tech-eazy-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(
    templatefile("${path.module}/user_data.tpl", {
      bucket             = aws_s3_bucket.app_builds.bucket
      key                = var.s3_object_key
      stop_after_minutes = var.stop_after_minutes
    })
  )

  lifecycle {
    create_before_destroy = true
  }
}
