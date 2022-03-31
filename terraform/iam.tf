# This configuration file is responsible for creating the IAM user that will have programmatic
# access to the registry.

# Create the IAM user
resource "aws_iam_user" "my_iam_user" {
  name = "my-asg-iam-user"
}

# Create and assign the permissions policy to the user.
resource "aws_iam_user_policy" "my_iam_policy" {
  name = "EcrPullFromMyRegistry"
  user = aws_iam_user.my_iam_user.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "${aws_autoscaling_group.my_auto_scaling_group.arn}"
        }
    ]
}
EOF
}

# Create the programmatic access key for the user.
resource "aws_iam_access_key" "my_jenkins_asg_access_key" {
  user = aws_iam_user.my_iam_user.name
}