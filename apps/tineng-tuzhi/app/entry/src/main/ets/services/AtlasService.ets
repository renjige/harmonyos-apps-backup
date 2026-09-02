import { AtlasReport, MixBar, WeekCompareSnapshot } from '../models/WorkoutModels'
import { DateHelper } from './DateHelper'
import { PlanStore } from './PlanStore'
import { StatsService } from './StatsService'

export class AtlasService {
  static async buildCurrentWeek(): Promise<AtlasReport> {
    const today = DateHelper.todayKey()
    return AtlasService.buildForDate(today)
  }

  static async buildForDate(fromKey: string): Promise<AtlasReport> {
    const weekKey = DateHelper.weekKey(fromKey)
    const keys = DateHelper.weekDateKeys(fromKey)
    const report = new AtlasReport()
    report.weekKey = weekKey
    report.title = '本周体能图志'
    report.rangeLabel = DateHelper.weekRangeLabel(weekKey)
    report.mix = await StatsService.sportMix(keys[0], keys[6])
    report.compare = await StatsService.weekCompareSnapshot()
    const peak = await StatsService.peakDay(keys[0], keys[6])
    report.peakDay = peak.dateKey
    report.peakMinutes = peak.minutes
    const plan = await PlanStore.loadPlan(weekKey)
    report.motto = plan.motto
    report.summary = AtlasService.buildSummary(report)
    report.advice = AtlasService.buildAdvice(report)
    return report
  }

  private static buildSummary(report: AtlasReport): string {
    const cmp: WeekCompareSnapshot = report.compare
    if (cmp.thisMinutes <= 0 && cmp.thisDays <= 0) {
      return `${report.rangeLabel} 还没有运动记录。先排一周训练图志，或记下今天的第一条。`
    }
    const peakText = report.peakDay.length > 0 ?
      `高峰在 ${DateHelper.displayShort(report.peakDay)}（${report.peakMinutes} 分钟）。` : ''
    const mixText = AtlasService.mixLine(report.mix)
    return `${report.rangeLabel} 共运动 ${cmp.thisDays} 天、${cmp.thisMinutes} 分钟、${cmp.thisCalories} 千卡。${peakText}${mixText}`
  }

  private static mixLine(mix: MixBar[]): string {
    if (mix.length === 0) {
      return ''
    }
    let top = mix[0]
    for (const b of mix) {
      if (b.minutes > top.minutes) {
        top = b
      }
    }
    const pct = Math.round(top.ratio * 100)
    return ` 品类以「${top.label}」为主（约占 ${pct}%）。`
  }

  private static buildAdvice(report: AtlasReport): string {
    const cmp = report.compare
    if (cmp.thisDays === 0) {
      return '本周图志还是空白。打开「周训图志」给 3 天排上类型和分钟，再回来对照。'
    }
    if (cmp.deltaMinutes >= 40) {
      return '时长比上周明显变厚。保持现有节奏即可，不必硬加量。'
    }
    if (cmp.deltaMinutes <= -40) {
      return '时长比上周变薄。把周训里空着的一天补上，比一次拉很长更稳。'
    }
    if (cmp.thisDays < 3) {
      return '出勤天数偏少。用周训图志先钉住 3 个固定日，比每天临时决定更容易坚持。'
    }
    if (report.mix.length === 1) {
      return '本周几乎只有一种运动。下周在周训里加一条交叉训练（力量或瑜伽），图志会更立体。'
    }
    return '图志已经成形。记录时补一体感档位，下周对照会更准。'
  }
}
