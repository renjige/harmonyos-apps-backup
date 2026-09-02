export class ImagePathUtil {
  static normalizeStored(path: string): string {
    if (path.startsWith('file://')) {
      return path
    }
    if (path.startsWith('/')) {
      return `file://${path}`
    }
    return path
  }

  static displayUri(path: string): string {
    if (path.length === 0) {
      return ''
    }
    if (path.startsWith('file://') || path.startsWith('http')) {
      return path
    }
    return `file://${path}`
  }
}
