/** 赛途计划 / 节点等数据变更信号，驱动列表 ForEach 即时刷新 */
export class SaituRefreshSignals {
  static bumpTrackEpoch(): void {
    const n = (AppStorage.get<number>('saituTrackEpoch') ?? 0) + 1
    AppStorage.setOrCreate('saituTrackEpoch', n)
  }
}
