import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { pasteboard } from '@kit.BasicServicesKit'
import { EssayStore } from './EssayStore'

export class ExportOutcome {
  ok: boolean = false
  message: string = ''
  text: string = ''
}

export class ExportService {
  static async exportPlainText(context: common.UIAbilityContext): Promise<ExportOutcome> {
    const text = await EssayStore.exportPlainText()
    return ExportService.deliver(context, text, 'txt')
  }

  static async exportMarkdown(context: common.UIAbilityContext): Promise<ExportOutcome> {
    const text = await EssayStore.exportMarkdown()
    return ExportService.deliver(context, text, 'md')
  }

  private static async deliver(context: common.UIAbilityContext, text: string, ext: string): Promise<ExportOutcome> {
    const out = new ExportOutcome()
    out.text = text
    if (text.trim().length === 0) {
      out.message = '暂无记录可导出'
      return out
    }
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
    } catch {
      out.message = '无法写入剪贴板'
      return out
    }
    ExportService.writeSandbox(context, text, ext)
    out.ok = true
    out.message = '已复制到剪贴板，可粘贴到备忘录或文件'
    return out
  }

  private static writeSandbox(context: common.UIAbilityContext, text: string, ext: string): void {
    const dir = `${context.filesDir}/exports`
    try {
      fileIo.mkdirSync(dir)
    } catch {
    }
    const path = `${dir}/weiguan_export_${Date.now()}.${ext}`
    let file: fileIo.File | null = null
    try {
      file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC)
      fileIo.writeSync(file.fd, text)
    } catch {
    } finally {
      if (file !== null) {
        try {
          fileIo.closeSync(file)
        } catch {
        }
      }
    }
  }
}
