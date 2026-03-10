# 1. Correct Trust Relationship
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["${var.service_identifier}"] # MUST be ec2
    }
  }
}

resource "aws_iam_role" "idp_manager" {
  name               = "${var.service_role_name}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# 2. The Instance Profile (The 'Bridge')
resource "aws_iam_instance_profile" "idp_profile" {
  name = "${var.iam_instance_profile_name}"
  role = aws_iam_role.idp_manager.name
}

# 3. The Security Group (The 'Shield')
resource "aws_security_group" "idp_sg" {
  name   = "${var.iam_sg_name}"
  vpc_id = "${aws_vpc.hub_vpc.id}" # Pass this from the Spoke VPC module

  # Allow the instance to talk to the SSM API
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. The Instance
resource "aws_instance" "app_server" {
  ami                  = "${var.ami_image}" # Or your SSM resolve string
  instance_type        = "${var.instance_type}"
  iam_instance_profile = aws_iam_instance_profile.idp_profile.name
  subnet_id            = "${aws_subnet.private_hub_subnet.id}"
  vpc_security_group_ids = [aws_security_group.idp_sg.id]

  tags = { Name = "idp-spoke-app" }
}