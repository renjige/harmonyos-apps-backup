# AGC 上架配置指南（私人日记）

## 1. 创建应用

1. 登录 [AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html)
2. **我的项目** → 新建/选择项目 → **添加应用** → 平台选 **HarmonyOS**
3. 应用名称：**私人日记**（≤15 字）
4. Bundle ID：`com.sikong.sirenriji`（与 `app/AppScope/app.json5` 一致）

## 2. 备案

- 在工信部完成 **APP 备案**，平台选择 **鸿蒙**
- 备案主体与 AGC 开发者账号一致（运营者：魏文波）

## 3. 隐私政策 URL

- 将 `store/privacy-policy.md` 发布为可公网访问的 HTTPS 页面
- 在 AGC **应用信息 → 隐私政策** 填写该 URL
- 应用内首次启动已有勾选弹窗（`PrivacyConsentOverlay`）

## 4. 素材

| 项 | 路径 |
|----|------|
| 应用图标 1024 | `store/logo/preview-1024.png` |
| 截图 | 时间线 / 日历 / 统计 / 编辑页 / 设置（≥5 张） |
| 一句话简介 | 智能陪伴的私人日记本，记录生活每一刻的温暖与思考 |

## 5. 分类与标签

- 分类：**应用 > 实用工具 > 笔记/记录**
- 关键词：日记、心情、本地、隐私、记录

## 6. 权限说明（与 module.json5 一致）

在 AGC 权限说明中写明：相册/相机/麦克风/大致位置均在用户触发功能时使用（`when: inuse`）。

## 7. 云测试

- AGC **质量 → 云测试** 提交 Release 包
- 重点验证：首次隐私弹窗、写日记、日历、统计、应用锁、杀进程重启

## 8. 鸿蒙激励计划 2026

- **9 月 25 日前** 报名激励计划
- **9 月 30 日前** 提交上架
- 目标：任一自然月有效月活 ≥400，评分 >3

## 9. DevEco 打包

1. 打开 `apps/sikong-siren-riji/app/`
2. **Build → Generate Key** 配置签名
3. **Build → Build Hap(s)/APP(s) → Build APP(s)** 选 **release**
4. 上传 `.app` 至 AGC
