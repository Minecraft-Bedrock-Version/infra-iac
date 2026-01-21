import boto3
import os
import json
import uuid
import time

s3 = boto3.client('s3')
codebuild = boto3.client('codebuild')
iam = boto3.client('iam')

S3_BUCKET_NAME = os.environ.get("S3_BUCKET_NAME")
CODEBUILD_PROJECT_NAME = os.environ.get("CODEBUILD_PROJECT_NAME")
CODEBUILD_ROLE_NAME = os.environ.get("CODEBUILD_ROLE_NAME")

#Lambda 트리거 시 전달되어야하는 event 인자값 (JSON으로 아래 내용이 포함되어야 함)
#polciy_name : 생성 예정인 정책 이름
#polciy_document : 생성 예정인 정책의 JSON 내용
#cli_commands : 실행 예정인 CLI 명령어

def lambda_handler(event, context):
    try:
        policy_name = event['policy_name']
        policy_document = json.dumps(event['policy_document'])
        cli_commands = event['cli_commands']

        #CLI 명령어 스크립트 S3 업로드
        cli_filename = f"deploy-{uuid.uuid4().hex}.sh"
        s3.put_object(
            Bucket=S3_BUCKET_NAME,
            Key=cli_filename,
            Body=cli_commands,
            ContentType="text/x-sh"
        )
        print(f"CLI script uploaded to s3://{S3_BUCKET_NAME}/{cli_filename}")

        #JSON 정책 생성
        policy_arn = iam.create_policy(
            PolicyName=policy_name,
            PolicyDocument=policy_document
        )['Policy']['Arn']
        print(f"IAM Policy created: {policy_arn}")

        #생성된 JSON 정책을 Codebuild 역할에 연결
        iam.attach_role_policy(
            RoleName=CODEBUILD_ROLE_NAME,
            PolicyArn=policy_arn
        )
        print(f"Policy attached to CodeBuild role: {CODEBUILD_ROLE_NAME}")

        #CodeBuild 트리거
        response = codebuild.start_build(
            projectName=CODEBUILD_PROJECT_NAME,
            environmentVariablesOverride=[
                {
                    'name': 'CLI_FILE_NAME',
                    'value': cli_filename,
                    'type': 'PLAINTEXT'
                }
            ]
        )
        build_id = response['build']['id']
        print(f"CodeBuild started: {build_id}")

        #CodeBuild가 완료되면
        while True:
            build_info = codebuild.batch_get_builds(ids=[build_id])
            current_status = build_info['builds'][0]['buildStatus']
            
            print(f"Current Build Status: {current_status}")

            if current_status in ['SUCCEEDED', 'FAILED', 'FAULT', 'STOPPED', 'TIMED_OUT']:
                if current_status != 'SUCCEEDED':
                    raise Exception(f"CodeBuild failed with status: {current_status}")
                break
            
            time.sleep(10)
            
        print("CodeBuild finished successfully")

        #CodeBuild 역할에서 정책 삭제
        iam.detach_role_policy(
            RoleName=CODEBUILD_ROLE_NAME,
            PolicyArn=policy_arn
        )
        iam.delete_policy(PolicyArn=policy_arn)
        print(f"Policy detached and deleted: {policy_arn}")

        return {
            "statusCode": 200,
            "body": f"CLI executed via CodeBuild. Policy {policy_name} cleaned up."
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "body": str(e)
        }
