# 部署说明模板

## 后端

1. 配置 `.env`（参考 `server/.env.example`）  
2. 执行 `db/migrations` 与 `db/seeds`  
3. 启动 NestJS，确认 HTTPS 与 IPv6 可达  

## 客户端

1. DevEco 打开 `app/`  
2. 配置服务端 Base URL  
3. 发布前关闭调试；使用正式签名  

## 审核

1. 使用 `store/demo-account.md` 中账号  
2. 按 `store/screenshot-plan.md` 截图  
3. 提交前再跑一遍根目录 `CHECKLIST.md`
