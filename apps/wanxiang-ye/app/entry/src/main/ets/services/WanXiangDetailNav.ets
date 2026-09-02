export class WanXiangDetailNav {
  static open(id: string): void {
    AppStorage.setOrCreate('wanxiangDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('wanxiangDetailId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static currentId(): string {
    const v = AppStorage.get<string>('wanxiangDetailId')
    return v !== undefined ? v : ''
  }
}
