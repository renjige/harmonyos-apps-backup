# 设备权限说明（上架 / AGC 对齐）

与 `module.json5` 的 `requestPermissions` 必须一致。

| 权限 | 类型 | 是否声明 | 用途 |
|------|------|----------|------|
| `ohos.permission.INTERNET` | 系统授权（非 user_grant） | 是 | 可选登录 / 注册 / 注销 |
| `ohos.permission.MICROPHONE` | user_grant | **否** | 不申请。口述收录走系统输入法，应用不采集音频 |

## 华为审核「user_grant 与隐私政策不一致」

本版本已从软件包移除 MICROPHONE。重新提交前请同时：

1. 上传新 HAP（`requestPermissions` 仅 INTERNET）
2. AGC **用户与隐私 → 协议服务 → 设备权限**：不要勾选麦克风
3. 重新上传 `store/privacy-policy.md`（第四节不再声明麦克风权限）
