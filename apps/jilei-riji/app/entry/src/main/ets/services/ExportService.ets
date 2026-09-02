import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { DiaryStore } from './DiaryStore'

export class ExportService {
  static async exportToFile(context: common.UIAbilityContext): Promise<string> {
    const text = await DiaryStore.exportAllText()
    const dir = `${context.filesDir}/exports`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // directory may already exist
    }
    const name = `jilei_export_${Date.now()}.txt`
    const path = `${dir}/${name}`
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
          // ignore close errors
        }
      }
    }
  }
}
