output instance_ip {
    value = data.aws_instances.asg_instance.*.public_ips
}

output alb_address {
    value = aws_alb.alb.dns_name
}
