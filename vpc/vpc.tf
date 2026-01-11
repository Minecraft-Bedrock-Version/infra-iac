#VPC 생성
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr #VPC CIDR 블록 지정
  enable_dns_support   = true #VPC에서 내부에서 dns 사용 가능
  enable_dns_hostnames = true #VPC 내 리소스에 dns 부여

  tags = {
    Name = "${var.project_name}-VPC"
  }
}

#퍼블릭 서브넷 생성
resource "aws_subnet" "public_subnet_01" {
  vpc_id               = aws_vpc.vpc.id  #VPC 선택
  cidr_block           = var.public_subnet_cidr_01 #퍼블릭 서브넷의 CIDR
  availability_zone    = var.availability_zone_01 #퍼블릭 서브넷이 위치할 가용 영역

  tags = {
    Name = "${var.project_name}-public-subnet-01" #서브넷 이름 지정 
    Type = "Public"
  }
}

#인터넷 게이트웨이 생성
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id  #VPC 선택

  tags = {
    Name = "${var.project_name}-internet-gateway" #igw 이름 지정
  }
}

#퍼블릭 서브넷용 라우트 테이블 생성
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id  #VPC 선택

  route { #라우트 규칙 정의
    cidr_block = "0.0.0.0/0" #서브넷에서 나가는 모든 트래픽이
    gateway_id = aws_internet_gateway.internet_gateway.id #인터넷 게이트웨이를 통하도록 설정
  }

  tags = {
    Name = "${var.project_name}-public-route" #라우트 테이블 이름 지정
  }
}

#퍼블릭 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "route_table_public_subnet_01" {
  subnet_id      = aws_subnet.public_subnet_01.id #퍼블릭 서브넷 선택
  route_table_id = aws_route_table.route_table.id #퍼블릭 서브넷용 라우트 테이블에 연결
}