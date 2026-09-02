# 溪漫观

**溪漫观** 是一款智慧生活记录与状态洞察鸿蒙应用。每日三条漫观笔记（文字 + 情绪标签），状态图谱可视化，本机生成智慧洞察报告。

> 让每一天的碎片生活，被智慧地看见。

## DevEco 工程路径

```
apps/ximan-guan/app/
```

## 核心功能（完整闭环）

| Tab | 功能 |
|-----|------|
| 漫观 | 每日记录（限 3 条 × 50 字）、6 种情绪、今日列表、近 7 日时间线、详情**编辑/删除**（二次确认） |
| 图谱 | 情绪分布、趋势（点击柱查看当日笔记并可编辑）、关键词云（周/月） |
| 洞察 | 报告卡片流、智慧寄语、分享复制 |
| 我的 | 昵称、每日提醒（Toggle + 时间选择）、主题持久化、JSON 导出、清除笔记、协议、撤回隐私 |

## 数据与网络

- **纯本地** Preferences 存储，无网络、无登录
- 首次启动隐私弹窗
- 提醒权限：`PUBLISH_AGENT_REMINDER`（默认关闭，用户开启后才调度）

## 上架图标

- **上架用图**：`apps/ximan-guan/store/logo/preview-1024.png`
- 工程副本：`apps/ximan-guan/app/AppScope/resources/base/media/app_icon.png`

## 验收

见 `CHECKLIST.md` 与 `docs/product/feature-list.md`

## 运营者

魏文波 · 详见 `store/app-info.md`
