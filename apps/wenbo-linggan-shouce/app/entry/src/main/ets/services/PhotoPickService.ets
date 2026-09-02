import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { InspirationMedia } from './InspirationMedia'

/** 系统相册选图并缓存到应用沙箱 */
export class PhotoPickService {
  static async pickOne(context: common.UIAbilityContext): Promise<string> {
    const keys = await PhotoPickService.pickMany(context, 1)
    if (keys.length === 0) {
      return ''
    }
    return keys[0]
  }

  static async pickMany(context: common.UIAbilityContext, maxSelect: number = 9): Promise<string[]> {
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = maxSelect
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      const out: string[] = []
      for (const uri of result.photoUris) {
        const cached = PhotoPickService.cacheToAppFiles(context, uri)
        if (cached.length > 0) {
          out.push(InspirationMedia.toLocalKey(cached))
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static cacheToAppFiles(context: common.UIAbilityContext, srcUri: string): string {
    const stamp = Date.now()
    const destPath = `${context.filesDir}/inspiration_${stamp}_${Math.floor(Math.random() * 10000)}.jpg`
    try {
      const src = fileIo.openSync(srcUri, fileIo.OpenMode.READ_ONLY)
      const dest = fileIo.openSync(destPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
      fileIo.copyFileSync(src.fd, dest.fd)
      fileIo.closeSync(src)
      fileIo.closeSync(dest)
      return `file://${destPath}`
    } catch {
      return srcUri
    }
  }
}
