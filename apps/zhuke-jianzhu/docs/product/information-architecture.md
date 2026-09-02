# 信息架构 — 筑科建筑

## 主导航（5 Tab）

```
首页 | 案例 | 业务 | 资讯 | 我的
```

## 页面树

```
Index
└── MainTabPage
    ├── [Tab0] HomePage
    │   ├── → QualificationPage（企业资质）
    │   ├── → RecruitmentPage（人才招聘）
    │   ├── → ContactPage（联系我们）
    │   ├── → ProjectDetailPage
    │   └── → NewsDetailPage
    ├── [Tab1] ProjectsPage
    │   └── → ProjectDetailPage
    ├── [Tab2] BusinessPage
    │   └── → BusinessDetailPage
    ├── [Tab3] NewsPage
    │   └── → NewsDetailPage
    └── [Tab4] MinePage
        ├── → FavoritesPage
        ├── → HistoryPage
        ├── → NotificationsPage
        ├── → FeedbackPage
        ├── → AboutPage
        ├── → QualificationPage
        ├── → RecruitmentPage
        │   └── → JobDetailPage
        └── → ContactPage
```

## 启动链

```
Index → MainTabPage（open_optional，游客可浏览）
      → LoginPage（可选，从我的或需登录操作触发）
```

## 数据层

- `MockData.ets` — 静态 Mock 数据源
- `ContentService.ets` — 内容读取与分类筛选
- `UserPrefsService.ets` — 收藏、浏览记录、通知（AppStorage）

## UI 设计令牌

| 用途 | 色值 |
|------|------|
| 品牌主色 | #0B6BCB |
| 品牌深色 | #0A2540 |
| 页面背景 | #F2F4F7 |
| 卡片背景 | #FFFFFF |
| 主文字 | #0F172A |
| 次文字 | #475569 |
