import { pasteboard } from '@kit.BasicServicesKit'
import { FolioStore } from './FolioStore'

export class ExportService {
  static async copyCsv(): Promise<boolean> {
    const csv = await FolioStore.exportCsv()
    return ExportService.copyText(csv)
  }

  static async copyText(text: string): Promise<boolean> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const sys = pasteboard.getSystemPasteboard()
      await sys.setData(data)
      return true
    } catch {
      return false
    }
  }
}
