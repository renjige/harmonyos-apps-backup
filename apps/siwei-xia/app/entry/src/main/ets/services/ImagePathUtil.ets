import { fileIo } from '@kit.CoreFileKit'
import { fileUri } from '@kit.CoreFileKit'

/** 沙箱路径 → Image 组件可显示的 URI（HarmonyOS 6.x 需 file:// 或 getUriFromPath） */
export class ImagePathUtil {
  static normalizeStored(path: string): string {
    if (path.length === 0) {
      return ''
    }
    if (path.startsWith('file://') || path.startsWith('datashare://') || path.startsWith('content://')) {
      return path
    }
    if (path.startsWith('/')) {
      return `file://${path}`
    }
    return path
  }

  static toDisplayUri(path: string): string {
    if (path.length === 0) {
      return ''
    }
    const stored = ImagePathUtil.normalizeStored(path)
    if (stored.startsWith('datashare://') || stored.startsWith('content://')) {
      return stored
    }
    const raw = stored.startsWith('file://') ? stored.substring(7) : stored
    if (raw.startsWith('/')) {
      try {
        return fileUri.getUriFromPath(raw)
      } catch {
        return stored
      }
    }
    return stored
  }

  static isReadable(path: string): boolean {
    const raw = ImagePathUtil.rawPath(path)
    if (raw.length === 0) {
      return false
    }
    try {
      const st = fileIo.statSync(raw)
      return st.size >= 64
    } catch {
      return false
    }
  }

  static rawPath(path: string): string {
    if (path.length === 0) {
      return ''
    }
    if (path.startsWith('file://')) {
      return path.substring(7)
    }
    return path
  }
}
