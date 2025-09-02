import { z } from "zod";
const echoSchema = z.object({
    message: z.string(),
});
const knowledgeSchema = z.object({
    kw: z.string().optional().default(""),
    pageSize: z.number().int().positive().optional(),
    pageNum: z.number().int().positive().optional(),
});
const KB_API_URL = process.env.FUND_KB_API_URL ||
    "https://report.haiyu.datavita.com.cn/api/admin/knowledge/query";
async function handleKnowledge(args) {
    const { kw = "", pageSize = 10, pageNum = 1 } = knowledgeSchema.parse(args);
    const url = new URL(KB_API_URL);
    url.searchParams.set("kw", kw);
    url.searchParams.set("pageSize", String(pageSize));
    url.searchParams.set("pageNum", String(pageNum));
    const response = await fetch(url.toString(), {
        method: "GET",
        headers: {
            Accept: "application/json",
        },
    });
    if (!response.ok) {
        throw new Error(`Knowledge API request failed: ${response.status} ${response.statusText}`);
    }
    let data;
    try {
        data = await response.json();
    }
    catch (e) {
        throw new Error("Knowledge API returned invalid JSON");
    }
    // Normalize basic shape: { code, msg, result }
    console.log('handleKnowledge', data);
    return {
        content: [{ type: "text", text: JSON.stringify(data) }],
    };
}
export const handleToolRequest = async (request) => {
    const { name, arguments: args } = request.params;
    if (name === "fund.echo") {
        const parsed = echoSchema.parse(args);
        return {
            content: [{ type: "text", text: parsed.message }],
        };
    }
    if (name === "fund.knoewledge") {
        return await handleKnowledge(args);
    }
    throw new Error(`Unknown tool: ${name}`);
};
