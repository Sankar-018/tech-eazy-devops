#############################################
# IAM ROLE FOR EC2 (S3 + Monitoring)
#############################################

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_s3_role" {
  name               = "tech-eazy-ec2-s3-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# S3 read access for app.jar
data "aws_iam_policy_document" "s3_read" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.app_builds.arn,
      "${aws_s3_bucket.app_builds.arn}/*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "s3_read_policy" {
  name   = "tech-eazy-s3-read"
  policy = data.aws_iam_policy_document.s3_read.json
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

# Monitoring policy – CloudWatch + SNS
resource "aws_iam_policy" "monitoring_policy" {
  name   = "tech-eazy-monitoring"
  policy = file("${path.module}/policies/monitoring.json")
}

resource "aws_iam_role_policy_attachment" "attach_monitoring_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.monitoring_policy.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "tech-eazy-ec2-profile"
  role = aws_iam_role.ec2_s3_role.name
}
