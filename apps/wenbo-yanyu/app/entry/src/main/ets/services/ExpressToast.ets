/** 表达 Tab 顶层 Toast（固定在标题栏下，不被 Scroll 遮挡） */
export class ExpressToast {
  static show(message: string): void {
    AppStorage.setOrCreate('expressToast', message)
    AppStorage.setOrCreate('expressToastTick', Date.now())
    setTimeout((): void => {
      const current = AppStorage.get<string>('expressToast')
      if (current === message) {
        AppStorage.setOrCreate('expressToast', '')
      }
    }, 2600)
  }
}
