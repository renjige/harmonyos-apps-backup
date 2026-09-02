# 趣味解谜 Logo

## 概念

问号与灯泡融合：问号代表解谜探索，灯泡代表智慧灵感。主色华为蓝 `#007AFF`，点缀暖橙 `#FF6B35`。

## 分层

- **background.png** — 纯 `#007AFF` 底
- **foreground.png** — 白问号 + 橙灯泡图形
- **preview-1024.png** — 合成预览

## 生成

```bash
node store/logo/render_logo.mjs
node runtimes/ensure-app-logo.mjs apps/wenbo-quwei-jiemi
```
