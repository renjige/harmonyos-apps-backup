# 权限说明

| 权限 | 时机 | 原因 |
|---|---|---|
| ohos.permission.INTERNET | 打开首页 / 心笺 / 通知时 | 拉取今日一句、标签预设、金句与机构通知 |

添加图片使用系统 **PhotoViewPicker**（用户当场点选），不声明 `READ_IMAGEVIDEO`。该权限属于受限 ACL，声明但未写入签名 Profile 会导致云测 **ACL permission consistency** 失败。

不申请：通讯录、定位、麦克风、电话、短信、读取相册、系统通知。
