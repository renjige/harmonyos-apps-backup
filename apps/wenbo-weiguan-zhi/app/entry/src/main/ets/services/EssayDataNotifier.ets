export class EssayDataNotifier {
  static bump(): void {
    const cur = AppStorage.get<number>('essayDataEpoch') ?? 0
    AppStorage.setOrCreate('essayDataEpoch', cur + 1)
  }
}
