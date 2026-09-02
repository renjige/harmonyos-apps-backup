/** 全局作品/教程详情导航 — MainTabPage 顶层 Overlay */
export class CraftDetailNav {
  static openWork(workId: string): void {
    AppStorage.setOrCreate('craftDetailGuideId', '')
    AppStorage.setOrCreate('craftDetailWorkId', workId)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('craftDetailToken') ?? 0
    AppStorage.setOrCreate('craftDetailToken', token + 1)
  }

  static openGuide(guideId: string): void {
    AppStorage.setOrCreate('craftDetailWorkId', '')
    AppStorage.setOrCreate('craftDetailGuideId', guideId)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('craftDetailToken') ?? 0
    AppStorage.setOrCreate('craftDetailToken', token + 1)
  }

  static close(): void {
    AppStorage.setOrCreate('craftDetailWorkId', '')
    AppStorage.setOrCreate('craftDetailGuideId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static closeGuide(): void {
    CraftDetailNav.close()
  }

  /** 关闭详情并切到创作 Tab（作品分段）— 须先于组件卸载调用 AppStorage */
  static goCreateTab(): void {
    AppStorage.setOrCreate('createHubSegment', 0)
    const token = AppStorage.get<number>('mainTabNavToken') ?? 0
    AppStorage.setOrCreate('mainTabNavToken', token + 1)
    AppStorage.setOrCreate('mainTabNavTarget', 2)
    AppStorage.setOrCreate('craftDetailWorkId', '')
    AppStorage.setOrCreate('craftDetailGuideId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static currentWorkId(): string {
    const v = AppStorage.get<string>('craftDetailWorkId')
    return v !== undefined && v !== null ? v : ''
  }

  static currentGuideId(): string {
    const v = AppStorage.get<string>('craftDetailGuideId')
    return v !== undefined && v !== null ? v : ''
  }

  static isOpen(): boolean {
    return CraftDetailNav.currentWorkId().length > 0 || CraftDetailNav.currentGuideId().length > 0
  }
}
