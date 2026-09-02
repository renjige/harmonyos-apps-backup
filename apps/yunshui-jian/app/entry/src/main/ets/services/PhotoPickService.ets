import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { common } from '@kit.AbilityKit'
import { ImagePathUtil } from './ImagePathUtil'

export class PhotoPickService {
  static async pickImages(context: common.UIAbilityContext, maxCount: number): Promise<string[]> {
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = maxCount
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      if (result.photoUris === undefined || result.photoUris.length === 0) {
        return []
      }
      const out: string[] = []
      for (const uri of result.photoUris) {
        const copied = PhotoPickService.copyToSandbox(context, uri)
        if (copied.length > 0) {
          out.push(copied)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static copyToSandbox(context: common.UIAbilityContext, uri: string): string {
    const dir = `${context.filesDir}/life_note_images`
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
