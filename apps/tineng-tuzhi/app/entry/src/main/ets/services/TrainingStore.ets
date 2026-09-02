import { ActionCategory, BodyNote, ChallengeCatalog, CyclePlan, GoalChallenge, InsightFav, LibraryAction, PlanCatalog, PrepList, ProgramCatalog } from '../models/TrainingModels'
import { DateHelper } from './DateHelper'
import { WorkoutStore } from './WorkoutStore'

const KEY_PLANS = 'archive_plans'
const KEY_ACTIONS = 'archive_actions'
const KEY_LISTS = 'archive_lists'
const KEY_FAVS = 'archive_favs'
const KEY_CHALLENGES = 'archive_challenges'
const KEY_CHECKINS = 'archive_checkins'
const KEY_SEEDED = 'archive_seeded'
const KEY_NOTES = 'body_notes'

export class TrainingStore {
  static async ensureTemplates(): Promise<void> {
    const flagged = await WorkoutStore.readRaw(KEY_SEEDED)
    if (flagged !== '1' && flagged !== '2') {
      await TrainingStore.saveActions(TrainingStore.defaultActions())
      await TrainingStore.saveLists(TrainingStore.defaultLists())
    }
    await TrainingStore.mergeCatalog()
    await WorkoutStore.writeRaw(KEY_SEEDED, '2')
  }

  static async mergeCatalog(): Promise<void> {
    const cur = TrainingStore.parseActions(await WorkoutStore.readRaw(KEY_ACTIONS))
    const catalog = TrainingStore.defaultActions()
    const next: LibraryAction[] = []
    for (const a of cur) {
      next.push(a)
    }
    for (const c of catalog) {
      let found = false
      for (const a of next) {
        if (a.id === c.id) {
          found = true
          if (a.purpose.length === 0) {
            a.purpose = c.purpose
            a.caution = c.caution
            a.coverKey = c.coverKey
          }
        }
      }
      if (!found) {
        next.push(c)
      }
    }
    await TrainingStore.saveActions(next)
  }

  static async loadPlans(): Promise<CyclePlan[]> {
    return TrainingStore.parsePlans(await WorkoutStore.readRaw(KEY_PLANS))
  }

  static async savePlan(item: CyclePlan): Promise<void> {
    const list = await TrainingStore.loadPlans()
    const next: CyclePlan[] = []
    let replaced = false
    for (const p of list) {
      if (p.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(p)
      }
    }
    if (!replaced) {
      next.push(item)
    }
    await TrainingStore.persistPlans(next)
  }

  static async deletePlan(id: string): Promise<void> {
    const list = await TrainingStore.loadPlans()
    const next: CyclePlan[] = []
    for (const p of list) {
      if (p.id !== id) {
        next.push(p)
      }
    }
    await TrainingStore.persistPlans(next)
  }

  static async loadActions(): Promise<LibraryAction[]> {
    const parsed = TrainingStore.parseActions(await WorkoutStore.readRaw(KEY_ACTIONS))
    if (parsed.length === 0) {
      const seeded = TrainingStore.defaultActions()
      await TrainingStore.saveActions(seeded)
      return seeded
    }
    return parsed
  }

  static async saveAction(item: LibraryAction): Promise<void> {
    const list = await TrainingStore.loadActions()
    const next: LibraryAction[] = []
    let replaced = false
    for (const a of list) {
      if (a.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(a)
      }
    }
    if (!replaced) {
      next.push(item)
    }
    await TrainingStore.saveActions(next)
  }

  static async deleteAction(id: string): Promise<void> {
    const list = await TrainingStore.loadActions()
    const next: LibraryAction[] = []
    for (const a of list) {
      if (a.id !== id) {
        next.push(a)
      }
    }
    await TrainingStore.saveActions(next)
  }

  static async loadLists(): Promise<PrepList[]> {
    const parsed = TrainingStore.parseLists(await WorkoutStore.readRaw(KEY_LISTS))
    if (parsed.length === 0) {
      const seeded = TrainingStore.defaultLists()
      await TrainingStore.saveLists(seeded)
      return seeded
    }
    return parsed
  }

