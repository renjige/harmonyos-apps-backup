import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { JsonChunks } from './JsonChunks'
import { PavilionTime } from '../models/PavilionModels'
import { PavilionDetailNav } from './PavilionDetailNav'

const STORE = 'shiquge_journal'
const KEY_LOGS = 'logs_raw'
const KEY_FINDS = 'finds_raw'
const KEY_WISH = 'wish_raw'
const KEY_QUIZ = 'quiz_hist'

export class ExploreLog {
  id: string = ''
  title: string = ''
  body: string = ''
  category: string = 'like'
  createdAt: string = ''

  categoryLabel(): string {
    if (this.category === 'find') {
      return '新发现的知识'
    }
    if (this.category === 'topic') {
      return '感兴趣的话题'
    }
    return '最近喜欢的事物'
  }
}

export class DailyFind {
  id: string = ''
  dateKey: string = ''
  title: string = ''
  body: string = ''
}

export class WishItem {
  id: string = ''
  title: string = ''
  kind: string = 'person'
  status: string = 'todo'

  kindLabel(): string {
    if (this.kind === 'skill') {
      return '想学习的技能'
    }
    if (this.kind === 'activity') {
      return '想尝试的活动'
    }
    return '想了解的历史人物'
  }

  statusLabel(): string {
    if (this.status === 'doing') {
      return '进行中'
    }
    if (this.status === 'done') {
      return '已完成'
    }
    return '未开始'
  }
}

export class GrowthRow {
  id: string = ''
  label: string = ''
  count: number = 0
  stars: string = '☆☆☆☆☆'
}

