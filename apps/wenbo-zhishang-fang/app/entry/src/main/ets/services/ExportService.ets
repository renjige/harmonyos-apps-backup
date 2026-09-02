import { common } from '@kit.AbilityKit'
import { fileIo } from '@kit.CoreFileKit'
import { pasteboard } from '@kit.BasicServicesKit'
import { NoteStore } from './NoteStore'

export class ExportService {
  static async exportCsvFile(context: common.UIAbilityContext): Promise<string> {
    const csv = await NoteStore.exportCsv()
    const dir = `${context.filesDir}/export`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // exists
    }
    const path = `${dir}/zhishang-fang-${Date.now()}.csv`
    const file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
    fileIo.writeSync(file.fd, csv)
    fileIo.closeSync(file)
    return path
  }

  static async copyCsv(): Promise<boolean> {
    const csv = await NoteStore.exportCsv()
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
