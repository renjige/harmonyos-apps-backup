/** 全局 UI 刷新令牌 — 写操作后统一 bump，保证首页/成长/我的统计同步 */
export class AppRefresh {
  static bumpHub(): void {
    AppStorage.setOrCreate('hubRefresh', Date.now())
  }

  static bumpResearch(): void {
    AppStorage.setOrCreate('researchHubRefresh', Date.now())
    AppStorage.setOrCreate('researchRefresh', Date.now())
    AppRefresh.bumpHub()
  }

  static bumpFav(): void {
    AppStorage.setOrCreate('favRefresh', Date.now())
    AppRefresh.bumpHub()
  }

  static bumpRecord(): void {
    AppStorage.setOrCreate('recordRefresh', Date.now())
    AppRefresh.bumpHub()
  }
}
