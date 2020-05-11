import { appSchema, tableSchema } from '@nozbe/watermelondb'

const mySchema = appSchema({
    version: 1,
    tables: [
        tableSchema({
            name: 'posts',
            columns: [
                { name: 'title', type: 'string' },
                { name: 'content', type: 'string' },
                { name: 'likes', type: 'number' },
                { name: 'created_at', type: 'number' },
                { name: 'updated_at', type: 'number' },
            ]
        })
    ]
})

export default mySchema