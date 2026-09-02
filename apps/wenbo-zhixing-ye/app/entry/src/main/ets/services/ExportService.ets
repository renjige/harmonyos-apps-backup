import { common } from '@kit.AbilityKit'
import { fileIo, picker } from '@kit.CoreFileKit'
import { pasteboard } from '@kit.BasicServicesKit'
import { util } from '@kit.ArkTS'
import { ZhixingStore } from './ZhixingStore'

export class ExportService {
  /** 优先弹出系统保存对话框，失败则复制到剪贴板 */
  static async exportForUser(context: common.UIAbilityContext): Promise<string> {
    const text = await ZhixingStore.exportAllText()
    if (text.trim().length === 0) {
      return '暂无可导出的学习数据'
    }
    try {
      const options = new picker.DocumentSaveOptions()
      options.newFileNames = [`知行页学习数据_${Date.now()}.txt`]
      const viewPicker = new picker.DocumentViewPicker()
      const uris = await viewPicker.save(options)
      if (uris.length === 0) {
        return '已取消保存'
      }
      ExportService.writeUri(uris[0], text)
      await ExportService.copyText(text)
      return '已保存到所选位置，内容也已复制到剪贴板'
    } catch {
      const ok = await ExportService.copyText(text)
      if (ok) {
        return '已复制全部学习数据到剪贴板，可粘贴到备忘录或文件 App 保存'
      }
      return '导出失败，请稍后重试'
    }
  }

  static async exportToFile(context: common.UIAbilityContext): Promise<string> {
    return ExportService.writeText(context, await ZhixingStore.exportAllText())
  }

  static async copyAll(): Promise<boolean> {
    try {
      const text = await ZhixingStore.exportAllText()
      return await ExportService.copyText(text)
    } catch {
      return false
    }
  }

  private static async copyText(text: string): Promise<boolean> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const sys = pasteboard.getSystemPasteboard()
      await sys.setData(data)
      return true
    } catch {
      return false
    }
  }

  private static writeUri(target: string, text: string): void {
    const encoder = util.TextEncoder.create('utf-8')
    const bytes = encoder.encodeInto(text)
    const file = fileIo.openSync(target, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC)
    try {
      fileIo.writeSync(file.fd, bytes)
    } finally {
      fileIo.closeSync(file)
    }
  }

  private static writeText(context: common.UIAbilityContext, text: string): string {
    const dir = `${context.filesDir}/export`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // exists
    }
    const name = `zhixing-ye-${Date.now()}.txt`
    const path = `${dir}/${name}`
    const file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
    fileIo.writeSync(file.fd, text)
    fileIo.closeSync(file)
    return path
  }
}
