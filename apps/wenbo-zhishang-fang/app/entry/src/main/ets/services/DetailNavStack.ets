export class DetailNavStack {
  private static ids: string[] = []

  static push(id: string): void {
    if (id.length === 0) {
      return
    }
    const last = DetailNavStack.ids.length > 0 ? DetailNavStack.ids[DetailNavStack.ids.length - 1] : ''
    if (last === id) {
      return
    }
    DetailNavStack.ids.push(id)
  }

  static pop(): string {
    if (DetailNavStack.ids.length === 0) {
      return ''
    }
    DetailNavStack.ids.pop()
    if (DetailNavStack.ids.length === 0) {
      return ''
    }
    return DetailNavStack.ids[DetailNavStack.ids.length - 1]
  }

  static clear(): void {
    DetailNavStack.ids = []
  }

  static current(): string {
    if (DetailNavStack.ids.length === 0) {
      return ''
    }
    return DetailNavStack.ids[DetailNavStack.ids.length - 1]
  }

  static canBack(): boolean {
    return DetailNavStack.ids.length > 1
  }
}
