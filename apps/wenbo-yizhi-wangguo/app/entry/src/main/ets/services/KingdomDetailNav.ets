export class KingdomDetailNav {
  static open(kind: string, id: string, cta: string): void {
    AppStorage.setOrCreate('kkDetailKind', kind)
    AppStorage.setOrCreate('kkDetailId', id)
    AppStorage.setOrCreate('kkDetailCta', cta)
    AppStorage.setOrCreate('kkDetailOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('kkDetailOpen', false)
    const quiz = AppStorage.get<boolean>('kkQuizOpen') === true
    const result = AppStorage.get<boolean>('kkResultOpen') === true
    const daily = AppStorage.get<boolean>('kkDailyOpen') === true
    const collect = AppStorage.get<boolean>('kkCollectOpen') === true
    const settings = AppStorage.get<boolean>('kkSettingsOpen') === true
    const gate = AppStorage.get<boolean>('kkGateOpen') === true
    const diagnose = AppStorage.get<boolean>('kkDiagnoseOpen') === true
    if (!quiz && !result && !daily && !collect && !settings && !gate && !diagnose) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }
}
