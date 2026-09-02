/** 我的页统计卡片数据 */
export class MineStatTile {
  key: string = ''
  label: string = ''
  valueText: string = '0'

  static of(key: string, label: string, value: number): MineStatTile {
    const row = new MineStatTile()
    row.key = key
    row.label = label
    row.valueText = `${value}`
    return row
  }
}
