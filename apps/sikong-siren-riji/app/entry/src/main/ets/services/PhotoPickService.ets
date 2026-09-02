import { photoAccessHelper } from '@kit.MediaLibraryKit'

/**
 * 使用系统 PhotoViewPicker，无需申请 READ_IMAGEVIDEO 等 ACL 权限。
 * 用户选图后仅获得临时 URI，符合隐私最小化原则。
 */
export class PhotoPickService {
  static async pickImages(maxCount: number): Promise<string[]> {
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = maxCount
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      const out: string[] = []
      if (result.photoUris !== undefined) {
        for (const uri of result.photoUris) {
          out.push(uri)
        }
      }
      return out
    } catch {
      return []
    }
  }
}
