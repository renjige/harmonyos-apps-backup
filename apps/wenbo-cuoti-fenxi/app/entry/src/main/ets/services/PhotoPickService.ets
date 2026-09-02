import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { camera, cameraPicker } from '@kit.CameraKit'

export class PhotoPickService {
  static async capture(context: common.UIAbilityContext): Promise<string> {
    try {
      const profile = new cameraPicker.PickerProfile()
      profile.cameraPosition = camera.CameraPosition.CAMERA_POSITION_BACK
      const types: Array<cameraPicker.PickerMediaType> = [cameraPicker.PickerMediaType.PHOTO]
      const result = await cameraPicker.pick(context, types, profile)
      if (result.resultCode === 0 && result.resultUri.length > 0) {
        return PhotoPickService.cacheToAppFiles(context, result.resultUri)
      }
    } catch {
    }
    return PhotoPickService.pickAlbum(context)
  }

  static async pickAlbum(context: common.UIAbilityContext): Promise<string> {
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = 1
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      if (result.photoUris.length > 0) {
        return PhotoPickService.cacheToAppFiles(context, result.photoUris[0])
      }
    } catch {
    }
    return ''
  }

  private static cacheToAppFiles(context: common.UIAbilityContext, srcUri: string): string {
    const stamp = Date.now()
    const destPath = `${context.filesDir}/cuoti_${stamp}.jpg`
    try {
      const src = fileIo.openSync(srcUri, fileIo.OpenMode.READ_ONLY)
      const dest = fileIo.openSync(destPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
      fileIo.copyFileSync(src.fd, dest.fd)
      fileIo.closeSync(src)
      fileIo.closeSync(dest)
      return `file://${destPath}`
    } catch {
      return srcUri
    }
  }
}
