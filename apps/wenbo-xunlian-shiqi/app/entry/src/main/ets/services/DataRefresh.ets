export class DataRefresh {
  static bump(): void {
    const n = (AppStorage.get<number>('dataEpoch') ?? 0) + 1
    AppStorage.setOrCreate('dataEpoch', n)
  }
}
