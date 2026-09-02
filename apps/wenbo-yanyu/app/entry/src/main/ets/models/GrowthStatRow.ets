/** 成长 / 知识统计展示行 */
export class GrowthStatRow {
  key: string = ''
  label: string = ''
  valueText: string = '0'

  static of(key: string, label: string, value: number | string): GrowthStatRow {
    const row = new GrowthStatRow()
    row.key = key
    row.label = label
    row.valueText = `${value}`
    return row
  }
}
