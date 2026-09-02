/** 今日工作台统计刷新：任意本机数据写入后 bump，DailyPage 监听并 reload */
export class HomeRefresh {
  static bump(): void {
    const cur = AppStorage.get<number>('homeRefreshTick') ?? 0
    AppStorage.setOrCreate('homeRefreshTick', cur + 1)
  }
}
