#ssh 접속을 위한 키페어를 미리 생성해둔 상태 -> 변수 파일에 지정해야함

#EC2 IAM 역할
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}EC2Role" #역할 이름

  assume_role_policy = jsonencode({ #ec2에서 사용 가능
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

#eip 생성
resource "aws_eip" "ec2_eip" {
  domain = "vpc"
}

#고객관리형 정책
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.project_name}EC2Policy"
  description = "MBV EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
              "lambda:InvokeFunction",
          ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/MBV" = "Lambda" #해당 태그가 붙은 람다 함수만 대상으로 함
          }
        }
      }
    ]
  })
}

#역할에 정책 연결
resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

#인스턴스 IAM 따로 설정
resource "aws_iam_instance_profile" "mbv_profile" {
  name = "${var.project_name}EC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
}

#인스턴스 생성
resource "aws_instance" "mbv" {
  ami                       = "ami-0aec5ae807cea9ce0" #ami 이름 (지역별로 고유)
  instance_type             = "t3.micro" #인스턴스 유형
  key_name                  = var.key_pair #키페어 이름
  subnet_id                 = var.public_subnet_id_01 #퍼블릭 서브넷 id
  vpc_security_group_ids    = [var.security_group_id] #보안 그룹 id

  root_block_device { #스토리지
    volume_size           = 8 #볼륨 크기
    volume_type           = "gp3" #볼륨 유형
    iops                  = 3000 #프로비저닝된 iops 값
    delete_on_termination = true #인스턴스 종료 시 삭제 여부
    encrypted             = true #암호화 여부
    kms_key_id            = "alias/aws/ebs" #기본값 aws/ebs 키 사용
    throughput            = 125 #처리량
  }

  iam_instance_profile                 = aws_iam_instance_profile.mbv_profile.name #위에서 생성한 IAM 역할 사용
  instance_initiated_shutdown_behavior = "stop" #EC2 종료 시 중지

  metadata_options { #인스턴스 메타데이터 옵션
    http_endpoint               = "enabled" #메타데이터 액세스 기능 활성화
    http_protocol_ipv6          = "disabled" #메타데이터 IPv6 비활성화
    http_tokens                 = "required" #버전 V2만 사용하도록 토큰 필요 여부 활성화
    http_put_response_hop_limit = 2 #홉 수 제한
    instance_metadata_tags      = "disabled" #메타데이터에서 인스턴스 태그 접근 비활성화
  }

  user_data = null
}

#인스턴스에 eip 연결
resource "aws_eip_association" "ec2_eip_association" {
  instance_id   = aws_instance.mbv.id
  allocation_id = aws_eip.ec2_eip.id
}