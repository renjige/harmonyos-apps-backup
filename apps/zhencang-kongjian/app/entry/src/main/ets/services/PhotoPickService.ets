import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { common } from '@kit.AbilityKit'
import { ImagePathUtil } from './ImagePathUtil'

export class PhotoPickService {
  static lastError: string = ''

  static async pickImage(context: common.UIAbilityContext): Promise<string> {
    const list = await PhotoPickService.pickImages(context, 1)
    if (list.length > 0) {
      return list[0]
    }
    return ''
  }

  static async pickImages(context: common.UIAbilityContext, maxCount: number): Promise<string[]> {
    PhotoPickService.lastError = ''
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
        PhotoPickService.lastError = '图片保存失败，请重试'
      }
      return out
    } catch {
      PhotoPickService.lastError = '无法打开系统相册'
      return []
    }
  }

  private static async copyToSandbox(context: common.UIAbilityContext, uri: string): Promise<string> {
    const dir = `${context.filesDir}/treasure_photos`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // exists
    }
    const destPath = `${dir}/img_${Date.now()}_${Math.floor(Math.random() * 10000)}.jpg`
    try {
      await fileIo.copyFile(uri, destPath)
      if (PhotoPickService.isUsable(destPath)) {
        return ImagePathUtil.normalizeStored(destPath)
      }
    } catch {
      // fall through
    }
    return ''
  }

  private static isUsable(path: string): boolean {
    try {
      const st = fileIo.statSync(path)
      return st.size >= 64
    } catch {
      return false
    }
  }
}
