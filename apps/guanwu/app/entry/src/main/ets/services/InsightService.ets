import {
  EmotionStat, InsightReport, MilestoneItem, ObserveRecord, SceneStat, SubtypeOption,
  TrendPoint, WisdomTip
} from '../models/ObserveModels'
import { DateHelper } from './DateHelper'
import { ObserveStore } from './ObserveStore'

const WISDOM_LINES: string[] = [
  '观察本身就是一种温柔。你已经在认真对待日常。',
  '本周记录变少时，不必自责，花一分钟记下眼前一物即可。',
  '场景反复出现，说明那里正在成为你的生活重心。',
  '疲惫被看见，休息才有理由。',
  '想法不必完整，闪念也值得被收藏。',
  '环境的光与风，常常比日程更能说明这一天。'
]

export class InsightService {
  static async moodStats(startKey: string, endKey: string): Promise<EmotionStat[]> {
    const notes = await ObserveStore.notesInRange(startKey, endKey)
    const map = new Map<string, number>()
    let total = 0
    for (const n of notes) {
      if (n.kind === 'mood' && n.subtypeKey.length > 0) {
        const prev = map.get(n.subtypeKey) ?? 0
        map.set(n.subtypeKey, prev + 1)
        total++
      }
    }
    const out: EmotionStat[] = []
    for (const opt of SubtypeOption.forKind('mood')) {
      const s = new EmotionStat()
      s.key = opt.key
      s.label = opt.label
      s.count = map.get(opt.key) ?? 0
      s.ratio = total > 0 ? s.count / total : 0
      out.push(s)
    }
    return out
  }

  static async sceneStats(startKey: string, endKey: string): Promise<SceneStat[]> {
    const notes = await ObserveStore.notesInRange(startKey, endKey)
    const map = new Map<string, number>()
    for (const n of notes) {
      if (n.kind === 'scene' && n.subtypeKey.length > 0) {
        const prev = map.get(n.subtypeKey) ?? 0
        map.set(n.subtypeKey, prev + 1)
      }
    }
    const out: SceneStat[] = []
    for (const opt of SubtypeOption.forKind('scene')) {
      const s = new SceneStat()
      s.key = opt.key
      s.label = opt.label
      s.count = map.get(opt.key) ?? 0
      out.push(s)
    }
    out.sort((a, b) => b.count - a.count)
    return out
  }

  static async trendPoints(days: number): Promise<TrendPoint[]> {
    const keys = DateHelper.lastNDays(days)
    keys.reverse()
    const out: TrendPoint[] = []
    let idx = 0
    for (const key of keys) {
      const notes = await ObserveStore.notesForDate(key)
      let sum = 0
      let moodCount = 0
      for (const n of notes) {
        if (n.kind === 'mood') {
          const opt = SubtypeOption.find('mood', n.subtypeKey)
          sum += opt !== undefined ? opt.score : 3
          moodCount++
        }
      }
      const p = new TrendPoint()
      p.dateKey = key
      p.count = notes.length
      p.label = (days <= 7 || idx % 5 === 0) ? DateHelper.displayShort(key) : ''
      p.score = moodCount > 0 ? sum / moodCount : 0
      out.push(p)
      idx++
    }
    return out
  }

  static async buildReport(weekly: boolean): Promise<InsightReport> {
    const end = DateHelper.todayKey()
    const startDate = new Date()
    startDate.setDate(startDate.getDate() - (weekly ? 6 : 29))
    const start = DateHelper.keyFromDate(startDate)
    const notes = await ObserveStore.notesInRange(start, end)
    const report = new InsightReport()
    report.periodLabel = weekly ? DateHelper.weekRangeLabel() : DateHelper.monthRangeLabel()
    report.recordCount = notes.length
    report.streakDays = await ObserveStore.streakDays()
    if (notes.length === 0) {
      report.mainMood = '尚无心情记录'
      report.topScene = '尚无场景记录'
      report.wisdomMessage = '记下第一条观察后，这里会生成属于你的生活报告。'
      return report
    }
    const moods = await InsightService.moodStats(start, end)
    let topMood = moods[0]
    for (const s of moods) {
      if (s.count > topMood.count) {
        topMood = s
      }
    }
    report.mainMood = topMood.count > 0 ? topMood.label : '未标注心情'
    report.mainMoodRatio = Math.round(topMood.ratio * 100)
    const scenes = await InsightService.sceneStats(start, end)
    report.topScene = scenes.length > 0 && scenes[0].count > 0 ? scenes[0].label : '未标注场景'
    report.wisdomMessage = InsightService.pickWisdom(notes)
    return report
  }

