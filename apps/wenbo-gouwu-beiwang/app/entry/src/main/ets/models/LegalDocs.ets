/**
 * 登录/设置页协议全文，与 store/privacy-policy.md、user-agreement.md 一致。
 * 应用名称、开发者、运营者与 AppGallery Connect 提交信息一致。
 */
import { BrandIdentity } from '../config/BrandIdentity'

export class LegalDocs {
  static privacyTitle(): string {
    return '隐私政策'
  }

  static agreementTitle(): string {
    return '用户协议'
  }

  static identityLine(): string {
    return `${BrandIdentity.appName()} · ${BrandIdentity.developer()}`
  }

  static privacyBody(): string {
    return BrandIdentity.legalHeader() + '\n' +
      '一、我们如何收集和使用信息\n' +
      '1. 游客可在本机创建购物清单、物品、常购库、价格、标签、备忘与提醒。这些内容默认保存在您的设备中，用于采购管理与提醒。\n' +
      '2. 若您选择注册/登录，我们将收集账号、密码、姓名和联系电话，以便同步您主动创建的清单、物品、常购库、备忘和提醒。\n' +
      '3. 我们不会将本应用用于商品交易、支付或向第三方出售个人信息。\n\n' +
      '二、权限\n' +
      '本应用使用网络权限（ohos.permission.INTERNET）以便在登录后同步清单。若您设置智慧提醒，将申请发布提醒通知权限（ohos.permission.PUBLISH_AGENT_REMINDER），用于在您选定的时间发送本地通知。不申请通讯录、短信、电话、定位或相册权限。\n\n' +
      '三、存储与共享\n' +
      '登录后的业务数据保存在运营者管理的云端服务中，按租户隔离。未接入广告 SDK，不向大模型传输您的对话或清单内容。\n\n' +
      '四、您的权利\n' +
      '可在「我的 → 设置与隐私」查看本政策与用户协议、撤回隐私同意或注销账号。撤回后需重新勾选协议才能登录。\n\n' +
      '五、联系方式\n' +
      `如有疑问，请通过华为开发者联盟预留渠道或应用内「我的 → 关于」页反馈。上架开发者登记为魏文波，运营主体为${BrandIdentity.operator()}。`
  }

  static agreementBody(): string {
    return BrandIdentity.legalHeader() + '\n' +
      '一、服务说明\n' +
      `${BrandIdentity.appName()}是个人与家庭采购管理工具。您可以按日常采购、生鲜食品、家庭用品、旅行用品、儿童用品分类管理多份清单；记录商品名称、数量、备注、预估与实付价格及必买/待确认等标签；使用常购物品库与超市/菜市场/家庭补货/搬家/出行等模板快速建单；查看购物历史并一键再买一次；收藏常用方案；设置一次或每周采购提醒；统计花费与常购分类。备忘页可补充说明。本应用不是购物商城，不提供商品浏览、下单或支付。\n\n` +
      '二、使用规则\n' +
      '请合理使用清单与备忘功能，不得利用本应用从事违法活动。游客可在本机使用；登录后可同步数据。\n\n' +
      '三、账号\n' +
      '注册需提供账号、密码、姓名和电话。您对账号下的操作负责。可随时在「我的 → 设置与隐私」注销。\n\n' +
      '四、免责\n' +
      '清单与提醒仅作个人备忘，不构成消费建议，也不替代您在商店现场的核对。\n\n' +
      '五、协议更新\n' +
      '我们可能更新本协议。继续使用即视为同意更新后的内容。'
  }
}
