import { common } from '@kit.AbilityKit'
import { fileIo } from '@kit.CoreFileKit'
import { pasteboard } from '@kit.BasicServicesKit'
import { MemoryStore } from './MemoryStore'

export class ExportService {
  static async exportToFile(context: common.UIAbilityContext): Promise<string> {
    return ExportService.writeText(context, await MemoryStore.exportAllText())
  }

  static async exportFavorites(context: common.UIAbilityContext): Promise<string> {
    return ExportService.writeText(context, await MemoryStore.exportFavoritesText())
  }

  static async exportBooklet(context: common.UIAbilityContext, id: string): Promise<string> {
    return ExportService.writeText(context, await MemoryStore.exportBookletText(id))
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

  private static writeText(context: common.UIAbilityContext, text: string): string {
    const dir = `${context.filesDir}/export`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // exists
    }
    const name = `huiyi-ce-${Date.now()}.txt`
    const path = `${dir}/${name}`
    const file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
    fileIo.writeSync(file.fd, text)
    fileIo.closeSync(file)
    return path
  }
}
