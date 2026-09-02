import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { ChecklistItem, FavFolder, GoalState, KnowledgeCard, NoteItem, PlanItem, ProgramItem,
  ChallengeItem, ThemeBook, TrainLog } from '../models/TuceModels'

const STORE = 'yundong_tuce_album_v2'

export class TuceStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      TuceStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      TuceStore.pref = null
    }
    await TuceStore.ensureDefaults()
  }

  static async favIds(): Promise<string[]> {
    return TuceStore.split(await TuceStore.get('favs', ''))
  }

  static async toggleFav(id: string): Promise<boolean> {
    const ids = await TuceStore.favIds()
    const next: string[] = []
    let on = false
    let found = false
    for (const it of ids) {
      if (it === id) {
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(id)
      on = true
    }
    await TuceStore.put('favs', next.join('|'))
    return on
  }

  static async isFav(id: string): Promise<boolean> {
    const ids = await TuceStore.favIds()
    for (const it of ids) {
      if (it === id) {
        return true
      }
    }
    return false
  }

  static async folders(): Promise<FavFolder[]> {
    return TuceStore.parseFolders(await TuceStore.get('folders', ''))
  }

  static async saveFolder(item: FavFolder): Promise<void> {
    const list = await TuceStore.folders()
    await TuceStore.put('folders', TuceStore.writeFolders(TuceStore.upsertFolder(list, item)))
  }

  static async plans(): Promise<PlanItem[]> {
    return TuceStore.parsePlans(await TuceStore.get('plans', ''))
  }

  static async savePlan(item: PlanItem): Promise<void> {
    const list = await TuceStore.plans()
    await TuceStore.put('plans', TuceStore.writePlans(TuceStore.upsertPlan(list, item)))
  }

  static async deletePlan(id: string): Promise<void> {
    const list = await TuceStore.plans()
    const next: PlanItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await TuceStore.put('plans', TuceStore.writePlans(next))
  }

  static async findPlan(id: string): Promise<PlanItem | undefined> {
    const list = await TuceStore.plans()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async programs(): Promise<ProgramItem[]> {
    return TuceStore.parsePrograms(await TuceStore.get('programs', ''))
  }

  static async saveProgram(item: ProgramItem): Promise<void> {
    const list = await TuceStore.programs()
    await TuceStore.put('programs', TuceStore.writePrograms(TuceStore.upsertProgram(list, item)))
  }

  static async findProgram(id: string): Promise<ProgramItem | undefined> {
    const list = await TuceStore.programs()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async deleteProgram(id: string): Promise<void> {
    const list = await TuceStore.programs()
    const next: ProgramItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await TuceStore.put('programs', TuceStore.writePrograms(next))
  }

  static async deleteTheme(id: string): Promise<void> {
    const list = await TuceStore.themes()
    const next: ThemeBook[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await TuceStore.put('themes', TuceStore.writeThemes(next))
  }

  static async deleteFolder(id: string): Promise<void> {
    const list = await TuceStore.folders()
    const next: FavFolder[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await TuceStore.put('folders', TuceStore.writeFolders(next))
  }

  static async addMoveToFolder(folderId: string, moveId: string): Promise<void> {
    const list = await TuceStore.folders()
    for (const it of list) {
      if (it.id === folderId) {
        const ids = TuceStore.split(it.moveIds)
        for (const existing of ids) {
          if (existing === moveId) {
            return
          }
        }
        ids.push(moveId)
        it.moveIds = ids.join('|')
        await TuceStore.saveFolder(it)
        return
      }
    }
  }

  static async dailyThemeWord(): Promise<string> {
    const raw = await TuceStore.get('dailyTheme', '')
    const today = TuceStore.today()
    const prefix = `${today}\t`
    if (raw.indexOf(prefix) === 0) {
      return raw.substring(prefix.length)
    }
    return ''
  }

  static async saveDailyTheme(word: string): Promise<void> {
    await TuceStore.put('dailyTheme', `${TuceStore.today()}\t${word.trim()}`)
  }

  static async logs(): Promise<TrainLog[]> {
    return TuceStore.parseLogs(await TuceStore.get('logs', ''))
  }

  static async saveLog(item: TrainLog): Promise<void> {
    const list = await TuceStore.logs()
    await TuceStore.put('logs', TuceStore.writeLogs(TuceStore.upsertLog(list, item)))
  }

  static async deleteLog(id: string): Promise<void> {
    const list = await TuceStore.logs()
    const next: TrainLog[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await TuceStore.put('logs', TuceStore.writeLogs(next))
  }

  static async checkins(): Promise<string[]> {
    return TuceStore.split(await TuceStore.get('checkins', ''))
  }

  static async addCheckin(date: string): Promise<void> {
    const ids = await TuceStore.checkins()
    for (const it of ids) {
      if (it === date) {
        return
      }
    }
    ids.push(date)
    await TuceStore.put('checkins', ids.join('|'))
  }

  static async challenges(): Promise<ChallengeItem[]> {
    return TuceStore.parseChallenges(await TuceStore.get('challenges', ''))
  }

  static async saveChallenge(item: ChallengeItem): Promise<void> {
    const list = await TuceStore.challenges()
    await TuceStore.put('challenges', TuceStore.writeChallenges(TuceStore.upsertChallenge(list, item)))
  }

  static async themes(): Promise<ThemeBook[]> {
    return TuceStore.parseThemes(await TuceStore.get('themes', ''))
  }

  static async saveTheme(item: ThemeBook): Promise<void> {
    const list = await TuceStore.themes()
    await TuceStore.put('themes', TuceStore.writeThemes(TuceStore.upsertTheme(list, item)))
  }

  static async notes(): Promise<NoteItem[]> {
    return TuceStore.parseNotes(await TuceStore.get('notes', ''))
  }

  static async saveNote(item: NoteItem): Promise<void> {
    const list = await TuceStore.notes()
    await TuceStore.put('notes', TuceStore.writeNotes(TuceStore.upsertNote(list, item)))
  }

  static async deleteNote(id: string): Promise<void> {
    const list = await TuceStore.notes()
    const next: NoteItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await TuceStore.put('notes', TuceStore.writeNotes(next))
  }

  static async cards(): Promise<KnowledgeCard[]> {
    return TuceStore.parseCards(await TuceStore.get('cards', ''))
  }

  static async saveCard(item: KnowledgeCard): Promise<void> {
    const list = await TuceStore.cards()
    await TuceStore.put('cards', TuceStore.writeCards(TuceStore.upsertCard(list, item)))
  }

  static async goal(): Promise<GoalState> {
    const raw = await TuceStore.get('goal', '3\t15\t7')
    const p = raw.split('\t')
    const g = new GoalState()
    if (p.length >= 3) {
      g.weekly = parseInt(p[0], 10)
      g.monthly = parseInt(p[1], 10)
      g.streak = parseInt(p[2], 10)
    }
    return g
  }

  static async saveGoal(g: GoalState): Promise<void> {
    await TuceStore.put('goal', `${g.weekly}\t${g.monthly}\t${g.streak}`)
  }

  static async checklist(): Promise<ChecklistItem[]> {
    const raw = await TuceStore.get('checklist', '')
    if (raw.length === 0) {
      return TuceStore.defaultChecklist()
    }
    return TuceStore.parseChecklist(raw)
  }

  static async toggleChecklist(id: string): Promise<void> {
    const list = await TuceStore.checklist()
    const next: ChecklistItem[] = []
    for (const it of list) {
      const copy = new ChecklistItem()
      copy.id = it.id
      copy.label = it.label
      copy.phase = it.phase
      copy.done = it.id === id ? !it.done : it.done
      next.push(copy)
    }
    await TuceStore.put('checklist', TuceStore.writeChecklist(next))
  }

  static async resetChecklist(): Promise<void> {
    await TuceStore.put('checklist', TuceStore.writeChecklist(TuceStore.defaultChecklist()))
  }

  static async deleteCard(id: string): Promise<void> {
    const list = await TuceStore.cards()
    const next: KnowledgeCard[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await TuceStore.put('cards', TuceStore.writeCards(next))
  }

  static async findNote(id: string): Promise<NoteItem | undefined> {
    const list = await TuceStore.notes()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static today(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  private static async ensureDefaults(): Promise<void> {
    const themes = await TuceStore.themes()
    if (themes.length > 0) {
      return
    }
    const a = new ThemeBook()
    a.id = 'theme_morning'
    a.name = '晨间活力册'
    a.moveIds = 'm01|m07|m10|m04'
    const b = new ThemeBook()
    b.id = 'theme_stretch'
    b.name = '拉伸恢复册'
    b.moveIds = 'm04|m05|m17|m22'
    const c = new ThemeBook()
    c.id = 'theme_core'
    c.name = '核心训练册'
    c.moveIds = 'm13|m14|m15'
    const list: ThemeBook[] = []
    list.push(a)
    list.push(b)
    list.push(c)
    await TuceStore.put('themes', TuceStore.writeThemes(list))
    const f1 = new FavFolder()
    f1.id = 'folder_morning'
    f1.name = '晨间精选'
    f1.moveIds = 'm01|m07|m10'
    const f2 = new FavFolder()
    f2.id = 'folder_stretch'
    f2.name = '拉伸恢复'
    f2.moveIds = 'm04|m05|m17'
    const folders: FavFolder[] = []
    folders.push(f1)
    folders.push(f2)
    await TuceStore.put('folders', TuceStore.writeFolders(folders))
    await TuceStore.put('checklist', TuceStore.writeChecklist(TuceStore.defaultChecklist()))
  }

  private static defaultChecklist(): ChecklistItem[] {
    const defs: string[][] = [
      ['cl1', 'before', '换好运动服与鞋'],
      ['cl2', 'before', '喝一小杯水'],
      ['cl3', 'before', '简单热身 3 分钟'],
      ['cl4', 'after', '拉伸放松 5 分钟'],
      ['cl5', 'after', '记录今日训练感受'],
      ['cl6', 'after', '补充蛋白质或水果']
    ]
    const out: ChecklistItem[] = []
    for (const row of defs) {
      const it = new ChecklistItem()
      it.id = row[0]
      it.phase = row[1]
      it.label = row[2]
      it.done = false
      out.push(it)
    }
    return out
  }

  private static parseChecklist(raw: string): ChecklistItem[] {
    const out: ChecklistItem[] = []
    for (const line of TuceStore.lines(raw)) {
      const p = line.split('\t')
      if (p.length < 4) {
        continue
      }
      const it = new ChecklistItem()
      it.id = p[0]
      it.phase = p[1]
      it.label = p[2]
      it.done = p[3] === '1'
      out.push(it)
    }
    return out
  }

  private static writeChecklist(list: ChecklistItem[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push(`${it.id}\t${it.phase}\t${it.label}\t${it.done ? '1' : '0'}`)
    }
    return lines.join('\n')
  }

  private static split(raw: string): string[] {
    if (raw.length === 0) {
      return []
    }
    return raw.split('|')
  }

  private static async get(key: string, fallback: string): Promise<string> {
    if (TuceStore.pref === null) {
      return fallback
    }
    try {
      const v = await TuceStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async put(key: string, value: string): Promise<void> {
    if (TuceStore.pref === null) {
      return
    }
    try {
      await TuceStore.pref.put(key, value)
      await TuceStore.pref.flush()
    } catch {
    }
  }

  private static parseFolders(raw: string): FavFolder[] {
    const out: FavFolder[] = []
    for (const line of TuceStore.lines(raw)) {
      const p = line.split('\t')
      if (p.length < 3) {
        continue
      }
      const it = new FavFolder()
      it.id = p[0]
      it.name = p[1]
      it.moveIds = p[2]
      out.push(it)
    }
    return out
  }

  private static writeFolders(list: FavFolder[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push(`${it.id}\t${it.name}\t${it.moveIds}`)
    }
    return lines.join('\n')
  }

  private static upsertFolder(list: FavFolder[], item: FavFolder): FavFolder[] {
    const next: FavFolder[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    return next
  }

  private static parsePlans(raw: string): PlanItem[] {
    const out: PlanItem[] = []
    for (const line of TuceStore.lines(raw)) {
      const p = line.split('\t')
      if (p.length < 8) {
        continue
      }
      const it = new PlanItem()
      it.id = p[0]
      it.name = p[1]
      it.moveIds = p[2]
      it.reps = p[3]
      it.minutes = parseInt(p[4], 10)
      it.restSec = parseInt(p[5], 10)
      it.note = p[6].replace(/\\n/g, '\n')
      it.createdAt = parseInt(p[7], 10)
      out.push(it)
    }
    return out
  }

  private static writePlans(list: PlanItem[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push(`${it.id}\t${it.name}\t${it.moveIds}\t${it.reps}\t${it.minutes}\t${it.restSec}\t${it.note.replace(/\n/g, '\\n')}\t${it.createdAt}`)
    }
    return lines.join('\n')
  }

  private static upsertPlan(list: PlanItem[], item: PlanItem): PlanItem[] {
    const next: PlanItem[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    return next
  }

  private static parsePrograms(raw: string): ProgramItem[] {
    const out: ProgramItem[] = []
    for (const line of TuceStore.lines(raw)) {
      const p = line.split('\t')
      if (p.length < 6) {
        continue
      }
      const it = new ProgramItem()
      it.id = p[0]
      it.name = p[1]
      it.days = parseInt(p[2], 10)
      it.planId = p[3]
      it.startDate = p[4]
      it.doneDates = p[5]
      out.push(it)
    }
    return out
  }

  private static writePrograms(list: ProgramItem[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push(`${it.id}\t${it.name}\t${it.days}\t${it.planId}\t${it.startDate}\t${it.doneDates}`)
    }
    return lines.join('\n')
  }

  private static upsertProgram(list: ProgramItem[], item: ProgramItem): ProgramItem[] {
    const next: ProgramItem[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    return next
  }

  private static parseLogs(raw: string): TrainLog[] {
    const out: TrainLog[] = []
    for (const line of TuceStore.lines(raw)) {
      const p = line.split('\t')
      if (p.length < 10) {
        continue
      }
      const it = new TrainLog()
      it.id = p[0]
      it.date = p[1]
      it.planName = p[2]
      it.doneText = p[3]
      it.feel = p[4]
      it.difficulty = parseInt(p[5], 10)
      it.fun = parseInt(p[6], 10)
      it.complete = parseInt(p[7], 10)
      it.note = p[8].replace(/\\n/g, '\n')
      it.createdAt = parseInt(p[9], 10)
      out.push(it)
    }
    return out
  }

  private static writeLogs(list: TrainLog[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push(`${it.id}\t${it.date}\t${it.planName}\t${it.doneText}\t${it.feel}\t${it.difficulty}\t${it.fun}\t${it.complete}\t${it.note.replace(/\n/g, '\\n')}\t${it.createdAt}`)
    }
    return lines.join('\n')
  }

  private static upsertLog(list: TrainLog[], item: TrainLog): TrainLog[] {
    const next: TrainLog[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    next.sort((a: TrainLog, b: TrainLog) => b.createdAt - a.createdAt)
    return next
  }

  private static parseChallenges(raw: string): ChallengeItem[] {
    const out: ChallengeItem[] = []
    for (const line of TuceStore.lines(raw)) {
      const p = line.split('\t')
      if (p.length < 5) {
        continue
      }
      const it = new ChallengeItem()
      it.id = p[0]
      it.title = p[1]
      it.days = parseInt(p[2], 10)
      it.startDate = p[3]
      it.doneDates = p[4]
      out.push(it)
    }
    return out
  }

  private static writeChallenges(list: ChallengeItem[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push(`${it.id}\t${it.title}\t${it.days}\t${it.startDate}\t${it.doneDates}`)
    }
    return lines.join('\n')
  }

  private static upsertChallenge(list: ChallengeItem[], item: ChallengeItem): ChallengeItem[] {
    const next: ChallengeItem[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    return next
  }

  private static parseThemes(raw: string): ThemeBook[] {
    const out: ThemeBook[] = []
    for (const line of TuceStore.lines(raw)) {
      const p = line.split('\t')
      if (p.length < 3) {
        continue
      }
      const it = new ThemeBook()
      it.id = p[0]
      it.name = p[1]
      it.moveIds = p[2]
      out.push(it)
    }
    return out
  }

  private static writeThemes(list: ThemeBook[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push(`${it.id}\t${it.name}\t${it.moveIds}`)
    }
    return lines.join('\n')
  }

  private static upsertTheme(list: ThemeBook[], item: ThemeBook): ThemeBook[] {
    const next: ThemeBook[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    return next
  }

  private static parseNotes(raw: string): NoteItem[] {
    const out: NoteItem[] = []
    for (const line of TuceStore.lines(raw)) {
      const p = line.split('\t')
      if (p.length < 4) {
        continue
      }
      const it = new NoteItem()
      it.id = p[0]
      it.title = p[1]
      it.body = p[2].replace(/\\n/g, '\n')
      it.createdAt = parseInt(p[3], 10)
      out.push(it)
    }
    return out
  }

  private static writeNotes(list: NoteItem[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push(`${it.id}\t${it.title}\t${it.body.replace(/\n/g, '\\n')}\t${it.createdAt}`)
    }
    return lines.join('\n')
  }

  private static upsertNote(list: NoteItem[], item: NoteItem): NoteItem[] {
    const next: NoteItem[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    return next
  }

  private static parseCards(raw: string): KnowledgeCard[] {
    const out: KnowledgeCard[] = []
    for (const line of TuceStore.lines(raw)) {
      const p = line.split('\t')
      if (p.length < 6) {
        continue
      }
      const it = new KnowledgeCard()
      it.id = p[0]
      it.moveName = p[1]
      it.focus = p[2]
      it.rhythm = p[3]
      it.caution = p[4]
      it.insight = p[5]
      out.push(it)
    }
    return out
  }

  private static writeCards(list: KnowledgeCard[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push(`${it.id}\t${it.moveName}\t${it.focus}\t${it.rhythm}\t${it.caution}\t${it.insight}`)
    }
    return lines.join('\n')
  }

  private static upsertCard(list: KnowledgeCard[], item: KnowledgeCard): KnowledgeCard[] {
    const next: KnowledgeCard[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    return next
  }

  private static lines(raw: string): string[] {
    if (raw.length === 0) {
      return []
    }
    return raw.split('\n')
  }
}
