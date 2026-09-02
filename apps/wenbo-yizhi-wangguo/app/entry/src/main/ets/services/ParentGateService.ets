export class ParentGateService {
  static a: number = 3
  static b: number = 4

  static refresh(): void {
    ParentGateService.a = 2 + Math.floor(Math.random() * 8)
    ParentGateService.b = 2 + Math.floor(Math.random() * 8)
  }

  static prompt(): string {
    return `${ParentGateService.a} + ${ParentGateService.b} = ?`
  }

  static check(answer: string): boolean {
    const n = Number.parseInt(answer)
    if (Number.isNaN(n)) {
      return false
    }
    return n === ParentGateService.a + ParentGateService.b
  }

  static isVerified(): boolean {
    const until = AppStorage.get<number>('kkGateUntil') ?? 0
    return until > Date.now()
  }

  static markVerified(): void {
    AppStorage.setOrCreate('kkGateUntil', Date.now() + 10 * 60 * 1000)
  }
}
