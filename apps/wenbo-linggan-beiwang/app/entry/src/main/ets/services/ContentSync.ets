/** 首页 / KPI / 转化流水线等业务数据变更后 bump，HomePage @StorageLink 全量重拉 */
export class ContentSync {
  static bump(): void {
    const n = AppStorage.get<number>('contentEpoch')
    const next = n !== undefined && n !== null ? n + 1 : 1
    AppStorage.setOrCreate('contentEpoch', next)
  }
}
