import { common, Want } from '@kit.AbilityKit'
import promptAction from '@ohos.promptAction'

/** 电话 / 邮件跳转 — 岗位详情、联系我们等复用 */
export class ContactUtil {
  static normalizePhone(raw: string): string {
    let digits = ''
    for (let i = 0; i < raw.length; i++) {
      const c = raw.charAt(i)
      if (c >= '0' && c <= '9') {
        digits += c
      }
    }
    return digits
  }

  static dial(context: common.UIAbilityContext, rawPhone: string): void {
    const phone = ContactUtil.normalizePhone(rawPhone)
    if (phone.length === 0) {
      promptAction.showToast({ message: '暂无可用电话号码' })
      return
    }
    const want: Want = {
      action: 'ohos.want.action.dial',
      uri: `tel:${phone}`
    }
    context.startAbility(want).catch(() => {
      promptAction.showToast({ message: `请拨打 ${rawPhone}` })
    })
  }

  static sendEmail(context: common.UIAbilityContext, email: string): void {
    const trimmed = email.trim()
    if (trimmed.length === 0) {
      promptAction.showToast({ message: '暂无可用邮箱地址' })
      return
    }
    const want: Want = {
      action: 'ohos.want.action.sendToData',
      uri: `mailto:${trimmed}`
    }
    context.startAbility(want).catch(() => {
      promptAction.showToast({ message: trimmed })
    })
  }
}
