# Infrastructure as Code Demo
This repo contains resources used to provide demo for Infrastructure as Code concept using **Jenkins pipelines**.

![images/pipeline1.png](!images/pipeline1.png)

# Usage

  * First launch jenkins using custom image (with required plugins)

  ```
  cd jenkins
  docker-compose up -d
  ```

  * After built is complete and your container is running you can point your browser to [http://localhost:8888](http://localhost:8888) to verify it.

  * Create jobs using command line

  ```
  ./load-seed.sh
  ```

  * Now you can launch job **ansible-pipeline** to check sample pipeline using ansible with code available at [src/](src/)

## Pipeline for Terraform

This pipeline creates VPC in AWS using code available at [https://github.com/cloudowski/terraform-vpc](https://github.com/cloudowski/terraform-vpc).

To use it you need to provide AWS credentials using standard *Username/Password* credentials in Jenkins.

  * Go to **Credentials->Jenkins->Global Credentials**
  * **Add credentials**
  * Provide your **AWS_ACCESS_KEY_ID** as **Username** and **AWS_SECRET_ACCESS_KEY** as **Password**
  * Type **aws-keys** as **ID** in the form

Now launch **terraform-aws-vpc-pipeline** job to initiate pipeline. Before actual deployment it will ask for permission.
