export class TrainingDetailNav {
  static open(recordId: string): void {
    AppStorage.setOrCreate('trainingDetailId', recordId)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('trainingDetailId', '')
    TrainingDetailNav.restoreTabBar()
  }

  static openQuest(questId: string): void {
    AppStorage.setOrCreate('questDetailId', questId)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeQuest(): void {
    AppStorage.setOrCreate('questDetailId', '')
    TrainingDetailNav.restoreTabBar()
  }

  static openRecap(): void {
    AppStorage.setOrCreate('showRecap', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeRecap(): void {
    AppStorage.setOrCreate('showRecap', false)
    TrainingDetailNav.restoreTabBar()
  }

  static restoreTabBar(): void {
    const rec = AppStorage.get<string>('trainingDetailId') ?? ''
    const quest = AppStorage.get<string>('questDetailId') ?? ''
    const form = AppStorage.get<boolean>('showTrainingForm') === true
    const qForm = AppStorage.get<boolean>('showQuestForm') === true
    const recap = AppStorage.get<boolean>('showRecap') === true
    const hub = AppStorage.get<string>('practiceHubKind') ?? ''
    const hidden = rec.length > 0 || quest.length > 0 || form || qForm || recap || hub.length > 0
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }
}
