import { MatchItem, StandingItem, TeamItem } from '../models/MatchModels'

/** 规则模板研判简报（非 LLM · 方案 B） */
export class TeamInsightService {
  static buildLines(
    teamA: TeamItem,
    teamB: TeamItem,
    standingA: StandingItem | undefined,
    standingB: StandingItem | undefined,
    h2h: MatchItem[],
    matchesA: MatchItem[],
    matchesB: MatchItem[]
  ): string[] {
    const lines: string[] = []
    lines.push(`【球队研判简报】${teamA.title} vs ${teamB.title}`)
    lines.push(`生成时间：${TeamInsightService.nowText()}`)
    lines.push('')
    lines.push('一、基本信息')
    lines.push(`· ${teamA.title}：${teamA.sportLabel()} · ${teamA.leagueName.length > 0 ? teamA.leagueName : '联赛待定'}`)
    lines.push(`· ${teamB.title}：${teamB.sportLabel()} · ${teamB.leagueName.length > 0 ? teamB.leagueName : '联赛待定'}`)
    lines.push('')
    lines.push('二、积分榜对照')
    if (standingA !== undefined) {
      lines.push(`· ${teamA.title}：${standingA.rankText()} · ${standingA.points} 分 · 胜率 ${standingA.winRateText()} · ${standingA.recordText()} · 净胜 ${standingA.goalDiff}`)
    } else {
      lines.push(`· ${teamA.title}：暂无公开积分榜数据`)
    }
    if (standingB !== undefined) {
      lines.push(`· ${teamB.title}：${standingB.rankText()} · ${standingB.points} 分 · 胜率 ${standingB.winRateText()} · ${standingB.recordText()} · 净胜 ${standingB.goalDiff}`)
    } else {
      lines.push(`· ${teamB.title}：暂无公开积分榜数据`)
    }
    lines.push('')
    lines.push('三、近期状态')
    lines.push(`· ${teamA.title}：${teamA.formStatus()} · 进攻 ${teamA.attackIndex > 0 ? `${teamA.attackIndex}` : '—'} · 防守 ${teamA.defenseIndex > 0 ? `${teamA.defenseIndex}` : '—'}`)
    lines.push(`· ${teamB.title}：${teamB.formStatus()} · 进攻 ${teamB.attackIndex > 0 ? `${teamB.attackIndex}` : '—'} · 防守 ${teamB.defenseIndex > 0 ? `${teamB.defenseIndex}` : '—'}`)
    if (teamA.attackNote.length > 0) {
      lines.push(`· ${teamA.title} 进攻：${teamA.attackNote}`)
    }
    if (teamB.defenseNote.length > 0) {
      lines.push(`· ${teamB.title} 防守：${teamB.defenseNote}`)
    }
    lines.push('')
    lines.push('四、历史交锋')
    if (h2h.length === 0) {
      lines.push('· 双方近期公开赛程中暂无已结束对阵记录')
    } else {
      let idx = 0
      for (const m of h2h) {
        if (idx >= 5) {
          break
        }
        lines.push(`· ${m.title} · ${m.statusLabel()} · ${m.dateIso()}`)
        idx += 1
      }
    }
    lines.push('')
    lines.push('五、近期赛程摘要')
    lines.push(TeamInsightService.recentSummary(teamA.title, matchesA))
    lines.push(TeamInsightService.recentSummary(teamB.title, matchesB))
    lines.push('')
    lines.push('六、研判要点（规则模板）')
    lines.push(TeamInsightService.keyInsight(teamA, teamB, standingA, standingB, h2h))
    lines.push('')
    lines.push('说明：本简报基于公开赛程与积分榜数据自动生成，仅供球迷参考，不构成投注建议。')
    return lines
  }

  static toPlainText(lines: string[]): string {
    let out = ''
    for (const row of lines) {
      out = `${out}${row}\n`
    }
    return out
  }

  private static recentSummary(teamTitle: string, matches: MatchItem[]): string {
    if (matches.length === 0) {
      return `· ${teamTitle}：暂无近期比赛记录`
    }
    let text = `· ${teamTitle}：`
    let idx = 0
    for (const m of matches) {
      if (idx >= 3) {
        break
      }
      if (idx > 0) {
        text = `${text}；`
      }
      text = `${text}${m.title}(${m.statusLabel()})`
      idx += 1
    }
    return text
  }

  private static keyInsight(
    teamA: TeamItem,
    teamB: TeamItem,
    standingA: StandingItem | undefined,
    standingB: StandingItem | undefined,
    h2h: MatchItem[]
  ): string {
    if (standingA !== undefined && standingB !== undefined) {
      if (standingA.points > standingB.points) {
        return `· 积分榜上 ${teamA.title} 领先 ${standingA.points - standingB.points} 分，整体赛季表现更稳；关注 ${teamB.title} 近期状态能否回暖。`
      }
      if (standingB.points > standingA.points) {
        return `· 积分榜上 ${teamB.title} 领先 ${standingB.points - standingA.points} 分；${teamA.title} 需在后续赛程中提升拿分效率。`
      }
      return `· 双方积分相同，联赛排名接近，后续直接对话或关键场次将决定走势。`
    }
    if (h2h.length > 0) {
      return `· 双方有过交锋记录，可结合历史对阵节奏评估风格差异；建议同步关注各自近期赛程密度。`
    }
    return `· 公开数据有限，建议先查看双方近期赛程与联赛积分榜，再结合个人关注备注做跟踪。`
  }

  private static nowText(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const h = d.getHours()
    const min = d.getMinutes()
    const ms: string = m < 10 ? `0${m}` : `${m}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    const hs: string = h < 10 ? `0${h}` : `${h}`
    const mins: string = min < 10 ? `0${min}` : `${min}`
    return `${d.getFullYear()}-${ms}-${ds} ${hs}:${mins}`
  }
}
