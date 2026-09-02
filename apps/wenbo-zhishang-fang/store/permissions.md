# 设备权限说明（上架 / AGC 对齐）

与 `module.json5` 的 `requestPermissions` 必须一致。华为审核比对的是 **user_grant**，不是全部权限。

| 权限 | 类型 | 软件包是否申请 | 隐私政策是否声明为已申请 |
|------|------|----------------|--------------------------|
| `ohos.permission.INTERNET` | 系统普通权限（非 user_grant） | 是 | 仅作联网说明 |
| `ohos.permission.CAMERA` | user_grant | **否（已从软件包移除）** | **否（正文不得出现 CAMERA / 相机权限）** |

封面配图仅走系统相册选择器，不调用拍摄接口。

## 华为审核「user_grant 与隐私政策不一致」

本版本已从软件包移除 CAMERA。重新提交前请同时：

1. DevEco **重新打 Release HAP**（确认 `module.json` 的 `requestPermissions` 仅有 INTERNET）
2. AGC **用户与隐私 → 协议服务**：重新上传 `store/privacy-policy.md`
3. AGC **用户与隐私 → 设备权限**：**不要勾选相机**（以及麦克风、位置、存储等未申请项）
