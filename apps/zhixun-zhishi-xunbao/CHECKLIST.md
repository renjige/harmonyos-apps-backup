# 知识寻宝 交付检查清单

当前 App 名称：**知识寻宝**

## 功能

- [x] 5 Tab：发现 / 地图 / 寻宝 / 宝藏 / 我的
- [x] 首页卡片进地图详情，详情可开始寻宝
- [x] 闯关：选题 → 确认 → 解析；错题可重试（每关 3 次）
- [x] 通关解锁宝藏 + 智慧值；我的宝藏网格
- [x] 每日签到
- [x] 栏目走平台 `/biz/knowledge-quest/*`，无客户端 localSeed
- [x] 新用户本机进度为空
- [x] 消息中心拉取机构通知
- [x] 智慧匹配问卷（规则模板，无大模型）
- [x] 无支付 / 无商城
- [x] 文案无「AI」字样

## 隐私

- [x] 启动无独立隐私首屏；协议勾选在登录/注册
- [x] LegalDocs 与 store 四 md 同步；运营者魏文波
- [x] PrivacyService.revoke async + MinePage handleRevokePrivacy + 顶层 Toast
- [x] 禁止「删除业务数据」；可清除缓存
- [x] 登录页不展示演示账号

## 影像 / Logo

- [x] store/logo/preview-1024.png
- [x] productVisualType=content-commerce，media ≥5 且封面独立
- [x] HomePage 至少 2 处 Image 真图

## 平台

- [x] register-tenant zhixun-zhishi-xunbao
- [x] seed-knowledge-quest-tenant
- [x] deploy saas16
- [x] 公网 maps 列表 20 条
