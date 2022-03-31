# Create an AWS EC2 instance with its own security group.




# Create security group for the server.
resource "aws_security_group" "my_hello_world_security_group" {
    name = "myHelloWorldServerSecurityGroup"

    # Open firewall up to allow everyone to access the server on port 22 for SSH.
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    # Open firewall up to allow everyone to access the webserver on the web port
    ingress {
        from_port   = var.web_port
        to_port     = var.web_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Open the server up to allow it to connect outwards to anywhere. E.g. to apply updates etc.
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


# Create a template file for the cloud init configuration. This is necessary because we wish to
# perform variable substitution in order to allow the user to specify the public SSH Key.
data "template_file" "my_template_file" {
    template = file("./cloud-init.yml")

    vars = {
        ssh_public_key = var.ssh_public_key
        web_port = var.web_port
        docker_image = var.docker_image
    }
}



