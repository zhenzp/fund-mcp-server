#!/usr/bin/env node
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { SSEServerTransport } from "@modelcontextprotocol/sdk/server/sse.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";
import { VERSION } from "./common/version.js";
import { config } from "dotenv";
import { getAllTools } from "./tool-registry/index.js";
import { handleToolRequest } from "./tool-handlers/index.js";

const server = new Server(
  {
    name: "fund-mcp-server",
    version: VERSION,
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: getAllTools(),
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  try {
    if (!request.params.arguments) {
      throw new Error("Arguments are required");
    }
    return await handleToolRequest(request);
  } catch (error) {
    if (error instanceof z.ZodError) {
      throw new Error(`Invalid input: ${JSON.stringify(error.errors)}`);
    }
    throw error as Error;
  }
});

config();

const useSSE =
  process.argv.includes("--sse") || process.env.MCP_TRANSPORT === "sse";
const useHttp =
  process.argv.includes("--http") || process.env.MCP_TRANSPORT === "http";

async function runServer() {
  if (useSSE || useHttp) {
    const { default: express } = await import("express");
    const app: any = express();
    const port = process.env.PORT || 3000;

    // 添加CORS中间件，支持跨域访问
    app.use((req: any, res: any, next: any) => {
      // 允许所有来源
      res.header("Access-Control-Allow-Origin", "*");
      // 允许的HTTP方法
      res.header(
        "Access-Control-Allow-Methods",
        "GET, POST, PUT, DELETE, OPTIONS"
      );
      // 允许的请求头
      res.header(
        "Access-Control-Allow-Headers",
        "Origin, X-Requested-With, Content-Type, Accept, Authorization"
      );
      // 允许发送凭证
      res.header("Access-Control-Allow-Credentials", "true");

      // 处理预检请求
      if (req.method === "OPTIONS") {
        res.sendStatus(200);
      } else {
        next();
      }
    });

    app.use(express.json({ limit: "10mb" }));

    // 新增：普通HTTP REST API端点
    if (useHttp) {
      // 列出所有可用工具
      app.get("/api/tools", async (req: any, res: any) => {
        try {
          const tools = getAllTools();
          res.json({
            success: true,
            data: tools,
          });
        } catch (error) {
          res.status(500).json({
            success: false,
            error: error instanceof Error ? error.message : "Unknown error",
          });
        }
      });

      // 调用工具
      app.post("/api/tools/call", async (req: any, res: any) => {
        try {
          const { name, arguments: args } = req.body;

          if (!name) {
            return res.status(400).json({
              success: false,
              error: "Tool name is required",
            });
          }

          if (!args) {
            return res.status(400).json({
              success: false,
              error: "Arguments are required",
            });
          }

          // 创建模拟的MCP请求格式
          const mockRequest = {
            params: {
              name,
              arguments: args,
            },
          };

          const result = await handleToolRequest(mockRequest as any);

          res.json({
            success: true,
            data: result,
          });
        } catch (error) {
          res.status(500).json({
            success: false,
            error: error instanceof Error ? error.message : "Unknown error",
          });
        }
      });

      // 健康检查
      app.get("/api/health", (req: any, res: any) => {
        res.json({
          success: true,
          message: "fund MCP Server is running",
          version: VERSION,
          mode: "HTTP REST API",
        });
      });
    }

    // 原有的SSE模式
    if (useSSE) {
      const sessions: Record<
        string,
        { transport: SSEServerTransport; server: Server }
      > = {};

      app.get("/sse", async (req: any, res: any) => {
        const sseTransport = new SSEServerTransport("/messages", res);
        const sessionId = sseTransport.sessionId;
        if (sessionId) {
          sessions[sessionId] = { transport: sseTransport, server };
        }
        try {
          await server.connect(sseTransport);
        } catch (error) {
          res.status(500).send("Server error");
        }
      });

      app.post("/messages", async (req: any, res: any) => {
        const sessionId = req.query.sessionId as string;
        const session = sessions[sessionId];
        if (!session) {
          res.status(404).send("Session not found");
          return;
        }
        try {
          await session.transport.handlePostMessage(req, res, req.body);
        } catch (error) {
          res.status(500).send("Server error");
        }
      });
    }

    const serverInstance: any = app.listen(port, () => {
      if (useHttp) {
        console.log(
          `fund MCP Server running in HTTP REST API mode on port ${port}`
        );
        console.log(`Health check: http://localhost:${port}/api/health`);
        console.log(`List tools: http://localhost:${port}/api/tools`);
        console.log(`Call tool: POST http://localhost:${port}/api/tools/call`);
        console.log(`LLM API: POST http://localhost:${port}/api/llm/call`);
      }
      if (useSSE) {
        console.log(`fund MCP Server running in SSE mode on port ${port}`);
        console.log(`SSE endpoint: http://localhost:${port}/sse`);
      }
    });

    process.on("SIGINT", () => {
      serverInstance.close(() => {
        process.exit(0);
      });
    });
  } else {
    const transport = new StdioServerTransport();
    await server.connect(transport);
  }
}

runServer().catch(() => {
  process.exit(1);
});
