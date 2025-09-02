export const getAllTools = () => [
    {
        name: 'fund.echo',
        description: 'Echo back a message. Example interface for scaffold.',
        inputSchema: {
            type: 'object',
            properties: {
                message: { type: 'string', description: 'Text to echo back' }
            },
            required: ['message']
        }
    },
    {
        name: 'fund.knoewledge',
        description: '获取的知识库列表信息',
        inputSchema: {
            type: 'object',
            properties: {
                kw: { type: 'string', description: '关键词，支持模糊查询' },
                pageSize: { type: 'number', description: '每页数量，默认10' },
                pageNum: { type: 'number', description: '页码，默认1' }
            },
        }
    }
];