  static async saveList(item: PrepList): Promise<void> {
    item.rebuildLines()
    const list = await TrainingStore.loadLists()
    const next: PrepList[] = []
    let replaced = false
    for (const p of list) {
      if (p.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(p)
      }
    }
    if (!replaced) {
      next.push(item)
    }
    await TrainingStore.saveLists(next)
  }

  static async toggleListItem(listId: string, index: number): Promise<boolean> {
    const lists = await TrainingStore.loadLists()
    for (const p of lists) {
      if (p.id !== listId) {
        continue
      }
      const lines = p.itemsText.split('|')
      let mask = p.doneMask
      while (mask.length < lines.length) {
        mask = `${mask}0`
      }
      if (index < 0 || index >= lines.length) {
        return false
      }
      const ch = mask.substring(index, index + 1) === '1' ? '0' : '1'
      p.doneMask = `${mask.substring(0, index)}${ch}${mask.substring(index + 1)}`
      p.rebuildLines()
      await TrainingStore.saveList(p)
      return true
    }
    return false
  }

  static async loadFavs(): Promise<InsightFav[]> {
    return TrainingStore.parseFavs(await WorkoutStore.readRaw(KEY_FAVS))
  }

  static async saveFav(item: InsightFav): Promise<void> {
    const list = await TrainingStore.loadFavs()
    const next: InsightFav[] = []
    let replaced = false
    for (const f of list) {
      if (f.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(f)
      }
    }
    if (!replaced) {
      next.push(item)
    }
    await TrainingStore.persistFavs(next)
  }

  static async deleteFav(id: string): Promise<void> {
    const list = await TrainingStore.loadFavs()
    const next: InsightFav[] = []
    for (const f of list) {
      if (f.id !== id) {
        next.push(f)
      }
    }
    await TrainingStore.persistFavs(next)
  }

  static async loadChallenges(): Promise<GoalChallenge[]> {
    return TrainingStore.parseChallenges(await WorkoutStore.readRaw(KEY_CHALLENGES))
  }

  static async saveChallenge(item: GoalChallenge): Promise<void> {
    const list = await TrainingStore.loadChallenges()
    const next: GoalChallenge[] = []
    let replaced = false
    for (const c of list) {
      if (c.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(c)
      }
    }
    if (!replaced) {
      next.push(item)
    }
    await TrainingStore.persistChallenges(next)
  }

  static async toggleChallenge(id: string): Promise<void> {
    const list = await TrainingStore.loadChallenges()
    for (const c of list) {
      if (c.id === id) {
        c.done = !c.done
        await TrainingStore.saveChallenge(c)
        return
      }
    }
  }

  static async loadCheckins(): Promise<string[]> {
    const raw = await WorkoutStore.readRaw(KEY_CHECKINS)
    if (raw.length === 0) {
      return []
    }
    return raw.split(',')
  }

  static async isCheckedToday(): Promise<boolean> {
    const today = DateHelper.todayKey()
    const list = await TrainingStore.loadCheckins()
    for (const k of list) {
      if (k === today) {
        return true
      }
    }
    return false
  }

  static async ensureCheckin(dateKey: string): Promise<void> {
    if (dateKey.length < 8) {
      return
    }
    const list = await TrainingStore.loadCheckins()
    for (const k of list) {
      if (k === dateKey) {
        return
      }
    }
    const next: string[] = []
    for (const k of list) {
      if (k.length >= 8) {
        next.push(k)
      }
    }
    next.push(dateKey)
    await WorkoutStore.writeRaw(KEY_CHECKINS, next.join(','))
  }

  static async toggleTodayCheckin(): Promise<boolean> {
    const today = DateHelper.todayKey()
    const list = await TrainingStore.loadCheckins()
    const next: string[] = []
    let found = false
    for (const k of list) {
      if (k === today) {
        found = true
      } else if (k.length >= 8) {
        next.push(k)
      }
    }
    if (!found) {
      next.push(today)
    }
    await WorkoutStore.writeRaw(KEY_CHECKINS, next.join(','))
    return !found
  }

