/**
 * 登录/注册页可打开的协议全文（与 store/privacy-policy.md、user-agreement.md 对齐）。
 *
 * ⚠️ 脚手架占位 — scaffold 后必须整段替换，禁止直接出货。
 * 见 .cursor/rules/app-legal-docs.mdc
 */
export class LegalDocs {
  static privacyTitle(): string {
    return '隐私政策'
  }

  static agreementTitle(): string {
    return '用户协议'
  }

  static privacyBody(): string {
    return '【待定制】运营者：魏文波\n应用名称：星座物候\n\n' +
      '请按 app-legal-docs.mdc 根据本 App 功能重写 privacyBody()，并同步 store/privacy-policy.md。\n\n' +
      '禁止保留：咨询预约、AI 参谋、企业客户与创业者、未替换的 {{SUPPORT_PHONE}}。'
  }

  static agreementBody(): string {
    return '【待定制】运营者：魏文波\n应用名称：星座物候\n\n' +
      '请按 app-legal-docs.mdc 根据本 App 功能重写 agreementBody()，并同步 store/user-agreement.md。\n\n' +
      '禁止保留：咨询预约、AI 参谋、企业客户与创业者。'
  }
}
