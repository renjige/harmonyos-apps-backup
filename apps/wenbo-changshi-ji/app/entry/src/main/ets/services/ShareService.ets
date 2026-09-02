import { pasteboard } from '@kit.BasicServicesKit'
import { fileIo, picker } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { util } from '@kit.ArkTS'
import { FactItem } from '../models/CommonSenseModels'

export class ShareService {
  static async shareFact(item: FactItem): Promise<string> {
    const card = ShareService.buildCard(item)
    if (card.trim().length < 8) {
      return '卡片内容尚未加载，请稍后再试'
    }
    return ShareService.copyText(card)
  }

  static async saveCardFile(item: FactItem, context: common.UIAbilityContext): Promise<string> {
    const card = ShareService.buildCard(item)
    if (card.trim().length < 8) {
      return '卡片内容尚未加载，请稍后再试'
    }
    try {
      const options = new picker.DocumentSaveOptions()
      const safeTitle = ShareService.safeFileName(item.title)
      options.newFileNames = [`常识集_${safeTitle}.txt`]
      const viewPicker = new picker.DocumentViewPicker()
      const uris = await viewPicker.save(options)
      if (uris.length === 0) {
        return '已取消保存'
      }
      ShareService.writeText(uris[0], card)
      await ShareService.copyText(card)
      return '已保存到所选位置，文案也已复制到剪贴板'
    } catch {
      try {
        const path = `${context.filesDir}/changshiji_card_${item.id}.txt`
        ShareService.writeText(path, card)
        await ShareService.copyText(card)
        return '已保存到应用目录并复制到剪贴板，可在文件管理器中查看'
      } catch {
        return '保存失败，请稍后重试'
      }
    }
  }

  static buildCard(item: FactItem): string {
    if (item.id.length === 0 || item.title.length === 0) {
      return ''
    }
    let card = `【常识集 · ${item.categoryLabel()}】\n`
    card += `${item.title}\n\n`
    const body = item.summary.length > 0 ? item.summary : item.body
    card += `${body}\n\n`
    if (item.source.length > 0) {
      card += `来源：${item.source}\n`
    }
    card += '— 来自常识集 App'
    return card
  }

  private static async copyText(card: string): Promise<string> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, card)
      await pasteboard.getSystemPasteboard().setData(data)
      return '分享卡片已复制到剪贴板'
    } catch {
      return '复制失败，请稍后重试'
    }
  }

  private static writeText(target: string, text: string): void {
    const encoder = util.TextEncoder.create('utf-8')
    const bytes = encoder.encodeInto(text)
    const file = fileIo.openSync(target, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC)
    try {
      fileIo.writeSync(file.fd, bytes)
    } finally {
      fileIo.closeSync(file)
    }
  }

  private static safeFileName(title: string): string {
    let name = title.trim()
    if (name.length === 0) {
      return '常识卡片'
    }
    if (name.length > 18) {
      name = name.substring(0, 18)
    }
    let out = ''
    for (let i = 0; i < name.length; i++) {
      const ch = name.charAt(i)
      if (ch === '\\' || ch === '/' || ch === ':' || ch === '*' || ch === '?' ||
        ch === '"' || ch === '<' || ch === '>' || ch === '|') {
        out = `${out}_`
      } else {
        out = `${out}${ch}`
      }
    }
    return out.length > 0 ? out : '常识卡片'
  }
}
