# Symbiote-task

This is the repo for Symbiote task.

1. Versions:
    - Terraform: v0.12.31
    - aws provider: v3.40.0

2. There are three customised modules created based on functionality of aws resource: 
    - Compute
    - Network
    - Storage

3. Constrains of the system:
    - Security: 
        - RDS needs KMS key to encrypt the contents 
        - Root modules variables need to declare saperately in variable file
        - RDS login hard-coded in (Need to store/fetch from Vault)
        - HTTP needs to redirect to HTTPS 

    - Logs:
        - There is no log for EC2 instance since the agent is not installed

4. Demo site is avaliable from output Application Load Balancer dns name: alb_address
    - for example:
            compute_alb_address = alb-1856156085.ap-southeast-2.elb.amazonaws.com
   
5. The key used to login to EC2 instance is attached in my email, and you can use it to test MySQL connection
