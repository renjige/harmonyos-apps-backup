# 知错·错题智慧训练

面向 K12 学生的智慧错题管理与针对性训练鸿蒙应用。

## 产品信息

| 项 | 值 |
|---|---|
| **App 名称** | 知错·错题智慧训练 |
| **公司** | 知错智慧 |
| **Slug** | `zhicuo-zhihui-cuoti-xunlian` |
| **行业 Pack** | `wrong-notebook` |
| **Bundle ID** | `com.zhicuozhihui.cuotixunlian` |
| **运营者** | 魏文波 |

## 核心功能

- **首页学情看板**：总错题 / 已掌握 / 待复习 + 今日训练进度环
- **错题本**：科目筛选、掌握状态筛选、搜索、批量删除、FAB 录入
- **智慧训练**：随机训练 / 专项训练（按学科与知识点）
- **学情报告**：学科分布、薄弱知识点、近七日趋势
- **拍照/手动录入**、详情页、导出、消息、设置与隐私

## DevEco 工程

打开目录：`apps/zhicuo-zhihui-cuoti-xunlian/app/`

## 平台 API

```
https://saas16.qianqi.online/api/v1
X-Tenant-Id: zhicuo-zhihui-cuoti-xunlian
```

## Admin 后台

https://saas16.qianqi.online/ — 账号见 `store/admin-account.md`

## 上架图标

- 合成预览：`store/logo/preview-1024.png`
- 矢量源稿：`store/logo/symbol.svg`（前景 `foreground.svg` + 背景 `background.svg`）
- 工程内：`app/AppScope/resources/base/media/app_icon.png`

## 审核演示账号

见 `store/demo-account.md`（**禁止**写入客户端 UI）

## 部署

```bash
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```