export class JournalStore {
  private static pref: preferences.Preferences | null = null
  private static logs: ExploreLog[] = []
  private static finds: DailyFind[] = []
  private static wishes: WishItem[] = []
  private static quizHist: string = ''

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      JournalStore.pref = await preferences.getPreferences(context, STORE)
      JournalStore.logs = JournalStore.parseLogs(await JournalStore.read(KEY_LOGS, '{"list":[]}'))
      JournalStore.finds = JournalStore.parseFinds(await JournalStore.read(KEY_FINDS, '{"list":[]}'))
      JournalStore.wishes = JournalStore.parseWish(await JournalStore.read(KEY_WISH, '{"list":[]}'))
      JournalStore.quizHist = await JournalStore.read(KEY_QUIZ, '')
    } catch {
      JournalStore.logs = []
      JournalStore.finds = []
      JournalStore.wishes = []
    }
  }

  static logList(): ExploreLog[] {
    return JournalStore.copyLogs(JournalStore.logs)
  }

  static findList(): DailyFind[] {
    return JournalStore.copyFinds(JournalStore.finds)
  }

  static wishList(): WishItem[] {
    return JournalStore.copyWish(JournalStore.wishes)
  }

  static quizLines(): string[] {
    return JournalStore.split(JournalStore.quizHist)
  }

  static logCount(): number {
    return JournalStore.logs.length
  }

  static findCount(): number {
    return JournalStore.finds.length
  }

  static wishDoneCount(): number {
    let n = 0
    for (const w of JournalStore.wishes) {
      if (w.status === 'done') {
        n++
      }
    }
    return n
  }

  static async saveLog(title: string, body: string, category: string): Promise<void> {
    const row = new ExploreLog()
    row.id = `log_${Date.now()}`
    row.title = title.length > 0 ? title : '未命名探索'
    row.body = body
    row.category = category.length > 0 ? category : 'like'
    row.createdAt = PavilionTime.todayKey()
    const next: ExploreLog[] = [row]
    for (const x of JournalStore.logs) {
      next.push(x)
    }
    JournalStore.logs = next
    await JournalStore.put(KEY_LOGS, JournalStore.encodeLogs())
    JournalStore.bump()
  }

  static async deleteLog(id: string): Promise<void> {
    const next: ExploreLog[] = []
    for (const x of JournalStore.logs) {
      if (x.id !== id) {
        next.push(x)
      }
    }
    JournalStore.logs = next
    await JournalStore.put(KEY_LOGS, JournalStore.encodeLogs())
    JournalStore.bump()
  }

  static async saveFind(title: string, body: string): Promise<void> {
    const row = new DailyFind()
    row.id = `find_${Date.now()}`
    row.dateKey = PavilionTime.todayKey()
    row.title = title.length > 0 ? title : '今日发现'
    row.body = body
    const next: DailyFind[] = [row]
    for (const x of JournalStore.finds) {
      next.push(x)
    }
    JournalStore.finds = next
    await JournalStore.put(KEY_FINDS, JournalStore.encodeFinds())
    JournalStore.bump()
  }

  static async deleteFind(id: string): Promise<void> {
    const next: DailyFind[] = []
    for (const x of JournalStore.finds) {
      if (x.id !== id) {
        next.push(x)
      }
    }
    JournalStore.finds = next
    await JournalStore.put(KEY_FINDS, JournalStore.encodeFinds())
    JournalStore.bump()
  }

  static async saveWish(title: string, kind: string): Promise<void> {
    const row = new WishItem()
    row.id = `wish_${Date.now()}`
    row.title = title.length > 0 ? title : '未命名清单'
    row.kind = kind.length > 0 ? kind : 'person'
    row.status = 'todo'
    const next: WishItem[] = [row]
    for (const x of JournalStore.wishes) {
      next.push(x)
    }
    JournalStore.wishes = next
    await JournalStore.put(KEY_WISH, JournalStore.encodeWish())
    JournalStore.bump()
  }

  static async cycleWish(id: string): Promise<void> {
    for (const w of JournalStore.wishes) {
      if (w.id === id) {
        if (w.status === 'todo') {
          w.status = 'doing'
        } else if (w.status === 'doing') {
          w.status = 'done'
        } else {
          w.status = 'todo'
        }
      }
    }
    await JournalStore.put(KEY_WISH, JournalStore.encodeWish())
    JournalStore.bump()
  }

  static async deleteWish(id: string): Promise<void> {
    const next: WishItem[] = []
    for (const x of JournalStore.wishes) {
      if (x.id !== id) {
        next.push(x)
      }
    }
    JournalStore.wishes = next
    await JournalStore.put(KEY_WISH, JournalStore.encodeWish())
    JournalStore.bump()
  }

  static async appendQuiz(line: string): Promise<void> {
    JournalStore.quizHist = JournalStore.quizHist.length > 0 ? `${line},${JournalStore.quizHist}` : line
    await JournalStore.put(KEY_QUIZ, JournalStore.quizHist)
  }

  static growthMap(): GrowthRow[] {
    let likeN = 0
    let findN = 0
    let topicN = 0
    for (const log of JournalStore.logs) {
      if (log.category === 'like') {
        likeN = likeN + 1
      } else if (log.category === 'find') {
        findN = findN + 1
      } else {
        topicN = topicN + 1
      }
    }
    const out: GrowthRow[] = []
    out.push(JournalStore.rowOf('like', '喜欢的事物', likeN))
    out.push(JournalStore.rowOf('find', '新发现知识', findN))
    out.push(JournalStore.rowOf('topic', '兴趣话题', topicN))
    out.push(JournalStore.rowOf('wish', '兴趣清单完成', JournalStore.wishDoneCount()))
    out.push(JournalStore.rowOf('daily', '每日发现', JournalStore.finds.length))
    return out
  }

  private static rowOf(id: string, label: string, count: number): GrowthRow {
    const r = new GrowthRow()
    r.id = id
    r.label = label
    r.count = count
    r.stars = JournalStore.starOf(count)
    return r
  }

  private static starOf(n: number): string {
    if (n >= 8) {
      return '★★★★★'
    }
    if (n >= 5) {
      return '★★★★☆'
    }
    if (n >= 3) {
      return '★★★☆☆'
    }
    if (n >= 2) {
      return '★★☆☆☆'
    }
    if (n >= 1) {
      return '★☆☆☆☆'
    }
    return '☆☆☆☆☆'
  }

  private static async read(key: string, fallback: string): Promise<string> {
    if (JournalStore.pref === null) {
      return fallback
    }
    const raw = await JournalStore.pref.get(key, fallback)
    return typeof raw === 'string' ? raw : fallback
  }

  private static async put(key: string, value: string): Promise<void> {
    if (JournalStore.pref === null) {
      return
    }
    await JournalStore.pref.put(key, value)
    await JournalStore.pref.flush()
  }

  private static bump(): void {
    PavilionDetailNav.bumpRefresh()
  }

  private static split(text: string): string[] {
    const out: string[] = []
    if (text.length === 0) {
      return out
    }
    const parts = text.split(',')
    for (const p of parts) {
      if (p.length > 0) {
        out.push(p)
      }
    }
    return out
  }

  private static parseLogs(raw: string): ExploreLog[] {
    const out: ExploreLog[] = []
    for (const ch of JsonChunks.objectsInList(raw)) {
      const r = new ExploreLog()
      r.id = JsonChunks.str(ch, 'id')
      r.title = JsonChunks.str(ch, 'title')
      r.body = JsonChunks.str(ch, 'body')
      r.category = JsonChunks.str(ch, 'category')
      r.createdAt = JsonChunks.str(ch, 'createdAt')
      if (r.id.length > 0) {
        out.push(r)
      }
    }
    return out
  }

  private static parseFinds(raw: string): DailyFind[] {
    const out: DailyFind[] = []
    for (const ch of JsonChunks.objectsInList(raw)) {
      const r = new DailyFind()
      r.id = JsonChunks.str(ch, 'id')
      r.dateKey = JsonChunks.str(ch, 'dateKey')
      r.title = JsonChunks.str(ch, 'title')
      r.body = JsonChunks.str(ch, 'body')
      if (r.id.length > 0) {
        out.push(r)
      }
    }
    return out
  }

  private static parseWish(raw: string): WishItem[] {
    const out: WishItem[] = []
    for (const ch of JsonChunks.objectsInList(raw)) {
      const r = new WishItem()
      r.id = JsonChunks.str(ch, 'id')
      r.title = JsonChunks.str(ch, 'title')
      r.kind = JsonChunks.str(ch, 'kind')
      r.status = JsonChunks.str(ch, 'status')
      if (r.id.length > 0) {
        out.push(r)
      }
    }
    return out
  }

  private static encodeLogs(): string {
    let s = '{"list":['
    let first = true
    for (const r of JournalStore.logs) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":${JSON.stringify(r.id)},"title":${JSON.stringify(r.title)},"body":${JSON.stringify(r.body)},` +
        `"category":${JSON.stringify(r.category)},"createdAt":${JSON.stringify(r.createdAt)}}`
    }
    return `${s}]}`
  }

  private static encodeFinds(): string {
    let s = '{"list":['
    let first = true
    for (const r of JournalStore.finds) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":${JSON.stringify(r.id)},"dateKey":${JSON.stringify(r.dateKey)},"title":${JSON.stringify(r.title)},` +
        `"body":${JSON.stringify(r.body)}}`
    }
    return `${s}]}`
  }

  private static encodeWish(): string {
    let s = '{"list":['
    let first = true
    for (const r of JournalStore.wishes) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":${JSON.stringify(r.id)},"title":${JSON.stringify(r.title)},"kind":${JSON.stringify(r.kind)},` +
        `"status":${JSON.stringify(r.status)}}`
    }
    return `${s}]}`
  }

  private static copyLogs(src: ExploreLog[]): ExploreLog[] {
    const out: ExploreLog[] = []
    for (const x of src) {
      out.push(x)
    }
    return out
  }

  private static copyFinds(src: DailyFind[]): DailyFind[] {
    const out: DailyFind[] = []
    for (const x of src) {
      out.push(x)
    }
    return out
  }

  private static copyWish(src: WishItem[]): WishItem[] {
    const out: WishItem[] = []
    for (const x of src) {
      out.push(x)
    }
    return out
  }
}
