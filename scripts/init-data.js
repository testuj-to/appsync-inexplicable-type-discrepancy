
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb')
const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb')

const dynamoDBDocumentClient = DynamoDBDocumentClient.from(new DynamoDBClient({}))

if (!process.env.DEMO_DDB_TABLE_NAME) {
    throw new Error('Missing env DEMO_DDB_TABLE_NAME')
}

const tableName = process.env.DEMO_DDB_TABLE_NAME

const main = async() => {
    await dynamoDBDocumentClient.send(new PutCommand({
        TableName: tableName,
        Item: {
            key1: ':ITEM:foo',
            dim1: ':ITEM:foo',
            item: {
                expectedValue: 12,
            },
        },
    }))

    console.log('Test item successfully created with id = "foo"')
}

main()
