import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { common } from '@kit.AbilityKit'
import { ImagePathUtil } from './ImagePathUtil'

export class PhotoPickService {
  static lastError: string = ''

  /** 系统 PhotoViewPicker 无需 READ_IMAGEVIDEO；选中后复制到应用沙箱 */
  static async pickImages(context: common.UIAbilityContext, maxCount: number): Promise<string[]> {
    PhotoPickService.lastError = ''
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = maxCount
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      const out: string[] = []
      if (result.photoUris === undefined) {
        return out
      }
      for (const uri of result.photoUris) {
        const saved = PhotoPickService.copyToSandbox(context, uri)
        if (saved.length > 0) {
          out.push(saved)
        }
      }
      if (out.length === 0 && result.photoUris.length > 0) {
        PhotoPickService.lastError = '图片保存失败，请重试'
      }
      return out
    } catch {
      PhotoPickService.lastError = '无法打开相册，请稍后重试'
      return []
    }
  }

  private static copyToSandbox(context: common.UIAbilityContext, uri: string): string {
    const dir = `${context.filesDir}/observe_images`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // already exists
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
          // ignore
        }
      }
      if (destFile !== null) {
        try {
          fileIo.closeSync(destFile)
        } catch {
          // ignore
        }
      }
    }
  }
}
