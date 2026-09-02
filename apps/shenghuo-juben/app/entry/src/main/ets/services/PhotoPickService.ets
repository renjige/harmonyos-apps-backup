import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { common } from '@kit.AbilityKit'

export class PhotoPickService {
  /** PhotoViewPicker 无需 READ_IMAGEVIDEO；选中后复制到应用沙箱 */
  static async pickOneImage(context: common.UIAbilityContext): Promise<string> {
    const list = await PhotoPickService.pickImages(context, 1)
    if (list.length === 0) {
      return ''
    }
    return list[0]
  }

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
    const dir = `${context.filesDir}/script_images`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // already exists
    }
    const dest = `${dir}/img_${Date.now()}_${Math.floor(Math.random() * 1000)}.jpg`
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
