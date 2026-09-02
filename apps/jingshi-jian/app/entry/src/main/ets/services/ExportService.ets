import { common } from '@kit.AbilityKit'
import { fileIo } from '@kit.CoreFileKit'
import { JianStore } from './JianStore'

export class ExportService {
  static async exportToFile(context: common.UIAbilityContext): Promise<string> {
    const text = await JianStore.exportAllText()
    const dir = `${context.filesDir}/export`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // exists
    }
    const name = `jingshi-jian-${Date.now()}.txt`
    const path = `${dir}/${name}`
    const file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
    fileIo.writeSync(file.fd, text)
    fileIo.closeSync(file)
    return path
  }
}
