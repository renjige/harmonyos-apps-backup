export class CareerDetailNav {
  static open(kind: string, id: string): void {
    AppStorage.setOrCreate('careerRoute', `${kind}:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openBare(kind: string): void {
    AppStorage.setOrCreate('careerRoute', kind)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('careerRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static bump(): void {
    const n = AppStorage.get<number>('careerTick') ?? 0
    AppStorage.setOrCreate('careerTick', n + 1)
  }

  static kindOf(route: string): string {
    const i = route.indexOf(':')
    if (i < 0) {
      return route
    }
    return route.substring(0, i)
  }

  static idOf(route: string): string {
    const i = route.indexOf(':')
    if (i < 0) {
      return ''
    }
    return route.substring(i + 1)
  }

  static openLearn(courseId: string, chapterIndex: number = -1): void {
    AppStorage.setOrCreate('learnChapterIndex', chapterIndex)
    CareerDetailNav.open('learn', courseId)
  }
}
