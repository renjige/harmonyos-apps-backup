import { AchieveItem, ArchiveSnap, GoalProgress, MixShare, ProgramDaySnap, ProgramItem, QuizResult, SuggestPack, TimelineEvent, TrainLog, WeekDot, WeeklyReport } from '../models/TuceModels'
import { MoveLibrary } from './MoveLibrary'
import { TuceStore } from './TuceStore'
import { BarChartItem } from '../components/design-system/AppChart'
import { CalendarCell } from './StatisticsUtil'

export class TuceEngine {
  static async archive(): Promise<ArchiveSnap> {
    const snap = new ArchiveSnap()
    const logs = await TuceStore.logs()
    const plans = await TuceStore.plans()
    const favs = await TuceStore.favIds()
    const themes = await TuceStore.themes()
    const programs = await TuceStore.programs()
    snap.sessions = logs.length
    snap.plans = plans.length
    snap.favs = favs.length
    snap.themes = themes.length
    snap.streak = await TuceEngine.streak()
    let done = 0
    for (const p of programs) {
      const n = TuceEngine.splitIdsSafe(p.doneDates)
      if (n.length >= p.days) {
        done++
      }
    }
    snap.programsDone = done
    return snap
  }

  static splitIdsSafe(raw: string): string[] {
    if (raw.length === 0) {
      return []
    }
    return raw.split('|')
  }

  static async streak(): Promise<number> {
    const days = await TuceStore.checkins()
    const set = new Set<string>()
    for (const d of days) {
      set.add(d)
    }
    let n = 0
    let cursor = TuceStore.today()
    if (!set.has(cursor)) {
      cursor = TuceEngine.shift(cursor, -1)
    }
    while (set.has(cursor)) {
      n++
      cursor = TuceEngine.shift(cursor, -1)
    }
    return n
  }

