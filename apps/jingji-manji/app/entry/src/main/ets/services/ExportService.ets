import { pasteboard } from '@kit.BasicServicesKit'
import { SportStore } from './SportStore'
import { SportAnalytics } from './SportAnalytics'
import { ChallengeStore } from './ChallengeStore'

export class ExportService {
  static buildText(): string {
    const s = SportAnalytics.summarize()
    const lines: string[] = []
    lines.push('竞技漫记 · 成长轨迹')
    lines.push(`累计 ${s.totalSessions} 次 · ${s.totalDurationMin} 分钟 · ${s.totalDistanceKm.toFixed(1)} km`)
    lines.push(`连续 ${s.streakDays} 天 · 本月 ${s.monthSessions} 次`)
    for (const mix of s.typeMix) {
      lines.push(`- ${mix.sportType} ${mix.sessions} 次`)
    }
    lines.push('')
    lines.push('最近记录：')
    const recent = SportStore.recent(8)
    for (const r of recent) {
      lines.push(`${r.recordDate} ${r.sportType} ${r.durationMin}分 ${r.distanceKm.toFixed(1)}km ${r.takeaway}`)
    }
    const chs = ChallengeStore.list()
    if (chs.length > 0) {
      lines.push('')
      lines.push('挑战：')
      for (const c of chs) {
        const p = SportAnalytics.challengeProgress(c)
        lines.push(`${c.title} ${p.sessions}/${c.targetSessions} ${c.status}`)
      }
    }
    return lines.join('\n')
  }

  static async copy(): Promise<boolean> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, ExportService.buildText())
      await pasteboard.getSystemPasteboard().setData(data)
      return true
    } catch {
      return false
    }
  }
}
