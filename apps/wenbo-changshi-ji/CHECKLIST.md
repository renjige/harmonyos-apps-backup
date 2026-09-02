# 常识集 — 交付自检

## 功能
- [x] 4 Tab：今日常识 / 分类浏览 / 我的收藏 / 我的
- [x] 列表 → 详情 Hero + 正文 + CTA（收藏/笔记/清单/问答/分享卡）
- [x] 平台 API 拉取常识栏目（63 条，含安全/家庭/节日与生活场景）
- [x] 常识搜索 + 分类筛选 Overlay
- [x] 收藏夹自定义分组
- [x] 每日常识 + 连续打卡
- [x] 问答测试 + 错题回顾 + 已掌握
- [x] 生活场景知识库
- [x] 常识清单（创建 / 已学 / 备注）
- [x] 知识分享卡片（复制 + 本机文件）
- [x] 相关推荐
- [x] 每日学习提醒（ReminderAgent）
- [x] 生活工具（日期 / 换算 / 节气 / 年龄）
- [x] 本机收藏/笔记/打卡/已读（新用户空态）
- [x] 阅读兴趣匹配（模板问卷，无 LLM）
- [x] open_optional 游客浏览

## 合规
- [x] 无独立隐私首屏；登录页协议勾选
- [x] LegalDocs + store 四份 md 已按本 App 功能定制（运营者魏文波）
- [x] handleRevokePrivacy + async revoke
- [x] INTERNET + PUBLISH_AGENT_REMINDER（inuse + reason）
- [x] FeatureFlags.LLM_ENABLED=false（若存在）

## 视觉
- [x] Logo preview-1024 + 分层 foreground/background
- [x] 内容影像 ≥11 张（hero/banner/cover_*）
- [x] HomePage Image($r('app.media.*')) ≥2

## 平台
- [x] register-tenant wenbo-changshi-ji
- [x] seed-common-sense-tenant
- [x] deploy saas16（本轮改种子后需再部署）

## DevEco
- [x] Sync + assembleHap 本地编译