  static async weekDots(): Promise<WeekDot[]> {
    const days = await TuceStore.checkins()
    const set = new Set<string>()
    for (const d of days) {
      set.add(d)
    }
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '日']
    const today = new Date()
    const dow = today.getDay() === 0 ? 7 : today.getDay()
    const out: WeekDot[] = []
    for (let i = 1; i <= 7; i++) {
      const item = new WeekDot()
      item.label = labels[i - 1]
      const key = TuceEngine.shift(TuceStore.today(), i - dow)
      item.on = set.has(key)
      out.push(item)
    }
    return out
  }

  static async achievements(): Promise<AchieveItem[]> {
    const logs = await TuceStore.logs()
    const favs = await TuceStore.favIds()
    const plans = await TuceStore.plans()
    const streak = await TuceEngine.streak()
    const out: AchieveItem[] = []
    out.push(TuceEngine.badge('a1', '初次训练', logs.length >= 1))
    out.push(TuceEngine.badge('a2', '连续 7 天', streak >= 7))
    out.push(TuceEngine.badge('a3', '连续 21 天', streak >= 21))
    out.push(TuceEngine.badge('a4', '完成 10 次训练', logs.length >= 10))
    out.push(TuceEngine.badge('a5', '完成 50 次训练', logs.length >= 50))
    out.push(TuceEngine.badge('a6', '计划达人', plans.length >= 3))
    out.push(TuceEngine.badge('a7', '动作收藏家', favs.length >= 8))
    out.push(TuceEngine.badge('a8', '坚持达人', streak >= 14 && logs.length >= 14))
    return out
  }

  static async timeline(): Promise<TimelineEvent[]> {
    const logs = await TuceStore.logs()
    const out: TimelineEvent[] = []
    if (logs.length > 0) {
      const first = logs[logs.length - 1]
      const e1 = new TimelineEvent()
      e1.date = first.date
      e1.title = '第一次训练'
      out.push(e1)
    }
    const streak = await TuceEngine.streak()
    if (streak >= 7) {
      const e2 = new TimelineEvent()
      e2.date = TuceStore.today()
      e2.title = `连续训练 ${streak} 天`
      out.push(e2)
    }
    if (logs.length >= 10) {
      const e3 = new TimelineEvent()
      e3.date = logs[0].date
      e3.title = `完成第 ${logs.length} 次训练`
      out.push(e3)
    }
    return out
  }

  static async mix(): Promise<MixShare[]> {
    const logs = await TuceStore.logs()
    const map = new Map<string, number>()
    for (const log of logs) {
      const key = log.planName.length > 0 ? log.planName : '自由训练'
      map.set(key, (map.get(key) ?? 0) + 1)
    }
    const total = logs.length === 0 ? 1 : logs.length
    const out: MixShare[] = []
    map.forEach((count: number, label: string) => {
      const s = new MixShare()
      s.label = label
      s.percent = Math.round(count * 100 / total)
      out.push(s)
    })
    return out
  }

  static async suggest(): Promise<SuggestPack> {
    const pack = new SuggestPack()
    const favs = await TuceStore.favIds()
    const stretch: string[] = []
    for (const id of favs) {
      const m = MoveLibrary.find(id)
      if (m !== undefined && m.category === '拉伸') {
        stretch.push(id)
      }
    }
    if (stretch.length >= 3) {
      pack.title = '晚间放松训练'
      pack.reason = `你收藏了 ${stretch.length} 个拉伸动作，可以组成一套睡前放松。`
      pack.moveIds = stretch.join('|')
      return pack
    }
    if (favs.length >= 4) {
      pack.title = '我的收藏组合'
      pack.reason = `已收藏 ${favs.length} 个动作，一键编成今日方案。`
      pack.moveIds = favs.slice(0, 6).join('|')
      return pack
    }
    pack.title = '晨间活力组合'
    pack.reason = '图鉴推荐：开合热身 → 高抬腿 → 深蹲 → 拉伸。'
    pack.moveIds = 'm01|m07|m10|m04'
    return pack
  }

  static async dailyTheme(): Promise<string> {
    const custom = await TuceStore.dailyThemeWord()
    if (custom.length > 0) {
      return custom
    }
    const themes: string[] = ['坚持', '呼吸', '稳定', '从容', '激活', '恢复', '专注']
    const idx = new Date().getDay()
    return themes[idx] ?? '坚持'
  }

  static async primaryProgram(): Promise<ProgramItem | undefined> {
    const programs = await TuceStore.programs()
    for (const p of programs) {
      const done = TuceEngine.splitIdsSafe(p.doneDates).length
      if (done < p.days) {
        return p
      }
    }
    if (programs.length > 0) {
      return programs[0]
    }
    return undefined
  }

  static async programDaySnap(programId: string): Promise<ProgramDaySnap> {
    const snap = new ProgramDaySnap()
    const p = await TuceStore.findProgram(programId)
    if (p === undefined) {
      return snap
    }
    snap.programId = p.id
    snap.programName = p.name
    snap.totalDays = p.days
    const doneList = TuceEngine.splitIdsSafe(p.doneDates)
    snap.dayIndex = doneList.length + 1
    if (snap.dayIndex > p.days) {
      snap.dayIndex = p.days
    }
    const today = TuceStore.today()
    for (const d of doneList) {
      if (d === today) {
        snap.todayDone = true
      }
    }
    const plan = await TuceStore.findPlan(p.planId)
    if (plan !== undefined) {
      snap.planName = plan.name
      snap.moveIds = plan.moveIds
    }
    return snap
  }

  static async completeProgramDay(programId: string): Promise<void> {
    const p = await TuceStore.findProgram(programId)
    if (p === undefined) {
      return
    }
    const today = TuceStore.today()
    const days = TuceEngine.splitIdsSafe(p.doneDates)
    let hit = false
    for (const d of days) {
      if (d === today) {
        hit = true
      }
    }
    if (!hit) {
      days.push(today)
      p.doneDates = days.join('|')
      await TuceStore.saveProgram(p)
    }
    await TuceStore.addCheckin(today)
    const plan = await TuceStore.findPlan(p.planId)
    if (plan !== undefined) {
      const log = new TrainLog()
      log.id = TuceStore.newId('log')
      log.date = today
      log.planName = plan.name
      log.doneText = `完成 ${p.name} 第 ${days.length} 天`
      log.feel = '状态平稳'
      log.difficulty = 3
      log.fun = 4
      log.complete = 4
      log.note = plan.note
      log.createdAt = Date.now()
      await TuceStore.saveLog(log)
    }
  }

  static monthCount(logsLen: number): string {
    return `本月已记录 ${logsLen} 次训练`
  }

  static async goalProgress(): Promise<GoalProgress> {
    const g = await TuceStore.goal()
    const logs = await TuceStore.logs()
    const checkins = await TuceStore.checkins()
    const gp = new GoalProgress()
    gp.weeklyTarget = g.weekly
    gp.monthlyTarget = g.monthly
    const now = new Date()
    const monthPrefix = `${now.getFullYear()}-${now.getMonth() + 1 < 10 ? `0${now.getMonth() + 1}` : `${now.getMonth() + 1}`}`
    const weekSet = new Set<string>()
    for (let i = 0; i < 7; i++) {
      weekSet.add(TuceEngine.shift(TuceStore.today(), -i))
    }
    for (const d of checkins) {
      if (weekSet.has(d)) {
        gp.weeklyDone++
      }
    }
    for (const log of logs) {
      if (log.date.indexOf(monthPrefix) === 0) {
        gp.monthlyDone++
      }
    }
    gp.weeklyPct = gp.weeklyTarget > 0 ? Math.min(1, gp.weeklyDone / gp.weeklyTarget) : 0
    gp.monthlyPct = gp.monthlyTarget > 0 ? Math.min(1, gp.monthlyDone / gp.monthlyTarget) : 0
    return gp
  }

  static async weeklyBars(): Promise<BarChartItem[]> {
    const logs = await TuceStore.logs()
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '日']
    const today = new Date()
    const dow = today.getDay() === 0 ? 7 : today.getDay()
    const out: BarChartItem[] = []
    for (let i = 1; i <= 7; i++) {
      const key = TuceEngine.shift(TuceStore.today(), i - dow)
      let count = 0
      for (const log of logs) {
        if (log.date === key) {
          count++
        }
      }
      const item = new BarChartItem()
      item.label = labels[i - 1]
      item.value = count
      out.push(item)
    }
    return out
  }

  static async monthCalendar(): Promise<CalendarCell[]> {
    const logs = await TuceStore.logs()
    const checkins = await TuceStore.checkins()
    const now = new Date()
    const year = now.getFullYear()
    const month = now.getMonth() + 1
    const countMap = new Map<string, number>()
    const prefix = `${year}-${month < 10 ? `0${month}` : `${month}`}`
    for (const log of logs) {
      if (log.date.indexOf(prefix) === 0) {
        countMap.set(log.date, (countMap.get(log.date) ?? 0) + 1)
      }
    }
    for (const d of checkins) {
      if (d.indexOf(prefix) === 0) {
        countMap.set(d, (countMap.get(d) ?? 0) + 1)
      }
    }
    const first = new Date(year, month - 1, 1)
    const pad = first.getDay()
    const days = new Date(year, month, 0).getDate()
    const out: CalendarCell[] = []
    for (let i = 0; i < pad; i++) {
      const c = new CalendarCell()
      c.inMonth = false
      out.push(c)
    }
    for (let d = 1; d <= days; d++) {
      const c = new CalendarCell()
      c.inMonth = true
      c.day = d
      const ds = d < 10 ? `0${d}` : `${d}`
      c.dateKey = `${prefix}-${ds}`
      c.count = countMap.get(c.dateKey) ?? 0
      out.push(c)
    }
    return out
  }

  static async recentLogs(limit: number): Promise<TrainLog[]> {
    const logs = await TuceStore.logs()
    const out: TrainLog[] = []
    for (let i = 0; i < logs.length && i < limit; i++) {
      out.push(logs[i])
    }
    return out
  }

  static async weeklyReport(): Promise<WeeklyReport> {
    const report = new WeeklyReport()
    const gp = await TuceEngine.goalProgress()
    const streak = await TuceEngine.streak()
    const mix = await TuceEngine.mix()
    const logs = await TuceStore.logs()
    report.weekDone = gp.weeklyDone
    report.weekTarget = gp.weeklyTarget
    report.streak = streak
    if (mix.length > 0) {
      report.topPlan = mix[0].label
      const parts: string[] = []
      for (let i = 0; i < mix.length && i < 3; i++) {
        parts.push(`${mix[i].label} ${mix[i].percent}%`)
      }
      report.categoryMix = parts.join(' · ')
    } else {
      report.topPlan = '暂无'
      report.categoryMix = '本周尚未记录训练'
    }
    if (gp.weeklyDone >= gp.weeklyTarget) {
      report.headline = '本周目标已达成，节奏稳定'
      report.insight = `连续 ${streak} 天，训练习惯正在形成。`
      report.nextAction = '可尝试 HIIT 或力量课提升强度，或开启 14 日挑战巩固习惯。'
    } else if (gp.weeklyDone > 0) {
      report.headline = `本周 ${gp.weeklyDone}/${gp.weeklyTarget} 次，还差 ${gp.weeklyTarget - gp.weeklyDone} 次`
      report.insight = '已有训练记录，再补一次即可达标。'
      report.nextAction = '从「精选课库」选一节 10–15 分钟场景课完成即可。'
    } else {
      report.headline = '本周尚未训练，从一节短课开始'
      report.insight = '新手建议「新手全身入门」或「办公室微运动」。'
      report.nextAction = '打开精选课库 → 开始跟练 → 完成后自动写入日志。'
    }
    const lines: string[] = []
    lines.push('运动图册 · 训练周报')
    lines.push('')
    lines.push(report.headline)
    lines.push(`本周完成 ${report.weekDone}/${report.weekTarget} 次 · 连续 ${report.streak} 天`)
    lines.push(`主项 ${report.topPlan}`)
    if (report.categoryMix.length > 0) {
      lines.push(`构成 ${report.categoryMix}`)
    }
    lines.push('')
    lines.push(report.insight)
    lines.push(report.nextAction)
    lines.push('')
    lines.push(`生成于 ${TuceStore.today()} · 蜕变影像`)
    report.bodyText = lines.join('\n')
    return report
  }

  static buildQuizResult(goal: number, scene: number, level: number, freq: number): QuizResult {
    const goals: string[] = ['减脂燃脂', '力量塑形', '柔韧恢复', '习惯养成']
    const scenes: string[] = ['居家', '办公室', '户外', '跑后']
    const levels: string[] = ['入门', '进阶']
    const result = new QuizResult()
    result.goalLabel = goals[goal] ?? goals[0]
    result.sceneLabel = scenes[scene] ?? scenes[0]
    result.levelLabel = levels[level] ?? levels[0]
    const ids: string[] = []
    if (goal === 0) {
      ids.push('p05')
      ids.push('p06')
    } else if (goal === 1) {
      ids.push('p09')
      ids.push('p04')
    } else if (goal === 2) {
      ids.push('p08')
      ids.push('p03')
    } else {
      ids.push('p06')
      ids.push('p01')
    }
    if (scene === 1) {
      ids.unshift('p02')
      ids.unshift('p11')
    } else if (scene === 2) {
      ids.unshift('p12')
      ids.unshift('p07')
    } else if (scene === 3) {
      ids.unshift('p03')
    }
    if (level === 0) {
      ids.push('p10')
    }
    const uniq: string[] = []
    for (const id of ids) {
      let hit = false
      for (const u of uniq) {
        if (u === id) {
          hit = true
        }
      }
      if (!hit) {
        uniq.push(id)
      }
    }
    result.presetIds = uniq.slice(0, 4).join('|')
    result.summary = `目标「${result.goalLabel}」· 场景「${result.sceneLabel}」· ${result.levelLabel} · 计划每周 ${freq + 2} 次`
    if (freq >= 2) {
      result.tips = '频率较高，建议交替 HIIT 与恢复课，并设置 7 日或 14 日挑战追踪。'
    } else {
      result.tips = '建议从 10–15 分钟短课开始，完成跟练后写入日志，逐步提高到每周 3 次。'
    }
    return result
  }

  private static badge(id: string, title: string, on: boolean): AchieveItem {
    const a = new AchieveItem()
    a.id = id
    a.title = title
    a.unlocked = on
    return a
  }

  static shift(key: string, delta: number): string {
    const parts = key.split('-')
    if (parts.length < 3) {
      return key
    }
    const d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10))
    d.setDate(d.getDate() + delta)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }
}
