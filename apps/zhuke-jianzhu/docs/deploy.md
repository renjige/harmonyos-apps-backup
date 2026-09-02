# 部署说明 — 筑科建筑

生产环境走 **HarmonyOS 统一平台 SaaS**（`saas.qianqi.online`），与元象建筑、鲸鸿智服等 App 相同模式。  
本地 `server/` 仅用于开发联调；公网只部署 `platform/`。

## 架构

| 组件 | 路径 | 生产 |
|------|------|------|
| 统一 API | `platform/server` | PM2 `:3090` |
| 统一管理台 | `platform/admin` | Nginx SPA |
| 租户配置 | `platform/tenants/zhuke-jianzhu.json` | 随部署同步 |
| 租户数据 | `platform/data/runtime/zhuke-jianzhu/` | JSON 持久化 |
| 鸿蒙 App | `app/` | ApiConfig → HTTPS 公网 |

App 请求头必须带 `X-Tenant-Id: zhuke-jianzhu`（`HttpClient` 已自动注入）。

## 一、服务器前置条件

| 项 | 值 |
|----|-----|
| IP | `47.96.7.150` |
| 域名 | `saas.qianqi.online`（DNS A 记录） |
| 远程目录 | `/www/wwwroot/saas.qianqi.online` |
| 面板 | 宝塔 |
| 进程 | PM2 `harmonyos-platform-api` |

**安全组 / 防火墙**须放行：22（SSH）、80、443。

SSL：宝塔站点 → SSL → Let's Encrypt 申请 `saas.qianqi.online`。

SSH 示例：

```bash
sshpass -p "f66s295lfftn0joryhnAA" ssh -o StrictHostKeyChecking=no \
  -o PreferredAuthentications=password -o PubkeyAuthentication=no \
  root@47.96.7.150
```

## 二、一键部署（仓库根目录）

在 **HarmonyOS 仓库根目录**（非 `apps/zhuke-jianzhu`）执行：

```bash
bash runtimes/deploy-platform-saas.sh
```

脚本会：

1. 构建 `platform/admin` 与 `platform/server`
2. rsync 上传 admin SPA、server dist、`tenants/`、`data/`
3. 远程 `npm install --omit=dev` + PM2 重启
4. 写入 Nginx 扩展：`/` → SPA，`/api/` → `127.0.0.1:3090`
5. 健康检查：`GET https://saas.qianqi.online/api/v1/platform/tenants`

## 三、验证 API

```bash
curl -sS -H "X-Tenant-Id: zhuke-jianzhu" \
  https://saas.qianqi.online/api/v1/content/banners | head -c 400
```

期望：`code: 0`，返回 Banner 列表。

## 四、鸿蒙客户端（发布前）

`app/entry/src/main/ets/config/ApiConfig.ets`：

- `USE_LOCAL_DEV = false`（生产）
- `TENANT_ID = 'zhuke-jianzhu'`
- `USE_HTTPS = true` → `https://saas.qianqi.online/api/v1`

`EntryAbility` 已读取 ApiConfig；`allowDevHttp` 生产为 `false`。

**本地联调**：设 `USE_LOCAL_DEV = true`，启动 `apps/zhuke-jianzhu/server`（`:3000`）。

## 五、管理后台

| 环境 | 地址 | 账号 |
|------|------|------|
| 公网 SaaS | https://saas.qianqi.online/ | 见 `store/admin-account.md` |
| 本地内容台 | `apps/zhuke-jianzhu/admin/` | 代理 API，开发用 |

## 六、新租户注册（其他 App）

```bash
node runtimes/register-tenant.mjs --slug {slug}
# 编辑 platform/data/admin-users.json 增加租户管理员
bash runtimes/deploy-platform-saas.sh
```

## 七、审核发布

1. 确认 ApiConfig 指向公网 HTTPS
2. 使用 `store/demo-account.md` 演示账号
3. 提交前跑根目录 `CHECKLIST.md`

## 故障排查

| 现象 | 处理 |
|------|------|
| SSH 超时 | 阿里云安全组放行 22 |
| HTTPS 失败 | 宝塔申请 SSL；检查 443 |
| API 404 | PM2 `harmonyos-platform-api` 是否 online |
| 未知租户 | `tenantId` 是否为 `zhuke-jianzhu` |
| 内容为空 | 检查 `data/runtime/zhuke-jianzhu/showcase-content.json` 是否已同步 |

详细迁移备忘：`platform/docs/migrate-47.96.7.150.md`
