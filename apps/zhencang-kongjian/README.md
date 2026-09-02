# 珍藏空间

个人数字珍藏空间 — 建档、主题册、收藏故事、计划、回顾与成就沉淀。

## DevEco 工程

打开目录：`apps/zhencang-kongjian/app/`

## 上架图标

`apps/zhencang-kongjian/store/logo/preview-1024.png`

## 底部导航（v2）

| Tab | 说明 |
|-----|------|
| 首页 | 藏间工作台：统计、快捷建档、最近入藏、主题、待整理、时光回顾 |
| 珍藏 | 全部档案，分类与清单状态筛选 |
| 主题 | 收藏领域地图 + 主题册 |
| 回顾 | 时间轴、日历、分类占比、统计 |
| 我的 | 搜索、智慧整理、计划、笔记、成就、设置 |

## 核心闭环

发现 → 建档 → 分类 → 收藏 → 整理 → 计划 → 回顾 → 沉淀

## 数据与权限

- 全部本机 Preferences 存储，无登录、无联网
- **0 新增系统权限**（图片仅 PhotoViewPicker，无相机/定位等）

## 验收

```bash
npm run gate:behavior -- apps/zhencang-kongjian
```

当前：**pass**

## slug

`zhencang-kongjian`
