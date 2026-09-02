# AGC Profile 权限对齐

Release 包仅声明 **`ohos.permission.INTERNET`**。

相册选图使用 HarmonyOS 系统 **PhotoViewPicker**（用户主动操作时弹出），**不需要** `READ_IMAGEVIDEO`，与 Profile 空权限配置兼容。

## 本 App 包内权限

| 权限 | 用途 |
|---|---|
| `ohos.permission.INTERNET` | 同步札记 / 相册元数据 / 账号 API |

个人照片保存在应用沙箱，不经相册读权限批量扫描。

## 上传步骤

1. DevEco **Clean → Build Release**（版本 1.0.2+）
2. 使用 `shzj.wxy.huawei` Release Profile 签名
3. 上传 AGC；权限仅需 INTERNET
