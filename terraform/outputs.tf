# Outputs
# Define all the outputs of information the user needs to know. E.g. the URI of the generated load
# balancer etc.


# Output the URL of the load balancer we created.
# https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest?tab=outputs
output "load_balancer_url" {
    value = aws_lb.my_load_balancer.dns_name
}


# output the web port, so you don't forget which port you need to connect to the endpoint and IP on.
output "web_port" {
    value = var.web_port
}


# Output the credentials Jenkins will need in order to send the command
# to refresh the instances within the ASG.
output "jenkins_deployment_iam_key_id" {
    value = aws_iam_access_key.my_jenkins_asg_access_key.id
    sensitive = false
}

output "jenkins_deployment_iam_key_secret" {
    value = aws_iam_access_key.my_jenkins_asg_access_key.secret
    sensitive = true
}

output "asg_name" {
    value = aws_autoscaling_group.my_auto_scaling_group.name
    sensitive = false
}

output "aws_region" {
    value = var.aws_region
}
