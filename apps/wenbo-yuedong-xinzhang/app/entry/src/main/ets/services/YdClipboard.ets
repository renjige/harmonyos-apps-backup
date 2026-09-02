import { pasteboard } from '@kit.BasicServicesKit'

export class YdClipboard {
  static async copyText(text: string): Promise<boolean> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      return true
    } catch {
      return false
    }
  }
}
