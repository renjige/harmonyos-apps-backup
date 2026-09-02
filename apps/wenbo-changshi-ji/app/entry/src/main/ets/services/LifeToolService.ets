import { DateFormatUtil } from '../components/design-system/DateFormatUtil'

/** 日期差、单位换算、节气、年龄（本地规则，无网络）。 */
export class LifeToolService {
  static daysBetween(fromKey: string, toKey: string): number {
    const a = DateFormatUtil.parseDate(fromKey).getTime()
    const b = DateFormatUtil.parseDate(toKey).getTime()
    return Math.round((b - a) / 86400000)
  }

  static ageYears(birthKey: string): number {
    const birth = DateFormatUtil.parseDate(birthKey)
    const now = new Date()
    let years = now.getFullYear() - birth.getFullYear()
    const mdNow = (now.getMonth() + 1) * 100 + now.getDate()
    const mdBirth = (birth.getMonth() + 1) * 100 + birth.getDate()
    if (mdNow < mdBirth) {
      years = years - 1
    }
    return years < 0 ? 0 : years
  }

  static cmToInch(cm: number): number {
    return Math.round(cm / 2.54 * 100) / 100
  }

  static inchToCm(inch: number): number {
    return Math.round(inch * 2.54 * 100) / 100
  }

  static kgToJin(kg: number): number {
    return Math.round(kg * 2 * 100) / 100
  }

  static jinToKg(jin: number): number {
    return Math.round(jin / 2 * 100) / 100
  }

  static cToF(c: number): number {
    return Math.round((c * 9 / 5 + 32) * 10) / 10
  }

  static fToC(f: number): number {
    return Math.round((f - 32) * 5 / 9 * 10) / 10
  }

  static solarTermNear(dateKey: string): string {
    const parts = dateKey.split('-')
    if (parts.length < 3) {
      return '请选择日期'
    }
    const m = Number.parseInt(parts[1], 10)
    const d = Number.parseInt(parts[2], 10)
    const md = m * 100 + d
    const terms: string[] = [
      '0105 小寒', '0120 大寒', '0204 立春', '0218 雨水', '0305 惊蛰', '0320 春分',
      '0404 清明', '0420 谷雨', '0505 立夏', '0521 小满', '0605 芒种', '0621 夏至',
      '0707 小暑', '0722 大暑', '0807 立秋', '0823 处暑', '0907 白露', '0923 秋分',
      '1008 寒露', '1023 霜降', '1107 立冬', '1122 小雪', '1207 大雪', '1221 冬至'
    ]
    let last = '冬至（上一节）'
    for (const row of terms) {
      const code = Number.parseInt(row.substring(0, 4), 10)
      const name = row.substring(5)
      if (md >= code) {
        last = name
      }
    }
    let next = '小寒'
    for (const row of terms) {
      const code = Number.parseInt(row.substring(0, 4), 10)
      const name = row.substring(5)
      if (code > md) {
        next = name
        break
      }
    }
    return `最近已过：${last}；下一节气：${next}（公历约值，供生活参考）`
  }
}
