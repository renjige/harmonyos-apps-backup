import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'

export class PhotoPickService {
  static async pickMany(context: common.UIAbilityContext, remain: number): Promise<string[]> {
    const out: string[] = []
    if (remain <= 0) {
      return out
    }
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = remain
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      for (const uri of result.photoUris) {
        const cached = PhotoPickService.cacheToAppFiles(context, uri)
        if (cached.length > 0) {
          out.push(cached)
        }
      }
    } catch {
    }
    return out
  }

  private static cacheToAppFiles(context: common.UIAbilityContext, srcUri: string): string {
    const stamp = Date.now()
    const destPath = `${context.filesDir}/huayuan_${stamp}_${srcUri.length}.jpg`
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