  static async wisdomTips(): Promise<WisdomTip[]> {
    const all = await ObserveStore.loadAll()
    const tips: WisdomTip[] = []
    const today = DateHelper.todayKey()
    const yesterdayDate = new Date()
    yesterdayDate.setDate(yesterdayDate.getDate() - 1)
    const yesterday = DateHelper.keyFromDate(yesterdayDate)
    const todayNotes = await ObserveStore.notesForDate(today)
    const yNotes = await ObserveStore.notesForDate(yesterday)
    if (all.length > 0 && todayNotes.length === 0) {
      const t = new WisdomTip()
      t.title = '今日还未观察'
      t.body = '花一分钟记下眼前一物、一种心情或一处光线。'
      tips.push(t)
    }
    if (all.length > 3 && yNotes.length === 0) {
      const t = new WisdomTip()
      t.title = '昨日留白'
      t.body = '昨天没有记录。节奏下降很正常，今天补一条即可。'
      tips.push(t)
    }
    const weekStartDate = new Date()
    weekStartDate.setDate(weekStartDate.getDate() - 6)
    const weekNotes = await ObserveStore.notesInRange(DateHelper.keyFromDate(weekStartDate), today)
    const kinds = new Set<string>()
    for (const n of weekNotes) {
      kinds.add(n.kind)
    }
    if (weekNotes.length > 0 && !kinds.has('environment')) {
      const t = new WisdomTip()
      t.title = '本周缺少环境观察'
      t.body = '试着写下此刻的光、风或室内气温，补全四象。'
      tips.push(t)
    }
    const streak = await ObserveStore.streakDays()
    if (streak >= 3) {
      const t = new WisdomTip()
      t.title = `已连续观察 ${streak} 天`
      t.body = '连续本身就是里程碑，不必写很长。'
      tips.push(t)
    }
    if (tips.length === 0) {
      const t = new WisdomTip()
      t.title = '保持观看'
      t.body = all.length === 0 ? '从首页「快速记录」开始第一条观察。' : '你的观察节奏稳定，继续看见日常即可。'
      tips.push(t)
    }
    if (tips.length > 3) {
      return [tips[0], tips[1], tips[2]]
    }
    return tips
  }

  static async milestones(): Promise<MilestoneItem[]> {
    const all = await ObserveStore.loadAll()
    const count = all.length
    const days = await ObserveStore.uniqueDays()
    const defs: number[] = [1, 7, 21, 50, 100]
    const titles: string[] = ['初观', '七日之象', '三旬留痕', '五十物象', '百次观看']
    const out: MilestoneItem[] = []
    for (let i = 0; i < defs.length; i++) {
      const m = new MilestoneItem()
      m.threshold = defs[i]
      m.title = titles[i]
      m.reached = i < 2 ? days >= defs[i] || count >= defs[i] : count >= defs[i]
      if (i === 1) {
        m.reached = days >= 7
      }
      if (i === 0) {
        m.reached = count >= 1
      }
      out.push(m)
    }
    return out
  }

  static todayMoodSummary(notes: ObserveRecord[]): string {
    const map = new Map<string, number>()
    for (const n of notes) {
      if (n.kind === 'mood') {
        const prev = map.get(n.subtypeKey) ?? 0
        map.set(n.subtypeKey, prev + 1)
      }
    }
    let bestKey = ''
    let best = 0
    map.forEach((c, k) => {
      if (c > best) {
        best = c
        bestKey = k
      }
    })
    if (bestKey.length === 0) {
      return notes.length === 0 ? '暂无' : '未标心情'
    }
    return SubtypeOption.labelOf('mood', bestKey)
  }

  static todayEnvSummary(notes: ObserveRecord[]): string {
    for (const n of notes) {
      if (n.kind === 'environment') {
        const label = n.subtypeLabel()
        return label.length > 0 ? label : '已记录'
      }
    }
    return '暂无'
  }

  static async buildTodayReview(): Promise<string[]> {
    const today = DateHelper.todayKey()
    const notes = await ObserveStore.notesForDate(today)
    const lines: string[] = []
    if (notes.length === 0) {
      lines.push('今日尚未记录，可从工作台打卡或快速记录开始。')
      return lines
    }
    lines.push(`今日共 ${notes.length} 条观察。`)
    lines.push(`心情：${InsightService.todayMoodSummary(notes)} · 环境：${InsightService.todayEnvSummary(notes)}`)
    return lines
  }

