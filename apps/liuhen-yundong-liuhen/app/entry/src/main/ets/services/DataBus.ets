import { StatsService } from './StatsService'

export class DataBus {
  private static refreshing: boolean = false

  static init(): void {
    AppStorage.setOrCreate('dataEpoch', 0)
    AppStorage.setOrCreate('activeTab', 0)
  }

  static bump(): void {
    const n = (AppStorage.get<number>('dataEpoch') ?? 0) + 1
    AppStorage.setOrCreate('dataEpoch', n)
  }

  static setTab(index: number): void {
    AppStorage.setOrCreate('activeTab', index)
  }

  /** 写入后统一刷新：首页统计 + 全局 dataEpoch（各 Tab 监听后重载） */
  static async refreshAll(): Promise<void> {
    if (DataBus.refreshing) {
      return
    }
    DataBus.refreshing = true
    try {
      await StatsService.publishHomeStats()
      DataBus.bump()
    } finally {
      DataBus.refreshing = false
    }
  }
}
