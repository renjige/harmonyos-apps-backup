import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { common } from '@kit.AbilityKit'

export class PhotoPickService {
  static async pickImages(context: common.UIAbilityContext, maxCount: number): Promise<string[]> {
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = maxCount
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      const out: string[] = []
      if (result.photoUris !== undefined) {
        for (const uri of result.photoUris) {
          const saved = PhotoPickService.copyToSandbox(context, uri)
          if (saved.length > 0) {
            out.push(saved)
          }
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static copyToSandbox(context: common.UIAbilityContext, uri: string): string {
    const dir = `${context.filesDir}/puzzle_images`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // exists
    }
    const dest = `${dir}/img_${Date.now()}_${Math.floor(Math.random() * 10000)}.jpg`
    let src: fileIo.File | null = null
    let destFile: fileIo.File | null = null
    try {
      src = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
      destFile = fileIo.openSync(dest, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC)
      fileIo.copyFileSync(src.fd, destFile.fd)
      return dest
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