  static async checkinStreak(): Promise<number> {
    const list = await TrainingStore.loadCheckins()
    const set: Map<string, number> = new Map()
    for (const k of list) {
      set.set(k, 1)
    }
    let streak = 0
    const cursor = new Date()
    const todayKey = DateHelper.todayKey()
    if (set.get(todayKey) !== 1) {
      cursor.setDate(cursor.getDate() - 1)
    }
    for (let i = 0; i < 366; i++) {
      const k = DateHelper.keyFromDate(cursor)
      if (set.get(k) === 1) {
        streak++
        cursor.setDate(cursor.getDate() - 1)
      } else {
        break
      }
    }
    return streak
  }

  static async findAction(id: string): Promise<LibraryAction | undefined> {
    const list = await TrainingStore.loadActions()
    for (const a of list) {
      if (a.id === id) {
        return a
      }
    }
    return undefined
  }

  static async toggleActionFav(id: string): Promise<void> {
    const list = await TrainingStore.loadActions()
    for (const a of list) {
      if (a.id === id) {
        a.favorited = !a.favorited
        await TrainingStore.saveAction(a)
        return
      }
    }
  }

  static async favActions(): Promise<LibraryAction[]> {
    const list = await TrainingStore.loadActions()
    const out: LibraryAction[] = []
    for (const a of list) {
      if (a.favorited) {
        out.push(a)
      }
    }
    return out
  }

  static async loadTodayNote(): Promise<BodyNote> {
    return TrainingStore.loadNote(DateHelper.todayKey())
  }

  static async loadNote(dateKey: string): Promise<BodyNote> {
    const raw = await WorkoutStore.readRaw(KEY_NOTES)
    const n = new BodyNote()
    n.dateKey = dateKey
    if (raw.length === 0) {
      return n
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('\t')
      if (parts.length >= 4 && parts[0] === dateKey) {
        n.energy = parts[1]
        n.drive = parts[2]
        n.text = parts[3]
        return n
      }
    }
    return n
  }

  static async saveNote(note: BodyNote): Promise<void> {
    const raw = await WorkoutStore.readRaw(KEY_NOTES)
    const next: string[] = []
    let replaced = false
    if (raw.length > 0) {
      const lines = raw.split('\n')
      for (const line of lines) {
        if (line.length === 0) {
          continue
        }
        const parts = line.split('\t')
        if (parts.length >= 1 && parts[0] === note.dateKey) {
          next.push([note.dateKey, note.energy, note.drive, note.text.replace(/\t/g, ' ')].join('\t'))
          replaced = true
        } else {
          next.push(line)
        }
      }
    }
    if (!replaced) {
      next.push([note.dateKey, note.energy, note.drive, note.text.replace(/\t/g, ' ')].join('\t'))
    }
    await WorkoutStore.writeRaw(KEY_NOTES, next.join('\n'))
  }

  static async applyVitalityPlan(): Promise<void> {
    const p = new CyclePlan()
    p.id = TrainingStore.newId()
    p.title = PlanCatalog.vitalityTitle()
    p.goalText = '每天一项主题训练'
    p.periodDays = 7
    p.startKey = DateHelper.todayKey()
    const days = PlanCatalog.vitalityDays()
    const bits: string[] = []
    for (let i = 0; i < days.length; i++) {
      bits.push(`Day${i + 1} ${days[i]}`)
    }
    p.note = bits.join(' / ')
    await TrainingStore.savePlan(p)
  }

  static async applyProgram(programId: string): Promise<void> {
    const prog = ProgramCatalog.find(programId)
    if (prog === undefined) {
      return
    }
    const p = new CyclePlan()
    p.id = TrainingStore.newId()
    p.title = prog.title
    p.goalText = prog.focus
    p.periodDays = prog.days.length * prog.weeks
    p.startKey = DateHelper.todayKey()
    const bits: string[] = []
    for (let i = 0; i < prog.days.length; i++) {
      bits.push(`Day${i + 1} ${prog.days[i]}`)
    }
    p.note = `${bits.join(' / ')} · 共 ${prog.weeks} 周循环`
    await TrainingStore.savePlan(p)
  }

