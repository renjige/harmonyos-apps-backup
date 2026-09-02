/** 全局 Toast：MainTabPage 顶层展示，避免被 Overlay / Tab 遮挡 */
export class ExploreToast {
  static show(message: string): void {
    if (message.length === 0) {
      return
    }
    AppStorage.setOrCreate('globalToast', message)
    const tick = (AppStorage.get<number>('globalToastTick') ?? 0) + 1
    AppStorage.setOrCreate('globalToastTick', tick)
  }
}
