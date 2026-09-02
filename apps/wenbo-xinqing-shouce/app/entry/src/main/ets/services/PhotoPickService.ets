import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { JournalImageCatalog } from './JournalImageCatalog'

/** 系统相册选图并缓存到应用沙箱（便于列表/详情持续展示） */
export class PhotoPickService {
  static async pickMoodPhoto(context: common.UIAbilityContext): Promise<string> {
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = 1
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      if (result.photoUris.length === 0) {
        return ''
      }
      const cached = PhotoPickService.cacheToAppFiles(context, result.photoUris[0])
      if (cached.length === 0) {
        return ''
      }
      return JournalImageCatalog.toLocalKey(cached)
    } catch {
      return ''
    }
  }

  private static cacheToAppFiles(context: common.UIAbilityContext, srcUri: string): string {
    const stamp = Date.now()
    const destPath = `${context.filesDir}/mood_${stamp}.jpg`
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