  static async startCatalogChallenge(id: string): Promise<void> {
    const list = await TrainingStore.loadChallenges()
    for (const c of list) {
      if (c.id === id) {
        return
      }
    }
    for (const cat of ChallengeCatalog.all()) {
      if (cat.id === id) {
        const g = new GoalChallenge()
        g.id = cat.id
        g.title = cat.title
        g.kind = cat.kind
        g.target = cat.target
        g.done = false
        await TrainingStore.saveChallenge(g)
        return
      }
    }
  }

  static newId(): string {
    return `${Date.now()}-${Math.floor(Math.random() * 10000)}`
  }

  static categoryLabel(key: string): string {
    return ActionCategory.labelFor(key)
  }

  static coverForCategory(key: string): string {
    if (key === 'stretch') {
      return 'atlas_stretch'
    }
    if (key === 'strength') {
      return 'atlas_strength'
    }
    if (key === 'balance') {
      return 'atlas_balance'
    }
    if (key === 'relax') {
      return 'atlas_relax'
    }
    return 'atlas_warm'
  }

  private static defaultActions(): LibraryAction[] {
    const rows: string[][] = [
      ['tpl-act-0', 'warm', '关节环绕', '开训前缓慢绕肩、绕髋各 8 次', '唤醒关节活动度', '动作缓慢，不要弹振', 'atlas_warm'],
      ['tpl-act-1', 'warm', '动态拉伸', '弓步走 + 高抬腿，唤醒下肢', '提升体温与步幅', '膝盖沿脚尖方向', 'atlas_warm'],
      ['tpl-act-2', 'stretch', '腘绳肌拉伸', '坐姿体前屈，不弹振，每侧 30 秒', '改善后链柔韧', '膝可微屈', 'atlas_stretch'],
      ['tpl-act-3', 'stretch', '胸椎伸展', '毛巾卷垫于上背，缓慢开合', '打开含胸体态', '腰不要过度后仰', 'atlas_stretch'],
      ['tpl-act-4', 'strength', '徒手深蹲', '核心收紧，膝不超过脚尖', '强化下肢与核心', '脚掌踩实', 'atlas_strength'],
      ['tpl-act-5', 'strength', '平板支撑', '保持躯干一条直线 20–40 秒', '稳定核心', '塌腰时立即结束', 'atlas_strength'],
      ['tpl-act-6', 'balance', '单腿站立', '每侧 30 秒，可扶墙', '提高踝膝稳定', '微屈支撑腿', 'atlas_balance'],
      ['tpl-act-7', 'balance', '直线行走', '脚尖碰脚跟慢走 10 步', '训练步态控制', '视线看前方', 'atlas_balance'],
      ['tpl-act-8', 'relax', '仰卧呼吸', '仰卧屈膝，鼻吸口呼 10 次', '让神经系统降速', '肩放松贴地', 'atlas_relax'],
      ['tpl-act-9', 'relax', '轻松漫步', '室内慢走 5 分钟收尾', '促进恢复循环', '步幅放小', 'atlas_relax']
    ]
    const out: LibraryAction[] = []
    for (const row of rows) {
      const a = new LibraryAction()
      a.id = row[0]
      a.category = row[1]
      a.name = row[2]
      a.desc = row[3]
      a.purpose = row[4]
      a.caution = row[5]
      a.coverKey = row[6]
      out.push(a)
    }
    return out
  }

  private static defaultLists(): PrepList[] {
    const a = new PrepList()
    a.id = 'tpl-list-0'
    a.title = '今日训练准备'
    a.itemsText = '水壶|毛巾|训练鞋|从动作库选好今日动作'
    a.doneMask = '0000'
    a.rebuildLines()
    const b = new PrepList()
    b.id = 'tpl-list-1'
    b.title = '拉伸步骤'
    b.itemsText = '热身 5 分钟|目标肌群静态拉伸|呼吸放慢|记录体感'
    b.doneMask = '0000'
    b.rebuildLines()
    return [a, b]
  }

