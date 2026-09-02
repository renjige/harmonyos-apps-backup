import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { RecordStore } from './RecordStore'

export class ExportService {
  static async exportTextFile(context: common.UIAbilityContext): Promise<string> {
    const text = await RecordStore.exportText()
    return ExportService.writeFile(context, text, 'txt')
  }

  static async exportCsvFile(context: common.UIAbilityContext): Promise<string> {
    const text = await RecordStore.exportCsv()
    return ExportService.writeFile(context, text, 'csv')
  }

  static async exportReportFile(context: common.UIAbilityContext, reportText: string): Promise<string> {
    return ExportService.writeFile(context, reportText, 'txt')
  }

  private static writeFile(context: common.UIAbilityContext, text: string, ext: string): string {
    const dir = `${context.filesDir}/exports`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // exists
    }
    const path = `${dir}/saichang_${Date.now()}.${ext}`
    let file: fileIo.File | null = null
    try {
      file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC)
      fileIo.writeSync(file.fd, text)
      return path
    } finally {
      if (file !== null) {
        try {
          fileIo.closeSync(file)
        } catch {
          // ignore
        }
      }
    }
  }
}
