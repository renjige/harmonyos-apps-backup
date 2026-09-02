# 第三方共享清单

| 第三方 | 共享内容 | 目的 |
|--------|----------|------|
| 无广告 SDK | — | — |
| 无生成式大模型 | 不传输摘录正文 | C 端 FeatureFlags.LLM_ENABLED=false |

账号登录时请求运营者业务 API（saas16.qianqi.online），仅传输账号字段，不上传书摘正文。
