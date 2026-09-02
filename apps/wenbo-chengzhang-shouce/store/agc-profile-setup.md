# AGC Profile 权限对齐（上传报错必看）

上传若提示 ACL permissions 与 profile / package 不一致，请按下列步骤处理。

## 本 App 包内声明的权限

| 权限 | 用途 |
|---|---|
| `ohos.permission.INTERNET` | 同步成长记录与平台 API |

（本 App **未** 使用相册选图，无需 `READ_IMAGEVIDEO`。）

## 当前 Profile 问题（已检测）

**Release 打包失败**：本机缺少 Profile 文件

```
F:/download/czsc.wxy.huaweiRelease.p7b  ← 不存在
```

`build-profile.json5` 已指向上述路径，但 `F:\download\` 下目前只有其它 App 的 p7b（如 `zkclys.zk.huaweiRelease.p7b`），**不能混用**——Profile 必须与包名 `czsc.wxy.huawei` 一一对应。

本机已有、可继续使用的签名材料：

| 文件 | 状态 |
|------|------|
| `F:/download/huawei.p12` | 存在 |
| `F:/download/huawei.cer` | 存在 |
| `F:/download/czsc.wxy.huaweiRelease.p7b` | **缺失，须从 AGC 下载** |

**Debug 包**可不依赖该 Release Profile，本地 `assembleHap` + `buildMode=debug` 已成功。

## 修复步骤（Release / 上架必做）

1. 登录 [AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html)
2. 进入应用 **成长手册**（包名 `czsc.wxy.huawei`）
3. **用户与访问** → 证书管理 → 确认 Release 证书与 `huawei.p12` / `huawei.cer` 匹配
4. **Profile 管理** → 新建/更新 **Release** Profile：
   - 包名：`czsc.wxy.huawei`
   - 权限勾选：`ohos.permission.INTERNET`（勿留空 `{}`）
5. 下载 Profile，保存为 **`F:\download\czsc.wxy.huaweiRelease.p7b`**（文件名须与 `build-profile.json5` 一致）
6. DevEco：**Build → Clean Project** → **Release** 重新打包
7. 真机卸载旧版后安装新 HAP，确认桌面名称为 **成长手册**、图标与 `store/logo/preview-1024.png` 一致

## 签名路径

`apps/wenbo-chengzhang-shouce/app/build-profile.json5` → `profile: F:/download/czsc.wxy.huaweiRelease.p7b`
