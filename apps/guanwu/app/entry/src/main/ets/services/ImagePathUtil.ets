import { fileUri } from '@kit.CoreFileKit'

/** 沙箱路径 → Image 组件可显示的 URI（HarmonyOS 6.x 须 file://） */
export class ImagePathUtil {
  static toDisplayUri(path: string): string {
    if (path.length === 0) {
      return ''
    }
    if (path.startsWith('file://') || path.startsWith('datashare://') || path.startsWith('content://')) {
      return path
    }
    if (path.startsWith('/')) {
      return fileUri.getUriFromPath(path)
    }
    return path
  }

  static normalizeStored(path: string): string {
    if (path.length === 0) {
      return ''
    }
    if (path.startsWith('file://')) {
      return path
    }
    if (path.startsWith('/')) {
      return `file://${path}`
    }
    return path
  }

  static toRawPath(uri: string): string {
    if (uri.startsWith('file://')) {
      return uri.substring('file://'.length)
    }
    return uri
  }
}
