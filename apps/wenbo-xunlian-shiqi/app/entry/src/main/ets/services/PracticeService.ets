import {
  CardDraft,
  CheckLine,
  CheckState,
  GoalDraft,
  KnowledgeCard,
  MoveDraft,
  MoveItem,
  StageGoal
} from '../models/TrainingModels'
import { TrainingStore } from './TrainingStore'

export class PracticeService {
  static readonly MOVE_CATS: string[] = ['热身', '拉伸', '力量', '平衡', '放松']
  static readonly CARD_TAGS: string[] = ['动作要点', '训练方法', '注意事项']

  static newMoveId(): string {
    return `mv_${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }

  static newGoalId(): string {
    return `gl_${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }

  static newCardId(): string {
    return `cd_${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }

  static emptyMoveDraft(): MoveDraft {
    return new MoveDraft()
  }

  static copyMoveDraft(src: MoveDraft): MoveDraft {
    const n = new MoveDraft()
    n.title = src.title
    n.category = src.category
    n.tips = src.tips
    n.purpose = src.purpose
    n.combo = src.combo
    return n
  }

  static toMoveDraft(item: MoveItem): MoveDraft {
    const d = new MoveDraft()
    d.title = item.title
    d.category = item.category
    d.tips = item.tips
    d.purpose = item.purpose
    d.combo = item.combo
    return d
  }

  static emptyGoalDraft(): GoalDraft {
    return new GoalDraft()
  }

  static emptyCardDraft(): CardDraft {
    return new CardDraft()
  }

  static createMove(d: MoveDraft): MoveItem {
    const m = new MoveItem()
    m.id = PracticeService.newMoveId()
    m.title = d.title.trim()
    m.category = d.category
    m.tips = d.tips.trim()
    m.purpose = d.purpose.trim()
    m.combo = d.combo.trim()
    m.favorited = '0'
    m.createdAt = new Date().toISOString()
    return m
  }

  static copyMove(src: MoveItem): MoveItem {
    const m = new MoveItem()
    m.id = src.id
    m.title = src.title
    m.category = src.category
    m.tips = src.tips
    m.purpose = src.purpose
    m.combo = src.combo
    m.favorited = src.favorited
    m.createdAt = src.createdAt
    return m
  }

  static toggleFavorite(src: MoveItem): MoveItem {
    const m = PracticeService.copyMove(src)
    m.favorited = src.favorited === '1' ? '0' : '1'
    return m
  }

  static createGoal(d: GoalDraft): StageGoal {
    const g = new StageGoal()
    g.id = PracticeService.newGoalId()
    g.title = d.title.trim()
    const n = parseInt(d.targetCount, 10)
    g.targetCount = (isNaN(n) || n <= 0) ? 20 : n
    g.currentCount = 0
    g.unit = d.unit.trim().length > 0 ? d.unit.trim() : '次'
    g.syncKind = PracticeService.normalizeSync(d.syncKind, g.unit)
    g.createdAt = new Date().toISOString()
    return g
  }

  static normalizeSync(kind: string, unit: string): string {
    if (kind === 'manual' || kind === 'sessions' || kind === 'minutes') {
      return kind
    }
    if (unit === '分钟' || unit === '分') {
      return 'minutes'
    }
    return 'sessions'
  }

  static liveCount(g: StageGoal): number {
    const kind = PracticeService.normalizeSync(g.syncKind, g.unit)
    if (kind === 'sessions') {
      return TrainingStore.list().length
    }
    if (kind === 'minutes') {
      let mins = 0
      for (const r of TrainingStore.list()) {
        mins += r.durationMin
      }
      return mins
    }
    return g.currentCount
  }

  static copyGoal(src: StageGoal): StageGoal {
    const next = new StageGoal()
    next.id = src.id
    next.title = src.title
    next.targetCount = src.targetCount
    next.currentCount = src.currentCount
    next.unit = src.unit
    next.syncKind = src.syncKind
    next.createdAt = src.createdAt
    return next
  }

  static createCard(d: CardDraft): KnowledgeCard {
    const k = new KnowledgeCard()
    k.id = PracticeService.newCardId()
    k.title = d.title.trim()
    k.body = d.body.trim()
    k.tag = d.tag
    k.createdAt = new Date().toISOString()
    return k
  }

  static bumpGoal(g: StageGoal, delta: number): StageGoal {
    const next = PracticeService.copyGoal(g)
    let v = PracticeService.liveCount(g) + delta
    if (v < 0) {
      v = 0
    }
    if (v > 9999) {
      v = 9999
    }
    next.currentCount = v
    next.syncKind = 'manual'
    return next
  }

  static packLines(lines: CheckLine[]): string {
    const out: string[] = []
    for (const l of lines) {
      out.push(`${l.title}|${l.done ? '1' : '0'}`)
    }
    return out.join('\n')
  }

  static unpackLines(packed: string): CheckLine[] {
    const out: CheckLine[] = []
    if (packed.length === 0) {
      return out
    }
    const rows = packed.split('\n')
    let seq = 0
    for (const row of rows) {
      if (row.length === 0) {
        continue
      }
      const l = new CheckLine()
      l.seq = seq
      seq += 1
      const sep = row.lastIndexOf('|')
      if (sep <= 0) {
        l.title = row
        l.done = false
      } else {
        l.title = row.substring(0, sep)
        l.done = row.substring(sep + 1) === '1'
      }
      out.push(l)
    }
    return out
  }

  static defaultBefore(): CheckLine[] {
    return PracticeService.namedLines(['热身', '准备装备', '确认今日时长'])
  }

  static defaultAfter(): CheckLine[] {
    return PracticeService.namedLines(['拉伸', '补水放松', '写下训练心得'])
  }

  static namedLines(titles: string[]): CheckLine[] {
    const out: CheckLine[] = []
    let seq = 0
    for (const title of titles) {
      const l = new CheckLine()
      l.title = title
      l.done = false
      l.seq = seq
      seq += 1
      out.push(l)
    }
    return out
  }

  static toggleLine(lines: CheckLine[], index: number): CheckLine[] {
    const out: CheckLine[] = []
    let i = 0
    for (const src of lines) {
      const l = new CheckLine()
      l.title = src.title
      l.seq = src.seq
      l.done = i === index ? !src.done : src.done
      out.push(l)
      i += 1
    }
    return out
  }

  static applyCheckTemplate(state: CheckState): CheckState {
    const next = new CheckState()
    next.beforePacked = state.beforePacked.length > 0 ? state.beforePacked : PracticeService.packLines(PracticeService.defaultBefore())
    next.afterPacked = state.afterPacked.length > 0 ? state.afterPacked : PracticeService.packLines(PracticeService.defaultAfter())
    return next
  }

  static addLine(lines: CheckLine[], title: string): CheckLine[] {
    const t = title.trim()
    if (t.length === 0) {
      return lines
    }
    const l = new CheckLine()
    l.title = t
    l.done = false
    l.seq = lines.length
    const out = lines.slice()
    out.push(l)
    return out
  }
}
