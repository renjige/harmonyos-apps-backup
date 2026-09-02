import { pasteboard } from '@kit.BasicServicesKit'
import { SportRecord, SportTypeOption } from '../models/SportRecord'

/** 规则模板报告：用用户自己的记录算出可执行结论，不是浏览页。 */
export class TransformReport {
  headline: string = ''
  firstDate: string = ''
  lastDate: string = ''
  daysSpan: number = 0
  sessionCount: number = 0
  streak: number = 0
  lastGapDays: number = 0
  weightDelta: number = 0
  distanceDelta: number = 0
  durationDelta: number = 0
  topSport: string = ''
  nextAction: string = ''
  weekBars: WeekBarItem[] = []
}

export class WeekBarItem {
  label: string = ''
  count: number = 0
}

export class CompareDelta {
  weightText: string = '—'
  distanceText: string = '—'
  durationText: string = '—'
  daysBetween: number = 0
}

export class TransformReportService {
  static build(list: SportRecord[]): TransformReport {
    const report = new TransformReport()
    report.weekBars = TransformReportService.toWeekBars(TransformReportService.last7Counts(list))
    if (list.length === 0) {
      report.headline = '还没有记录。拍下第一次运动，图册才会开始讲述蜕变。'
      report.nextAction = '去「记录」页添加照片和数据'
      return report
    }
    const chrono = TransformReportService.sortByDate(list)
    const first = chrono[0]
    const last = chrono[chrono.length - 1]
    report.firstDate = first.date
    report.lastDate = last.date
    report.sessionCount = list.length
    report.daysSpan = Math.max(1, TransformReportService.dayIndex(last.date) - TransformReportService.dayIndex(first.date) + 1)
    report.streak = TransformReportService.streakFrom(list, last.date)
    report.lastGapDays = Math.max(0, TransformReportService.dayIndex(SportRecord.formatDate(new Date())) - TransformReportService.dayIndex(last.date))
    report.weightDelta = TransformReportService.signedDelta(first.weight, last.weight)
    report.distanceDelta = TransformReportService.signedDelta(first.distance, last.distance)
    report.durationDelta = TransformReportService.signedDelta(first.duration, last.duration)
    report.topSport = SportTypeOption.labelOf(TransformReportService.topType(list))
    report.headline = TransformReportService.headlineOf(report)
    report.nextAction = TransformReportService.nextOf(report)
    return report
  }

  static delta(left: SportRecord | undefined, right: SportRecord | undefined): CompareDelta {
    const d = new CompareDelta()
    if (left === undefined || right === undefined) {
      return d
    }
    d.daysBetween = Math.abs(TransformReportService.dayIndex(right.date) - TransformReportService.dayIndex(left.date))
    d.weightText = TransformReportService.fmtDelta(left.weight, right.weight, 'kg')
    d.distanceText = TransformReportService.fmtDelta(left.distance, right.distance, 'km')
    d.durationText = TransformReportService.fmtDelta(left.duration, right.duration, '分钟')
    return d
  }

  static shareText(report: TransformReport): string {
    const lines: string[] = []
    lines.push('运动图册 · 本期蜕变报告')
    lines.push(report.headline)
    lines.push(`跨度 ${report.daysSpan} 天 · ${report.sessionCount} 次 · 连续 ${report.streak} 天`)
    lines.push(`体重变化 ${report.weightDelta} kg · 距离 ${report.distanceDelta} km`)
    lines.push(`下一步：${report.nextAction}`)
    lines.push('— 蜕变影像 · 运动图册')
    return lines.join('\n')
  }

