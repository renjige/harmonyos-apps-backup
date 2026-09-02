import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { common } from '@kit.AbilityKit'
import { ImagePathUtil } from './ImagePathUtil'

export class PhotoPickService {
  static lastError: string = ''

  static async pickImages(context: common.UIAbilityContext, maxCount: number): Promise<string[]> {
    PhotoPickService.lastError = ''
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = maxCount
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      const out: string[] = []
      if (result.photoUris !== undefined) {
        for (const uri of result.photoUris) {
          const saved = await PhotoPickService.copyToSandbox(context, uri)
          if (saved.length > 0) {
            out.push(saved)
          }
        }
      }
      if (out.length === 0) {
        PhotoPickService.lastError = '未能保存所选照片，请重试'
      }
      return out
    } catch {
      PhotoPickService.lastError = '无法打开系统相册'
      return []
    }
  }

  private static async copyToSandbox(context: common.UIAbilityContext, uri: string): Promise<string> {
    const dir = `${context.filesDir}/album_photos`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // exists
    }
    const destPath = `${dir}/img_${Date.now()}_${Math.floor(Math.random() * 10000)}.jpg`
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

  static estimateFileSize(uri: string): number {
    let path = uri
    if (path.startsWith('file://')) {
      path = path.substring(7)
    }
    try {
      const stat = fileIo.statSync(path)
      return stat.size
    } catch {
      return 0
    }
  }
}
