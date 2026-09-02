import { pasteboard } from '@kit.BasicServicesKit'

export class ClipService {
  static async copy(text: string): Promise<boolean> {
    if (text.length === 0) {
      return false
    }
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
