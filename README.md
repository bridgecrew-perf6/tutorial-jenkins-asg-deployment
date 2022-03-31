Tutorial - Jenkins Auto Scaling Group Deployment Website
=======================================================

This is the codebase is the example code for a tutorial on how to get Jenkins to automatically re-deploy your website
when it is deployed through the use of an  autoscaling group (as demonstrated
[here](https://github.com/programster/tutorial-terraform-examples)).


## Terraform Steps
We will use terraform to deploy the infrastructure which features an auto scaling group.

Navigate to the `terraform/` folder

```bash
cd terraform
```

Create your own terraform variable inputs file
```bash
cp terraform.tfvars.example terraform.tfvars
```

Run `aws configure` to set your AWS credentials if you need to.

Initialize terraform by running:
```bash
terraform init
```

Deploy your auto-scaling group infrastructure by running:
```
terraform apply
```

Run the following command to get the IAM credentials that will grant Jenkins the ability to
rotate the EC2 Instances within the ASG:

```bash
terraform output jenkins_deployment_iam_key_id && \
  terraform output jenkins_deployment_iam_key_secret
```

Note: Your servers will fail to deploy a webserver until the image is ready in your registry,
which *may* not be until you have configured and run Jenkins (below) to build and push your
Docker image. If you have manually built and pushed an image, you do not need to worry about this.



## Configuring Jenkins

### Docker Registry Credentials
Create a credentials of kind `Username and Password` called `docker-registry-credentials` with the
credentials for your docker registry. This *may* just be your username/password for Docker hub if
you are not running a private registry.

This will allow Jenkins to push to your registry whenever it performs a build.


### IAM Credentials for Auto Scaling Group
Create a credentials of kind `Username and Password` called `aws-asg-credentials` with the IAM
credentials that have permission to perform an ASG instance refresh. You retrieved these details
at the end of the Terraform section above.


### Branch Config File
Create a config file with the following contents. Update as appropriate. E.g. the `DOCKER_REGISTRY`
is an empty string if you are using the Docker Hub instead of a private docker registry. If you
are using a private registry, it would have a value similar to `https://registry.mydomain.com:5000`.

The `ASG_NAME` should match the `asg_name` output variable from the Terraform output.

```json
{
    staging: {
        DOCKER_REGISTRY: "",
        IMAGE_NAME: "jenkins-asg-demo-site",
        ASG_NAME: "staging-demo-asg",
        AWS_REGION: "eu-west-2",
        IAM_ASG_CREDENTIALS_NAME: "aws-staging-asg-credentials"
    }
}
```
