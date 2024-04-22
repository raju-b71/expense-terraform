resource "aws_security_group" "main" {
  name = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"
  vpc_id = var.vpc_id


  ingress {                            #one is inboundport/any sg wii have inbound rules and outbound rules
    from_port        = 0
    to_port          = 0              #0 to 0 is whole range
    protocol         = "-1"         #this stands for all traffic(-1)
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"                 #one is outboundport
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
}




resource "aws_instance" "instance" {
  ami           = data.aws_ami.ami.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]   #we created our own security group
  subnet_id = var.subnets[0] #we give first subnet
  tags = {
    Name = var.component
    monitor = "yes"
    env = var.env
  }
}



resource "null_resource" "ansible" {      # but can be used to trigger actions through provisioners or local-exec #THIS HAS NO INHERENT PROPERTIES  triggers
  provisioner "remote-exec" {              #   It uses provisioners to execute local commands (using local-exec)

    connection {
      type     = "ssh"
      user     = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_user
      password = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_password
      host     = aws_instance.instance.private_ip
    }
    inline = [
      "sudo pip3.11 install ansible hvac",
      "ansible-pull -i localhost, -U https://github.com/raju-b71/expense-ansible get-secrets.yml -e env=${var.env} -e role_name=${var.component} -e vault_token=${var.vault_token}",
      "ansible-pull -i localhost, -U https://github.com/raju-b71/expense-ansible expense.yml -e env=${var.env} -e role_name=${var.component} -e @~/secrets.json -e @~/app.json",
      "rm -f ~/secrets.json ~/app.json"

    ]
  }
}

resource "aws_route53_record" "record" {
  name    = "${var.component}-${var.env}"
  type    = "A"
  zone_id = var.zone_id
  records = [aws_instance.instance.private_ip]
  ttl = 30
}

resource "aws_lb" "main" {
  count = var.lb_needed ? 1 : 0                                           #loadbalncer
  name               = "{var.env}-${var.component}-alb"
  internal           = var.lb_type == "public" ? false : true              #this  is cond if var.lb= public is false then
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = var.lb_subnets                                       # we have to go to f,b and choose subnets

  tags = {
    Environment = "{var.env}-${var.component}-alb"
  }
}
#


