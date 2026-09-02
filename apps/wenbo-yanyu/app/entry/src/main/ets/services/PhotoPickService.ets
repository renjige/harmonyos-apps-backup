import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { common } from '@kit.AbilityKit'
import { ImagePathUtil } from './ImagePathUtil'

/** 系统相册选择器，不申请 READ_IMAGEVIDEO；复制到沙箱后以 file:// 存取 */
export class PhotoPickService {
  static async pickOneImage(context: common.UIAbilityContext): Promise<string> {
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = 1
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      if (result.photoUris === undefined || result.photoUris.length === 0) {
        return ''
      }
      let uri = ''
      for (const u of result.photoUris) {
        uri = u
        break
      }
      if (uri.length === 0) {
        return ''
      }
      return PhotoPickService.copyToSandbox(context, uri)
    } catch {
      return ''
    }
  }

  private static copyToSandbox(context: common.UIAbilityContext, uri: string): string {
    const dir = `${context.filesDir}/research_images`
    try {
      fileIo.mkdirSync(dir)
    } catch {
    }
    const dest = `${dir}/img_${Date.now()}_${Math.floor(Math.random() * 10000)}.jpg`
    try {
      fileIo.copyFileSync(uri, dest)
      return ImagePathUtil.normalizeStored(dest)
    } catch {
    }
    let src: fileIo.File | null = null
    let destFile: fileIo.File | null = null
    try {
      src = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
      destFile = fileIo.openSync(dest, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
      fileIo.copyFileSync(src.fd, destFile.fd)
      return ImagePathUtil.normalizeStored(dest)
    } catch {
      if (uri.startsWith('file://') || uri.startsWith('datashare://') || uri.startsWith('content://')) {
        return uri
      }
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
