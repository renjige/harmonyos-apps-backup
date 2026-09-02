# Delivery Bundle 标准

每个生成结果落在：

```text
apps/{companyPinyin}-{appPinyin}/
```

## 标准目录树

```text
{slug}/
  AppSpec.json
  GATE_A_RESULT.md
  CHECKLIST.md
  FIX_LIST.md                 # 仅 Gate B 失败时
  artifacts.json              # Artifact 登记列表
  app/                        # P2 HarmonyOS
  server/                     # P3 NestJS
  db/                         # P4
  ai/                         # P5
  store/                      # P6
  docs/
    product/                  # P1
    deploy.md
    demo-script.md
```

## 命名

- `companyPinyin` / `appPinyin`：小写英文，单词用连字符  
- 示例：`yuanxiang-xunjian`

## 完成定义

1. Gate A = pass  
2. P1–P6 产物路径存在且非空  
3. Gate B CHECKLIST 全部 block 级项通过  
4. `artifacts.json` 中各 pipeline status = validated  

模板见 `_templates/delivery/`。
