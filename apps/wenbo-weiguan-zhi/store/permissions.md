# 微观志 — 权限说明

与 `module.json5` / AppSpec / 隐私政策保持一致。

| 权限 | 类型 | 用途 | 申请时机 |
|------|------|------|----------|
| `ohos.permission.INTERNET` | normal | 可选账号登录、注册、注销 | 使用时（inuse） |

**不申请**相机、定位、麦克风等 user_grant 权限。配图仅通过系统相册选择器选取，无需声明 `CAMERA`。
