# 云水间

记录生活、整理心绪、收藏灵感、规划日常、回望时光的个人生活美学空间，东方留白与现代鸿蒙原生体验。

## DevEco 工程

打开目录：**`apps/yunshui-jian/app/`**

Sync Project → Build → 运行到模拟器或真机。

## 上架图标

| 用途 | 路径 |
|-----|------|
| **华为上架主图（1024×1024）** | `store/logo/preview-1024.png` |
| 工程 App 图标 | `app/AppScope/resources/base/media/app_icon.png` |
| 模块图标 | `app/entry/src/main/resources/base/media/icon.png` |
| 启动图标 | `app/entry/src/main/resources/base/media/startIcon.png` |
| 分层素材 | `store/logo/foreground.png` + `store/logo/background.png` |
| Symbol 矢量源 | `store/logo/symbol.svg` |

## 产品定位

- **类型**：纯本地生活美学工具
- **联网**：否（0 权限，无 `INTERNET`）
- **登录**：否（启动直达主 Tab，无账号体系）
- **AI**：否（无生成式对话）
- **提醒**：否（不调度系统提醒）
- **运营者**：魏文波
- **slug**：`yunshui-jian`

## 五 Tab 功能一览

| Tab | 页面 | 核心能力 |
|-----|------|---------|
| **首页** | `HomePage` | Hero 氛围、连续记录/本月札记/完成统计、快捷入口（写札记/记灵感/新计划/打卡）、今日心情、那年今日、最近札记、时光轴、全局搜索 |
| **札记** | `JournalHubPage` | 札记列表与详情（Hero + 编辑 + 删除）、灵感/经验库（经验/问题/目标/方案/挑战/收藏）、分类看板、快捷模板 |
| **计划** | `PlanHubPage` | 习惯打卡（连续/累计）、生活清单（购物/家务/出行/学习等）、计划编辑、完成归档 |
| **回顾** | `ReviewHubPage` | 主题册（按月/按年照片墙）、月度回顾摘要、时光轴、纪念日倒计时 |
| **我的** | `MinePage` | 数据看板（札记/连续/照片/打卡/心情/锦囊/目标等统计）、标签管理、纪念日、深色模式、设置与隐私 |

## 数据存储

全部业务数据保存在设备本地（HarmonyOS Preferences + 沙箱文件），无云端同步、无第三方 SDK。

主要 Store：`YunLocalStore`（札记/清单/习惯/心情/标签/纪念日）、`YunCraftStore`（灵感/经验库）。

## 详情与交互

- 札记 / 灵感：列表 → 详情 Overlay（Hero + 正文 + CTA）→ 全屏编辑
- 计划清单：勾选完成 / 点击进入编辑 Sheet
- 破坏性操作：删除、清除全部数据、撤回隐私均二次确认 + 顶部 Toast
- 深色模式：杀进程后偏好保持

## 视觉资产

内容影像清单见 [`docs/product/visual-assets.md`](docs/product/visual-assets.md)。

首页 Hero、Banner 与栏目封面均通过 `Image($r('app.media.*'))` 引用真图，禁止纯色块代替。

## 功能验收

完整功能勾选见 [`docs/product/feature-list.md`](docs/product/feature-list.md)。

## 目录结构

```text
apps/yunshui-jian/
├── app/                 # 鸿蒙客户端（DevEco 打开此目录）
│   └── entry/src/main/ets/
│       ├── pages/       # HomePage · JournalHub · PlanHub · ReviewHub · MinePage
│       ├── components/  # detail/ · yun/ · design-system/
│       └── services/    # YunLocalStore · YunCraftStore · YunDetailNav
├── store/               # 上架资料、Logo、隐私协议四件套
├── docs/product/        # feature-list · visual-assets · positioning
└── AppSpec.json
```

## 隐私与合规

- 启动直达主界面；协议全文在 **我的 → 设置与隐私** 可查看
- 本应用已接入华为应用市场隐私声明托管；应用内提供协议查阅、清除缓存、清除全部数据、撤回本机隐私标记
- 五处协议正文同步：`LegalDocs.ets` + `store/privacy-policy.md` + `user-agreement.md` + `personal-info-list.md` + `third-party-list.md`

## 行为门禁

交付前执行：

```bash
npm run gate:behavior -- apps/yunshui-jian
```

## 未实现（有意不做）

- 账号注册/登录与云端同步
- 网络 API 与 SaaS 平台对接
- 生成式 AI 对话
- 系统推送与代理提醒
- 第三方 SDK 与广告
