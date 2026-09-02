import { fileIo } from '@kit.CoreFileKit'
import { pasteboard } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'
import { ScriptStore } from './ScriptStore'

export class ExportService {
  static async exportToFile(context: common.UIAbilityContext): Promise<string> {
    const text = await ScriptStore.exportAllText()
    const dir = `${context.filesDir}/exports`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // already exists
    }
    const path = `${dir}/shenghuo_juben_${Date.now()}.txt`
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

  static async copyAllToClipboard(): Promise<boolean> {
    try {
      const text = await ScriptStore.exportAllText()
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      return true
    } catch {
      return false
    }
  }
}
