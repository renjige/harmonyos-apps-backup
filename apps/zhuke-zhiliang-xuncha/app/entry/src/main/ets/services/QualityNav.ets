import { QualityStatsBus } from './QualityStatsBus'

export class QualityNav {
  static open(kind: string, id: string = '', extra: string = ''): void {
    AppStorage.setOrCreate('qualityKind', kind)
    AppStorage.setOrCreate('qualityId', id)
    AppStorage.setOrCreate('qualityExtra', extra)
    const hideBar = kind.length > 0 && kind !== 'none'
    AppStorage.setOrCreate('tabBarHidden', hideBar)
  }

  static close(): void {
    AppStorage.setOrCreate('qualityKind', 'none')
    AppStorage.setOrCreate('qualityId', '')
    AppStorage.setOrCreate('qualityExtra', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    QualityStatsBus.publish()
    QualityNav.bump()
  }

  static toast(message: string): void {
    AppStorage.setOrCreate('qualityToast', message)
  }

  static bump(): void {
    QualityStatsBus.publish()
    const n = AppStorage.get<number>('qualityTick') ?? 0
    AppStorage.setOrCreate('qualityTick', n + 1)
    AppStorage.setOrCreate('qualityDataVersion', `${Date.now()}`)
  }

  static setTab(index: number): void {
    AppStorage.setOrCreate('qualityTab', index)
  }

  static setIssueFilter(filter: string): void {
    AppStorage.setOrCreate('issueFilter', filter)
  }
}
