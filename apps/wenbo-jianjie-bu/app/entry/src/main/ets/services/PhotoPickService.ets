import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { common } from '@kit.AbilityKit'
import { ImagePathUtil } from './ImagePathUtil'

export class PhotoPickService {
  static lastError: string = ''

  static async pickOneImage(context: common.UIAbilityContext): Promise<string> {
    PhotoPickService.lastError = ''
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = 1
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      if (result.photoUris === undefined || result.photoUris.length === 0) {
        return ''
      }
      const saved = await PhotoPickService.copyToSandbox(context, result.photoUris[0])
      if (saved.length === 0) {
        PhotoPickService.lastError = '图片保存失败，请重试'
      }
      return saved
    } catch {
      PhotoPickService.lastError = '无法打开相册，请稍后重试'
      return ''
    }
  }

  private static async copyToSandbox(context: common.UIAbilityContext, uri: string): Promise<string> {
    const dir = `${context.filesDir}/insight_images`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // exists
    }
    const destPath = `${dir}/img_${Date.now()}.jpg`
    const copied = PhotoPickService.copyByFd(uri, destPath)
    if (copied.length > 0) {
      return copied
    }
    try {
      await fileIo.copyFile(uri, destPath)
      return ImagePathUtil.normalizeStored(destPath)
    } catch {
      return ''
    }
  }

  private static copyByFd(uri: string, destPath: string): string {
    let src: fileIo.File | null = null
    let destFile: fileIo.File | null = null
    try {
      src = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
      destFile = fileIo.openSync(destPath,
        fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC)
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
