import { pasteboard } from '@kit.BasicServicesKit'

export class ClipboardHelper {
  static async copyText(text: string): Promise<boolean> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      return true
    } catch {
      return false
    }
  }
}
