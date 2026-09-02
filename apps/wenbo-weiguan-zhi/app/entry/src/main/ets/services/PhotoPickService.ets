import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { common } from '@kit.AbilityKit'
import { ImagePathUtil } from './ImagePathUtil'

export class PhotoPickService {
  static lastError: string = ''

  static async pickAlbum(context: common.UIAbilityContext): Promise<string> {
    PhotoPickService.lastError = ''
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = 1
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      if (result.photoUris === undefined || result.photoUris.length === 0) {
        PhotoPickService.lastError = '未选择图片'
        return ''
      }
      const saved = PhotoPickService.copyToSandbox(context, result.photoUris[0])
      if (saved.length === 0) {
        PhotoPickService.lastError = '图片保存失败，请重试'
      }
      return saved
    } catch {
      PhotoPickService.lastError = '无法打开相册，请稍后重试'
      return ''
    }
  }

  private static copyToSandbox(context: common.UIAbilityContext, uri: string): string {
    const dir = `${context.filesDir}/essay_images`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // exists
    }
    const destPath = `${dir}/img_${Date.now()}_${Math.floor(Math.random() * 1000)}.jpg`
    let src: fileIo.File | null = null
    let destFile: fileIo.File | null = null
    try {
      src = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
      destFile = fileIo.openSync(destPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC)
      fileIo.copyFileSync(src.fd, destFile.fd)
      return ImagePathUtil.normalizeStored(destPath)
    } catch {
      return ''
    } finally {
      if (src !== null) {
        try {
          fileIo.closeSync(src)
        } catch {
        }
      }
      if (destFile !== null) {
        try {
          fileIo.closeSync(destFile)
        } catch {
        }
      }
    }
  }
}
