/** 本地封面图 Image 源 — 鸿蒙 Image 需要 file:// 或完整 URI */
export class MediaUriUtil {
  static imageSrc(path: string): string {
    if (path.length === 0) {
      return ''
    }
    if (path.startsWith('file://') || path.startsWith('http://') || path.startsWith('https://')) {
      return path
    }
    if (path.indexOf('://') > 0) {
      return path
    }
    if (path.startsWith('/')) {
      return `file://${path}`
    }
    return path
  }
}
