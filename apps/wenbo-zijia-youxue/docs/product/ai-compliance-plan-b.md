# AI 合规方案 B · 自驾游学

C 端 `FeatureFlags.LLM_ENABLED = false`。不提供自由对话大模型，不上架「AI 文本生成」卖点。

「研学匹配」为问卷 + 规则模板：按年龄、天数、主题匹配已有路线 ID（srr01–srr08），输出准备提醒与行动清单。文案使用「智慧」「智能」，避免「AI」。

取得《安全评估报告》并完成算法备案前，禁止打开 `/ai/chat`。平台 `ai-config.json` 仍写入本 App 专用 systemPrompt，仅供后台备查。
