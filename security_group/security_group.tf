#보안그룹 생성
resource "aws_security_group" "mbv_sg" {
  name        = "${var.project_name}-sg" #보안 그룹 이름
  description = "MBV Security Group" #설명
  vpc_id      = var.vpc_id #vpc 선택
}

#보안그룹 인바운드 규칙 생성 - http 허용
resource "aws_vpc_security_group_ingress_rule" "in_http" {
  security_group_id = aws_security_group.mbv_sg.id #보안 그룹 참조
  cidr_ipv4         = "0.0.0.0/0" #모든 트래픽 허용
  from_port         = 80 #포트
  ip_protocol       = "tcp" #tcp
  to_port           = 80 #포트
}

#보안그룹 인바운드 규칙 생성 - https 허용
resource "aws_vpc_security_group_ingress_rule" "in_https" {
  security_group_id = aws_security_group.mbv_sg.id #보안 그룹 참조
  cidr_ipv4         = "0.0.0.0/0" #모든 트래픽 허용
  from_port         = 443 #포트
  ip_protocol       = "tcp" #tcp
  to_port           = 443 #포트
}

#보안그룹 인바운드 규칙 생성 - ssh 허용
resource "aws_vpc_security_group_ingress_rule" "in_ssh" {
  security_group_id = aws_security_group.mbv_sg.id #보안 그룹 참조
  cidr_ipv4         = "0.0.0.0/0" #모든 트래픽 허용
  from_port         = 22 #포트
  ip_protocol       = "tcp" #tcp
  to_port           = 22 #포트
}

#보안그룹 인바운드 규칙 생성 - Vector DB 허용
resource "aws_vpc_security_group_ingress_rule" "in_vector_db" {
  security_group_id = aws_security_group.mbv_sg.id #보안 그룹 참조
  cidr_ipv4         = "0.0.0.0/0" #모든 트래픽 허용
  from_port         = 6333 #포트
  ip_protocol       = "tcp" #tcp
  to_port           = 6333 #포트
}

#보안그룹 아웃바운드 규칙 생성
resource "aws_vpc_security_group_egress_rule" "out_all" {
  security_group_id = aws_security_group.mbv_sg.id #보안 그룹 참조
  cidr_ipv4         = "0.0.0.0/0" #모든 트래픽 허용
  ip_protocol       = "-1" #모든 프로토콜과 포트 허용
}