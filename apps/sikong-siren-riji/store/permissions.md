# 设备权限说明（上架 / AGC 协议服务对齐）

本 App 为**纯本地日记**，`module.json5` 中 **`requestPermissions` 为空**。

| 能力 | 实现方式 | 是否在 module.json5 声明 |
|------|----------|-------------------------|
| 插入图片 | 系统 **PhotoViewPicker**（用户主动选图，临时 URI） | 否 |
| 日记存储 | 本机 Preferences | 否 |
| 应用锁 | 本机 Preferences | 否 |
| 网络 / 云端 | **不使用** | 否 |

## 云测「ACL permission consistency」常见原因（本 App 已规避）

1. **声明了 READ_IMAGEVIDEO / CAMERA 等但未在 Release Profile 勾选 ACL** → 已移除全部声明，改系统 Picker  
2. **声明了权限但代码未使用**（如麦克风、定位）→ 已删除  
3. **AGC「协议服务 → 设备权限」与包内声明不一致** → 包内无权限时，AGC 也应清空或未勾选多余项  

## AGC 操作

1. 打开 AppGallery Connect → **用户与隐私 → 协议服务 → 设备权限**  
2. 删除/取消与本 App 无关的权限项（相机、麦克风、定位、相册读等），与空 `requestPermissions` 保持一致  
3. 使用 **Release Profile** 重新签名打包后再上传云测  

## 后续若增加能力

| 功能 | 推荐做法 |
|------|----------|
| 拍照 | `CameraPicker` 系统控件，优先不声明 CAMERA |
| 录音 | 使用时再声明 `MICROPHONE` + AGC 同步 + 隐私政策更新 |
| 天气定位 | 使用时再声明 `APPROXIMATELY_LOCATION` |