  static async buildMonthlyReview(): Promise<string[]> {
    const end = DateHelper.todayKey()
    const startDate = new Date()
    startDate.setDate(startDate.getDate() - 29)
    const start = DateHelper.keyFromDate(startDate)
    const notes = await ObserveStore.notesInRange(start, end)
    const lines: string[] = []
    if (notes.length === 0) {
      lines.push('近 30 日尚无观察，从今日工作台开始第一条。')
      return lines
    }
    const daySet = new Set<string>()
    for (const n of notes) {
      daySet.add(n.dateKey)
    }
    lines.push(`近 30 日共 ${notes.length} 条观察，活跃 ${daySet.size} 天。`)
    const streak = await ObserveStore.streakDays()
    lines.push(`当前连续观察 ${streak} 天。`)
    return lines
  }

  static async buildYearReview(): Promise<string[]> {
    const list = await ObserveStore.loadAll()
    const lines: string[] = []
    if (list.length === 0) {
      lines.push('还没有年度数据，坚持记录后会生成年度回顾。')
      return lines
    }
    const year = new Date().getFullYear()
    let yearCount = 0
    const months = new Set<string>()
    for (const n of list) {
      if (n.dateKey.startsWith(`${year}`)) {
        yearCount++
        months.add(n.dateKey.substring(0, 7))
      }
    }
    lines.push(`${year} 年累计 ${yearCount} 条观察，覆盖 ${months.size} 个月。`)
    lines.push(`累计活跃 ${await ObserveStore.uniqueDays()} 天，收藏 ${(await ObserveStore.filterFavorites()).length} 条。`)
    return lines
  }

  static async buildWeeklyReview(): Promise<string[]> {
    const end = DateHelper.todayKey()
    const startDate = new Date()
    startDate.setDate(startDate.getDate() - 6)
    const start = DateHelper.keyFromDate(startDate)
    const notes = await ObserveStore.notesInRange(start, end)
    const lines: string[] = []
    if (notes.length === 0) {
      lines.push('本周尚未留下观察，可从首页「今日观察计划」或快速记录开始。')
      return lines
    }
    const daySet = new Set<string>()
    for (const n of notes) {
      daySet.add(n.dateKey)
    }
    lines.push(`本周共 ${notes.length} 条观察，活跃 ${daySet.size} 天。`)
    let imgCount = 0
    for (const n of notes) {
      imgCount += n.imagePaths.length
    }
    if (imgCount > 0) {
      lines.push(`附带 ${imgCount} 张生活影像，图集可在「万物集」浏览。`)
    }
    const moods = await InsightService.moodStats(start, end)
    let topMood = moods[0]
    for (const s of moods) {
      if (s.count > topMood.count) {
        topMood = s
      }
    }
    if (topMood.count > 0) {
      lines.push(`心情主旋律为「${topMood.label}」，可在下方图表查看分布。`)
    }
    const scenes = await InsightService.sceneStats(start, end)
    if (scenes.length > 0 && scenes[0].count > 0) {
      lines.push(`最常出现的场景是「${scenes[0].label}」。`)
    }
    const kinds = new Set<string>()
    for (const n of notes) {
      kinds.add(n.kind)
    }
    if (kinds.size < 4) {
      lines.push('试着补全心情、场景、想法、环境四象，报告会更立体。')
    } else {
      lines.push('四象观察已齐，继续保持你的观物节奏。')
    }
    const catSet = new Set<string>()
    for (const n of notes) {
      if (n.categoryKey.length > 0) {
        catSet.add(n.categoryKey)
      }
    }
    if (catSet.size > 0) {
      lines.push(`本周覆盖 ${catSet.size} 个物品分类，可在图鉴里对照成长时间轴。`)
    }
    return lines
  }

  static async kindTotals(): Promise<number[]> {
    const list = await ObserveStore.loadAll()
    let mood = 0
    let scene = 0
    let thought = 0
    let env = 0
    for (const n of list) {
      if (n.kind === 'mood') {
        mood++
      } else if (n.kind === 'scene') {
        scene++
      } else if (n.kind === 'thought') {
        thought++
      } else if (n.kind === 'environment') {
        env++
      }
    }
    return [mood, scene, thought, env]
  }

  private static pickWisdom(notes: ObserveRecord[]): string {
    let tired = 0
    for (const n of notes) {
      if (n.subtypeKey === 'tired' || n.subtypeKey === 'sad') {
        tired++
      }
    }
    if (tired >= 3) {
      return WISDOM_LINES[3]
    }
    if (notes.length < 3) {
      return WISDOM_LINES[1]
    }
    return WISDOM_LINES[notes.length % WISDOM_LINES.length]
  }
}
