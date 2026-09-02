import { fileUri } from '@kit.CoreFileKit'

/** 沙箱路径 → Image 可显示的 file:// URI（HarmonyOS 6 必加前缀） */
export class ImagePathUtil {
  static toDisplayUri(path: string): string {
    if (path.length === 0) {
      return ''
    }
    if (path.startsWith('file://') || path.startsWith('datashare://') || path.startsWith('content://')) {
      return path
    }
    if (path.startsWith('/')) {
      try {
        return fileUri.getUriFromPath(path)
      } catch {
        return `file://${path}`
      }
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
}
