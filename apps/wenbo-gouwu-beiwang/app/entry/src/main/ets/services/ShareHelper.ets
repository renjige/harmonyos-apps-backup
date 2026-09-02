import { pasteboard } from '@kit.BasicServicesKit'

export class ShareHelper {
  static async copyText(text: string): Promise<boolean> {
    if (text.trim().length === 0) {
      return false
    }
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      return true
    } catch {
      return false
    }
  }
}
