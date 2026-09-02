import { InspirationItem } from '../models/InspirationModels'
import { WeeklyReviewReport } from '../models/WorkbenchModels'

/** 本周复盘：按本周记录/收藏/画板计数生成模板报告，非生成式文本 */
export class WeeklyReviewService {
  static weekStartIso(): string {
    const d = new Date()
    const day = d.getDay()
    const offset = day === 0 ? 6 : day - 1
    d.setDate(d.getDate() - offset)
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const dd = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = dd < 10 ? `0${dd}` : `${dd}`
    return `${y}-${ms}-${ds}`
  }

  static weekLabel(): string {
    const start = WeeklyReviewService.weekStartIso()
    const parts = start.split('-')
    if (parts.length >= 3) {
      return `${parts[1]}月${parts[2]}日起 · 本周复盘`
    }
    return '本周复盘'
  }

  static todayIso(): string {
    const d = new Date()
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const dd = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = dd < 10 ? `0${dd}` : `${dd}`
    return `${y}-${ms}-${ds}`
  }

  static monthPrefix(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${d.getFullYear()}-${ms}`
  }

  static periodLabel(period: string): string {
    if (period === 'today') {
      return '今日回顾'
    }
    if (period === 'month') {
      return '本月回顾'
    }
    return WeeklyReviewService.weekLabel()
  }

  static inPeriod(iso: string, period: string): boolean {
    if (iso.length < 10) {
      return false
    }
    const day = iso.substring(0, 10)
    if (period === 'today') {
      return day === WeeklyReviewService.todayIso()
    }
    if (period === 'month') {
      return day.indexOf(WeeklyReviewService.monthPrefix()) === 0
    }
    return WeeklyReviewService.inThisWeek(day, WeeklyReviewService.weekStartIso())
  }

  static inThisWeek(iso: string, weekStart: string): boolean {
    if (iso.length < 10) {
      return false
    }
    return iso.substring(0, 10) >= weekStart
  }

  static itemDate(item: InspirationItem): string {
    if (item.recordDate.length >= 10) {
      return item.recordDate.substring(0, 10)
    }
    if (item.createdAt.length >= 10) {
      return item.createdAt.substring(0, 10)
    }
    return ''
  }

  static build(
    inspirations: InspirationItem[],
    favorites: InspirationItem[],
    boards: InspirationItem[],
    period: string = 'week'
  ): WeeklyReviewReport {
    const report = new WeeklyReviewReport()
    report.weekLabel = WeeklyReviewService.periodLabel(period)
    report.generatedAt = new Date().toISOString().slice(0, 16).replace('T', ' ')

    let capture = 0
    const tagCount: string[] = []
    const tagSeen: string[] = []
    for (const it of inspirations) {
      if (WeeklyReviewService.inPeriod(WeeklyReviewService.itemDate(it), period)) {
        capture += 1
        for (const t of it.tags) {
          const name = t.trim()
          if (name.length === 0) {
            continue
          }
          let found = false
          for (const existing of tagSeen) {
            if (existing === name) {
              found = true
              break
            }
          }
          if (!found) {
            tagSeen.push(name)
            tagCount.push(name)
          }
        }
      }
    }

    let ownBoards = 0
    for (const b of boards) {
      if (b.kind !== 'showcase' && WeeklyReviewService.inPeriod(WeeklyReviewService.itemDate(b), period)) {
        ownBoards += 1
      }
    }

    let favCount = 0
    for (const f of favorites) {
      if (WeeklyReviewService.inPeriod(WeeklyReviewService.itemDate(f), period)) {
        favCount += 1
      }
    }
    if (period !== 'today' && favCount === 0) {
      favCount = favorites.length
    }

    report.captureCount = capture
    report.favoriteCount = favCount
    report.boardCount = ownBoards
    if (tagCount.length === 0) {
      report.tagLine = '这个时段标签尚未形成，记录时加上逗号分隔的标签便于整理。'
    } else if (tagCount.length <= 3) {
      report.tagLine = `出现的标签：${tagCount.join('、')}。`
    } else {
      report.tagLine = `出现的标签：${tagCount[0]}、${tagCount[1]}、${tagCount[2]} 等 ${tagCount.length} 个。`
    }

    const rangeWord = period === 'today' ? '今天' : (period === 'month' ? '本月' : '本周')
    if (capture === 0) {
      report.summary =
        `${rangeWord}还没有新的灵感记录。用今日提示写一条，保存时可钉到画板，回顾会立刻有内容可看。`
      report.captureNote = `捕捉：0 条。建议先完成一条「今日灵感提示」。`
      report.organizeNote = '整理：有记录之后，可在「整理」按标签与时间回顾。'
      report.collectNote = `收藏夹现有 ${favorites.length} 条，可从精选详情加入或取消。`
    } else {
      report.summary =
        `${rangeWord}你捕捉了 ${capture} 条灵感，收藏统计 ${favCount} 条，自有画板 ${ownBoards} 块。` +
        '下面按捕捉 / 整理 / 收藏三步给出下一步，全部来自你自己的记录统计。'
      report.captureNote = `捕捉：${rangeWord} ${capture} 条。保持「看见就记」比一次写很长更重要。`
      report.organizeNote = report.tagLine + ' 打开整理页，把同类碎片归到同一标签。'
      report.collectNote =
        `收藏：统计 ${favCount} 条。把仍想反复看的钉进画板，过期的可在空间「收藏内容」直接取消。`
    }

    report.nextAction1 = '用今日提示再记一条'
    report.nextAction2 = '把一条灵感钉进画板'
    report.nextAction3 = '打开整理，按标签回顾本周'
    return report
  }
}
