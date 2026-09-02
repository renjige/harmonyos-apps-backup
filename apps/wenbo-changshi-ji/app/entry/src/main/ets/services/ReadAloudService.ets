import { pasteboard } from '@kit.BasicServicesKit'
import { FactItem } from '../models/CommonSenseModels'

export class ReadAloudService {
  static async copyForReadAloud(item: FactItem): Promise<string> {
    const text = `${item.title}\n\n${item.body}`
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      return '已复制全文，可在系统朗读或粘贴使用'
    } catch {
      return '复制失败，请稍后重试'
    }
  }
}
