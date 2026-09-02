/** 全局 Toast — 统一写入 AppStorage 并在 MainTabPage 顶层展示 */
export class AppToast {
  static show(message: string, durationMs: number = 2800): void {
    AppStorage.setOrCreate('toastText', message)
    setTimeout((): void => {
      const current = AppStorage.get<string>('toastText') ?? ''
      if (current === message) {
        AppStorage.setOrCreate('toastText', '')
      }
    }, durationMs)
  }
}