  private static async persistPlans(items: CyclePlan[]): Promise<void> {
    const lines: string[] = []
    for (const p of items) {
      lines.push([p.id, p.title, p.goalText, `${p.periodDays}`, p.startKey, p.note].join('\t'))
    }
    await WorkoutStore.writeRaw(KEY_PLANS, lines.join('\n'))
  }

  private static async saveActions(items: LibraryAction[]): Promise<void> {
    const lines: string[] = []
    for (const a of items) {
      lines.push([a.id, a.category, a.name, a.desc, a.purpose, a.caution, a.coverKey, a.favorited ? '1' : '0'].join('\t'))
    }
    await WorkoutStore.writeRaw(KEY_ACTIONS, lines.join('\n'))
  }

  private static async saveLists(items: PrepList[]): Promise<void> {
    const lines: string[] = []
    for (const p of items) {
      lines.push([p.id, p.title, p.itemsText, p.doneMask].join('\t'))
    }
    await WorkoutStore.writeRaw(KEY_LISTS, lines.join('\n'))
  }

  private static async persistFavs(items: InsightFav[]): Promise<void> {
    const lines: string[] = []
    for (const f of items) {
      lines.push([f.id, f.title, f.body.replace(/\t/g, ' ').replace(/\n/g, ' ')].join('\t'))
    }
    await WorkoutStore.writeRaw(KEY_FAVS, lines.join('\n'))
  }

  private static async persistChallenges(items: GoalChallenge[]): Promise<void> {
    const lines: string[] = []
    for (const c of items) {
      lines.push([c.id, c.title, c.kind, `${c.target}`, c.done ? '1' : '0'].join('\t'))
    }
    await WorkoutStore.writeRaw(KEY_CHALLENGES, lines.join('\n'))
  }

  private static parsePlans(raw: string): CyclePlan[] {
    const out: CyclePlan[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('\t')
      if (parts.length < 5) {
        continue
      }
      const p = new CyclePlan()
      p.id = parts[0]
      p.title = parts[1]
      p.goalText = parts[2]
      p.periodDays = DateHelper.safeInt(parts[3], 30)
      p.startKey = parts[4]
      if (parts.length >= 6) {
        p.note = parts[5]
      }
      out.push(p)
    }
    return out
  }

  private static parseActions(raw: string): LibraryAction[] {
    const out: LibraryAction[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('\t')
      if (parts.length < 4) {
        continue
      }
      const a = new LibraryAction()
      a.id = parts[0]
      a.category = parts[1]
      a.name = parts[2]
      a.desc = parts[3]
      if (parts.length >= 5) {
        a.purpose = parts[4]
      }
      if (parts.length >= 6) {
        a.caution = parts[5]
      }
      if (parts.length >= 7 && parts[6].length > 0) {
        a.coverKey = parts[6]
      } else {
        a.coverKey = TrainingStore.coverForCategory(a.category)
      }
      if (parts.length >= 8) {
        a.favorited = parts[7] === '1'
      }
      out.push(a)
    }
    return out
  }

  private static parseLists(raw: string): PrepList[] {
    const out: PrepList[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('\t')
      if (parts.length < 3) {
        continue
      }
      const p = new PrepList()
      p.id = parts[0]
      p.title = parts[1]
      p.itemsText = parts[2]
      if (parts.length >= 4) {
        p.doneMask = parts[3]
      }
      p.rebuildLines()
      out.push(p)
    }
    return out
  }

  private static parseFavs(raw: string): InsightFav[] {
    const out: InsightFav[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('\t')
      if (parts.length < 3) {
        continue
      }
      const f = new InsightFav()
      f.id = parts[0]
      f.title = parts[1]
      f.body = parts[2]
      out.push(f)
    }
    return out
  }

  private static parseChallenges(raw: string): GoalChallenge[] {
    const out: GoalChallenge[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('\t')
      if (parts.length < 5) {
        continue
      }
      const c = new GoalChallenge()
      c.id = parts[0]
      c.title = parts[1]
      c.kind = parts[2]
      c.target = DateHelper.safeInt(parts[3], 21)
      c.done = parts[4] === '1'
      out.push(c)
    }
    return out
  }
}