  static async copyReport(report: TransformReport): Promise<boolean> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, TransformReportService.shareText(report))
      await pasteboard.getSystemPasteboard().setData(data)
      return true
    } catch {
      return false
    }
  }

  private static headlineOf(r: TransformReport): string {
    if (r.sessionCount === 1) {
      return `第 1 次已定格。再记一次，就能对照出 ${r.topSport} 的变化。`
    }
    if (r.weightDelta < 0) {
      return `${r.daysSpan} 天里完成 ${r.sessionCount} 次${r.topSport}，体重变化 ${r.weightDelta} kg。`
    }
    if (r.distanceDelta > 0) {
      return `从 ${r.firstDate} 到 ${r.lastDate}，单次距离提升 ${r.distanceDelta} km。`
    }
    return `${r.daysSpan} 天积累 ${r.sessionCount} 次${r.topSport}，连续活跃 ${r.streak} 天。`
  }

  private static nextOf(r: TransformReport): string {
    if (r.lastGapDays === 0) {
      return '今日已记录。明天用同一机位再拍一张，对比更准。'
    }
    if (r.lastGapDays === 1) {
      return '间隔一天。适合轻松有氧或拉伸，打开「记录」补一张状态照。'
    }
    if (r.lastGapDays <= 3) {
      return `已停 ${r.lastGapDays} 天。建议 20 分钟短训并拍照，避免断档。`
    }
    return `已 ${r.lastGapDays} 天未记录。从一次短时${r.topSport.length > 0 ? r.topSport : '运动'}重新接上图册。`
  }

  private static sortByDate(list: SportRecord[]): SportRecord[] {
    const copy: SportRecord[] = []
    for (const it of list) {
      copy.push(it)
    }
    copy.sort((a: SportRecord, b: SportRecord) => a.date.localeCompare(b.date))
    return copy
  }

  private static topType(list: SportRecord[]): string {
    const map = new Map<string, number>()
    for (const it of list) {
      map.set(it.sportType, (map.get(it.sportType) ?? 0) + 1)
    }
    let best = 'other'
    let n = 0
    map.forEach((count: number, key: string) => {
      if (count > n) {
        n = count
        best = key
      }
    })
    return best
  }

  private static streakFrom(list: SportRecord[], lastDate: string): number {
    const set = new Set<string>()
    for (const it of list) {
      set.add(it.date)
    }
    let streak = 0
    let cursor = lastDate
    while (set.has(cursor)) {
      streak++
      cursor = TransformReportService.shiftDate(cursor, -1)
    }
    return streak
  }

  private static toWeekBars(counts: number[]): WeekBarItem[] {
    const labels: string[] = ['6天前', '5', '4', '3', '2', '昨', '今']
    const out: WeekBarItem[] = []
    for (let i = 0; i < labels.length; i++) {
      const item = new WeekBarItem()
      item.label = labels[i]
      item.count = i < counts.length ? counts[i] : 0
      out.push(item)
    }
    return out
  }

  private static last7Counts(list: SportRecord[]): number[] {
    const counts: number[] = [0, 0, 0, 0, 0, 0, 0]
    const today = TransformReportService.dayIndex(SportRecord.formatDate(new Date()))
    for (const it of list) {
      const diff = today - TransformReportService.dayIndex(it.date)
      if (diff >= 0 && diff <= 6) {
        counts[6 - diff]++
      }
    }
    return counts
  }

  private static dayIndex(key: string): number {
    const parts = key.split('-')
    if (parts.length < 3) {
      return 0
    }
    const d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10))
    return Math.floor(d.getTime() / 86400000)
  }

  private static shiftDate(key: string, delta: number): string {
    const parts = key.split('-')
    if (parts.length < 3) {
      return key
    }
    const d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10))
    d.setDate(d.getDate() + delta)
    return SportRecord.formatDate(d)
  }

  private static signedDelta(from: number, to: number): number {
    if (from <= 0 || to <= 0) {
      return 0
    }
    return Math.round((to - from) * 10) / 10
  }

  private static fmtDelta(from: number, to: number, unit: string): string {
    if (from <= 0 || to <= 0) {
      return '—'
    }
    const d = Math.round((to - from) * 10) / 10
    const sign = d > 0 ? '+' : ''
    return `${sign}${d} ${unit}`
  }
}
