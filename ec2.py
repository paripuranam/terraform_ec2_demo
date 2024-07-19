import boto3

demo_ec2 = boto3.client("ec2", region_name = "us-east-1")

response = demo_ec2.describe_instances(
    Filters=[
        {
            'Name': 'tag:Name',
            'Values': [
                'demo_ec2_instance',
            ]
        },
    ]
);

print(response.get("Reservations"))