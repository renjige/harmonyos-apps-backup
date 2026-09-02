import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { common } from '@kit.AbilityKit'
import { MediaUriUtil } from '../utils/MediaUriUtil'

export class PhotoPickService {
  static async pickAlbum(context: common.UIAbilityContext): Promise<string> {
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = 1
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      if (result.photoUris.length > 0) {
        let first = ''
        for (const uri of result.photoUris) {
          first = uri
          break
        }
        if (first.length > 0) {
          return PhotoPickService.cacheToAppFiles(context, first)
        }
      }
    } catch {
    }
    return ''
  }

  private static cacheToAppFiles(context: common.UIAbilityContext, srcUri: string): string {
    const destPath = `${context.filesDir}/cover_${Date.now()}.jpg`
    try {
      const src = fileIo.openSync(srcUri, fileIo.OpenMode.READ_ONLY)
      const dest = fileIo.openSync(destPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
      fileIo.copyFileSync(src.fd, dest.fd)
      fileIo.closeSync(src)
      fileIo.closeSync(dest)
      return MediaUriUtil.imageSrc(destPath)
    } catch {
      return MediaUriUtil.imageSrc(srcUri)
    }
  }
}
