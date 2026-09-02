# 消暑饮品 · 方案 B（无生成式对话）

本应用 **不上架生成式对话**。`FeatureFlags.LLM_ENABLED = false`，C 端不调用 `/ai/chat`。

「智慧配饮」= 6 道选择题 + 规则模板报告 + 打开匹配到的饮品详情。

平台 `ai-config.json` 仍写入差异化 systemPrompt，供 Admin 备查；手机包不以此为主功能。

取得《安全评估报告》并完成算法备案前，禁止打开 LLM 开关，禁止在商店文案中写「AI 文本生成」。
