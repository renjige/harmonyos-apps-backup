export type MathDetailKind = 'mode' | 'challenge' | 'medal' | 'tip'

export class MathDetailRoute {
  kind: MathDetailKind = 'mode'
  id: string = ''
}

export class MathDetailNav {
  static open(kind: MathDetailKind, id: string): void {
    AppStorage.setOrCreate('mathDetailKind', kind)
    AppStorage.setOrCreate('mathDetailId', id)
    AppStorage.setOrCreate('mathDetailOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('mathDetailOpen', false)
    AppStorage.setOrCreate('mathDetailId', '')
    const quiz = AppStorage.get<boolean>('mathQuizOpen') === true
    const result = AppStorage.get<boolean>('mathResultOpen') === true
    const wrong = AppStorage.get<boolean>('mathWrongOpen') === true
    const settings = AppStorage.get<boolean>('mathSettingsOpen') === true
    if (!quiz && !result && !wrong && !settings) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }
}
