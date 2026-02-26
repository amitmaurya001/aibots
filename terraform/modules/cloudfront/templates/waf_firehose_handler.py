import os
import base64


import boto3


session = boto3.Session(region_name=os.getenv('SNS_REGION'))
sns = session.client('sns')


def lambda_handler(event, null):
    output = []
    records = event['records']

    for record in records:
        payload = base64.b64decode(record['data']).decode('utf-8')
        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(payload.encode('utf-8'))
        }
        output.append(output_record)

    print(f'Successfully processed {len(records)} records.')

    return {'records': output}
