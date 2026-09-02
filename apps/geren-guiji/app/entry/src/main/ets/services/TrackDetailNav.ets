export class TrackDetailRoute {
  trackId: string = ''
}

export class TrackDetailNav {
  static open(trackId: string): void {
    AppStorage.setOrCreate('trackDetailId', trackId)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('trackDetailId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static currentId(): string {
    const v = AppStorage.get<string>('trackDetailId')
    return v !== undefined ? v : ''
  }
}
