
import { util } from '@aws-appsync/utils'

export function request(ctx) {
    return {
        version: '2017-02-28',
        operation: 'GetItem',
        key: util.dynamodb.toMapValues({
            key1: `:ITEM:${ctx.args.id}`,
            dim1: `:ITEM:${ctx.args.id}`,
        }),
    }
}

export function response(ctx) {
    if (ctx.error) {
        return util.error(ctx.error.message, ctx.error.type)
    }

    const item = ctx.result.item

    return JSON.stringify({
        value: ctx.args.value,
        valueType: typeof ctx.args.value,
        expectedValue: item.expectedValue,
        expectedValueType: typeof item.expectedValue,
        isEqual: ctx.args.value == item.expectedValue,
        isTripleEqual: ctx.args.value === item.expectedValue,
    })
}
