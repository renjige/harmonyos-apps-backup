import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { common } from '@kit.AbilityKit'
import { ImagePathUtil } from './ImagePathUtil'

/** 系统 PhotoViewPicker；复制到沙箱并校验文件大小，避免空文件被当成成功 */
export class PhotoPickService {
  static lastError: string = ''

  static async pickImages(context: common.UIAbilityContext, maxCount: number): Promise<string[]> {
    PhotoPickService.lastError = ''
    if (context === undefined || context === null) {
      PhotoPickService.lastError = '无法获取应用上下文，请重启应用后重试'
      return []
    }
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = maxCount > 0 ? maxCount : 1
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      if (result.photoUris === undefined || result.photoUris.length === 0) {
        return []
      }
      const out: string[] = []
      for (const uri of result.photoUris) {
        const saved = await PhotoPickService.copyToSandbox(context, uri)
        if (saved.length > 0) {
          out.push(saved)
        }
      }
      if (out.length === 0 && result.photoUris.length > 0) {
        PhotoPickService.lastError = '图片保存失败，请重试或更换照片'
      }
      return out
    } catch {
      PhotoPickService.lastError = '无法打开相册，请稍后重试'
      return []
    }
  }

  private static async copyToSandbox(context: common.UIAbilityContext, uri: string): Promise<string> {
    const dir = `${context.filesDir}/journal_images`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // exists
    }
    const destPath = `${dir}/img_${Date.now()}_${Math.floor(Math.random() * 10000)}.jpg`
    const byFd = PhotoPickService.copyByFd(uri, destPath)
    if (PhotoPickService.isUsableFile(byFd.length > 0 ? destPath : '')) {
      return ImagePathUtil.normalizeStored(destPath)
    }
    try {
      await fileIo.copyFile(uri, destPath)
      if (PhotoPickService.isUsableFile(destPath)) {
        return ImagePathUtil.normalizeStored(destPath)
      }
    } catch {
      // fall through
    }
    return ''
  }

  private static isUsableFile(path: string): boolean {
    if (path.length === 0) {
      return false
    }
    try {
      const st = fileIo.statSync(path)
      return st.size >= 64
    } catch {
      return false
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
      return destPath
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
