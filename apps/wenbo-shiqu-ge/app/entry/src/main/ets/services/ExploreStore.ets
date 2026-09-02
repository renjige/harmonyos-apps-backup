import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { JsonChunks } from './JsonChunks'
import { PavilionTime } from '../models/PavilionModels'
import { PavilionDetailNav } from './PavilionDetailNav'

const STORE = 'shiquge_explore'
const KEY_NOTES = 'notes_raw'
const KEY_TASKS = 'tasks_raw'
const KEY_CARDS = 'cards_raw'
const KEY_ALBUMS = 'albums_raw'
const KEY_TAGS = 'custom_tags'
const KEY_FOCUS = 'focus_cats'
const KEY_DAYS = 'explore_days'
const KEY_QUIZ = 'quiz_last'

export class ExploreNote {
  id: string = ''
  title: string = ''
  body: string = ''
  coverKey: string = 'hero_bg'
  articleId: string = ''
  createdAt: string = ''
  tags: string = ''
}

export class ExploreTask {
  id: string = ''
  title: string = ''
  done: boolean = false
  dateKey: string = ''
}

export class ExploreCard {
  id: string = ''
  title: string = ''
  body: string = ''
  articleId: string = ''
  tags: string = ''
}

export class ExploreAlbum {
  id: string = ''
  title: string = ''
  ids: string = ''
}

export class ExploreStore {
  private static pref: preferences.Preferences | null = null
  private static notes: ExploreNote[] = []
  private static tasks: ExploreTask[] = []
  private static cards: ExploreCard[] = []
  private static albums: ExploreAlbum[] = []
  private static tags: string = '动植物,天文,地理,人文,科学'
  private static focus: string = ''
  private static days: string = ''
  private static quizLast: string = ''

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ExploreStore.pref = await preferences.getPreferences(context, STORE)
      ExploreStore.notes = ExploreStore.parseNotes(await ExploreStore.read(KEY_NOTES, '{"list":[]}'))
      ExploreStore.tasks = ExploreStore.parseTasks(await ExploreStore.read(KEY_TASKS, '{"list":[]}'))
      ExploreStore.cards = ExploreStore.parseCards(await ExploreStore.read(KEY_CARDS, '{"list":[]}'))
      ExploreStore.albums = ExploreStore.parseAlbums(await ExploreStore.read(KEY_ALBUMS, '{"list":[]}'))
      if (ExploreStore.albums.length === 0) {
        await ExploreStore.seedEmptyAlbums()
      }
      ExploreStore.tags = await ExploreStore.read(KEY_TAGS, '动植物,天文,地理,人文,科学')
      ExploreStore.focus = await ExploreStore.read(KEY_FOCUS, '')
      ExploreStore.days = await ExploreStore.read(KEY_DAYS, '')
      ExploreStore.quizLast = await ExploreStore.read(KEY_QUIZ, '')
    } catch {
      ExploreStore.notes = []
      ExploreStore.tasks = []
      ExploreStore.cards = []
      ExploreStore.albums = []
    }
  }

  static noteList(): ExploreNote[] {
    return ExploreStore.copyNotes(ExploreStore.notes)
  }

  static cardList(): ExploreCard[] {
    return ExploreStore.copyCards(ExploreStore.cards)
  }

  static albumList(): ExploreAlbum[] {
    return ExploreStore.copyAlbums(ExploreStore.albums)
  }

  static customTags(): string[] {
    return ExploreStore.split(ExploreStore.tags)
  }

  static focusCats(): string[] {
    return ExploreStore.split(ExploreStore.focus)
  }

  static dayCount(): number {
    return ExploreStore.split(ExploreStore.days).length
  }

  static quizSummary(): string {
    return ExploreStore.quizLast
  }

  static todayTasks(): ExploreTask[] {
    const today = PavilionTime.todayKey()
    const out: ExploreTask[] = []
    for (const t of ExploreStore.tasks) {
      if (t.dateKey === today) {
        out.push(t)
      }
    }
    if (out.length > 0) {
      return out
    }
    return ExploreStore.seedTodayTasks(today)
  }

  static async saveNote(title: string, body: string, coverKey: string, articleId: string, tags: string): Promise<void> {
    const n = new ExploreNote()
    n.id = `note_${Date.now()}`
    n.title = title.length > 0 ? title : '未命名笔记'
    n.body = body
    n.coverKey = coverKey.length > 0 ? coverKey : 'hero_bg'
    n.articleId = articleId
    n.createdAt = PavilionTime.todayKey()
    n.tags = tags
    const next: ExploreNote[] = [n]
    for (const row of ExploreStore.notes) {
      next.push(row)
    }
    ExploreStore.notes = next
    await ExploreStore.flushList(KEY_NOTES, ExploreStore.encodeNotes())
    await ExploreStore.touchDay()
  }

  static async deleteNote(id: string): Promise<void> {
    const next: ExploreNote[] = []
    for (const row of ExploreStore.notes) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    ExploreStore.notes = next
    await ExploreStore.flushList(KEY_NOTES, ExploreStore.encodeNotes())
    ExploreStore.bump()
  }

  static async saveCard(title: string, body: string, articleId: string, tags: string): Promise<void> {
    const c = new ExploreCard()
    c.id = `card_${Date.now()}`
    c.title = title.length > 0 ? title : '未命名卡片'
    c.body = body
    c.articleId = articleId
    c.tags = tags
    const next: ExploreCard[] = [c]
    for (const row of ExploreStore.cards) {
      next.push(row)
    }
    ExploreStore.cards = next
    await ExploreStore.flushList(KEY_CARDS, ExploreStore.encodeCards())
    await ExploreStore.touchDay()
  }

  static async deleteCard(id: string): Promise<void> {
    const next: ExploreCard[] = []
    for (const row of ExploreStore.cards) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    ExploreStore.cards = next
    await ExploreStore.flushList(KEY_CARDS, ExploreStore.encodeCards())
    ExploreStore.bump()
  }

  static async createAlbum(title: string): Promise<void> {
    const a = new ExploreAlbum()
    a.id = `alb_${Date.now()}`
    a.title = title.length > 0 ? title : '未命名收藏夹'
    a.ids = ''
    const next: ExploreAlbum[] = [a]
    for (const row of ExploreStore.albums) {
      next.push(row)
    }
    ExploreStore.albums = next
    await ExploreStore.flushList(KEY_ALBUMS, ExploreStore.encodeAlbums())
    ExploreStore.bump()
  }

  static async addToAlbum(albumId: string, articleId: string): Promise<void> {
    for (const a of ExploreStore.albums) {
      if (a.id === albumId) {
        if (a.ids.length === 0) {
          a.ids = articleId
        } else if (a.ids.indexOf(articleId) < 0) {
          a.ids = `${a.ids},${articleId}`
        }
      }
    }
    await ExploreStore.flushList(KEY_ALBUMS, ExploreStore.encodeAlbums())
    ExploreStore.bump()
  }

  static albumHas(album: ExploreAlbum, articleId: string): boolean {
    if (album.ids.length === 0) {
      return false
    }
    const parts = album.ids.split(',')
    for (const p of parts) {
      if (p === articleId) {
        return true
      }
    }
    return false
  }

  static async toggleTask(id: string): Promise<void> {
    for (const t of ExploreStore.tasks) {
      if (t.id === id) {
        t.done = !t.done
      }
    }
    await ExploreStore.flushList(KEY_TASKS, ExploreStore.encodeTasks())
    await ExploreStore.touchDay()
  }

  static async addTag(tag: string): Promise<void> {
    const t = tag.trim()
    if (t.length === 0) {
      return
    }
    const cur = ExploreStore.split(ExploreStore.tags)
    for (const x of cur) {
      if (x === t) {
        return
      }
    }
    ExploreStore.tags = ExploreStore.tags.length > 0 ? `${ExploreStore.tags},${t}` : t
    await ExploreStore.put(KEY_TAGS, ExploreStore.tags)
    ExploreStore.bump()
  }

  static async setFocus(cats: string): Promise<void> {
    ExploreStore.focus = cats
    await ExploreStore.put(KEY_FOCUS, cats)
    ExploreStore.bump()
  }

  static async recordQuiz(score: number, total: number): Promise<void> {
    ExploreStore.quizLast = `${PavilionTime.todayKey()} ${score}/${total}`
    await ExploreStore.put(KEY_QUIZ, ExploreStore.quizLast)
    await ExploreStore.touchDay()
  }

  static async touchDay(): Promise<void> {
    const today = PavilionTime.todayKey()
    const parts = ExploreStore.split(ExploreStore.days)
    for (const p of parts) {
      if (p === today) {
        ExploreStore.bump()
        return
      }
    }
    ExploreStore.days = ExploreStore.days.length > 0 ? `${ExploreStore.days},${today}` : today
    await ExploreStore.put(KEY_DAYS, ExploreStore.days)
    ExploreStore.bump()
  }

  static noteCount(): number {
    return ExploreStore.notes.length
  }

  static cardCount(): number {
    return ExploreStore.cards.length
  }

  static taskDoneCount(): number {
    let n = 0
    for (const t of ExploreStore.tasks) {
      if (t.done) {
        n++
      }
    }
    return n
  }

  private static async seedEmptyAlbums(): Promise<void> {
    const a1 = new ExploreAlbum()
    a1.id = 'alb_preset_fun'
    a1.title = '奇闻趣事'
    const a2 = new ExploreAlbum()
    a2.id = 'alb_preset_life'
    a2.title = '生活妙招'
    const a3 = new ExploreAlbum()
    a3.id = 'alb_preset_sci'
    a3.title = '科普知识'
    const a4 = new ExploreAlbum()
    a4.id = 'alb_preset_culture'
    a4.title = '文化故事'
    const list: ExploreAlbum[] = []
    list.push(a1)
    list.push(a2)
    list.push(a3)
    list.push(a4)
    ExploreStore.albums = list
    await ExploreStore.flushList(KEY_ALBUMS, ExploreStore.encodeAlbums())
  }

  private static seedTodayTasks(today: string): ExploreTask[] {
    const t1 = new ExploreTask()
    t1.id = `task_${today}_a`
    t1.title = '发现一个生活技巧'
    t1.done = false
    t1.dateKey = today
    const t2 = new ExploreTask()
    t2.id = `task_${today}_b`
    t2.title = '学习一个冷知识'
    t2.done = false
    t2.dateKey = today
    const t3 = new ExploreTask()
    t3.id = `task_${today}_c`
    t3.title = '阅读一个趣味故事'
    t3.done = false
    t3.dateKey = today
    const list: ExploreTask[] = []
    list.push(t1)
    list.push(t2)
    list.push(t3)
    ExploreStore.tasks = list
    void ExploreStore.flushList(KEY_TASKS, ExploreStore.encodeTasks())
    return list
  }

  private static async read(key: string, fallback: string): Promise<string> {
    if (ExploreStore.pref === null) {
      return fallback
    }
    const raw = await ExploreStore.pref.get(key, fallback)
    return typeof raw === 'string' ? raw : fallback
  }

  private static async put(key: string, value: string): Promise<void> {
    if (ExploreStore.pref === null) {
      return
    }
    await ExploreStore.pref.put(key, value)
    await ExploreStore.pref.flush()
  }

  private static async flushList(key: string, json: string): Promise<void> {
    await ExploreStore.put(key, json)
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

  private static parseNotes(raw: string): ExploreNote[] {
    const out: ExploreNote[] = []
    const chunks = JsonChunks.objectsInList(raw)
    for (const ch of chunks) {
      const n = new ExploreNote()
      n.id = JsonChunks.str(ch, 'id')
      n.title = JsonChunks.str(ch, 'title')
      n.body = JsonChunks.str(ch, 'body')
      n.coverKey = JsonChunks.str(ch, 'coverKey')
      n.articleId = JsonChunks.str(ch, 'articleId')
      n.createdAt = JsonChunks.str(ch, 'createdAt')
      n.tags = JsonChunks.str(ch, 'tags')
      if (n.id.length > 0) {
        out.push(n)
      }
    }
    return out
  }

  private static parseTasks(raw: string): ExploreTask[] {
    const out: ExploreTask[] = []
    const chunks = JsonChunks.objectsInList(raw)
    for (const ch of chunks) {
      const t = new ExploreTask()
      t.id = JsonChunks.str(ch, 'id')
      t.title = JsonChunks.str(ch, 'title')
      t.done = JsonChunks.str(ch, 'done') === '1'
      t.dateKey = JsonChunks.str(ch, 'dateKey')
      if (t.id.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private static parseCards(raw: string): ExploreCard[] {
    const out: ExploreCard[] = []
    const chunks = JsonChunks.objectsInList(raw)
    for (const ch of chunks) {
      const c = new ExploreCard()
      c.id = JsonChunks.str(ch, 'id')
      c.title = JsonChunks.str(ch, 'title')
      c.body = JsonChunks.str(ch, 'body')
      c.articleId = JsonChunks.str(ch, 'articleId')
      c.tags = JsonChunks.str(ch, 'tags')
      if (c.id.length > 0) {
        out.push(c)
      }
    }
    return out
  }

  private static parseAlbums(raw: string): ExploreAlbum[] {
    const out: ExploreAlbum[] = []
    const chunks = JsonChunks.objectsInList(raw)
    for (const ch of chunks) {
      const a = new ExploreAlbum()
      a.id = JsonChunks.str(ch, 'id')
      a.title = JsonChunks.str(ch, 'title')
      a.ids = JsonChunks.str(ch, 'ids')
      if (a.id.length > 0) {
        out.push(a)
      }
    }
    return out
  }

  private static encodeNotes(): string {
    let s = '{"list":['
    for (let i = 0; i < ExploreStore.notes.length; i++) {
      const n = ExploreStore.notes[i]
      if (i > 0) {
        s += ','
      }
      s += `{"id":${JSON.stringify(n.id)},"title":${JSON.stringify(n.title)},"body":${JSON.stringify(n.body)},` +
        `"coverKey":${JSON.stringify(n.coverKey)},"articleId":${JSON.stringify(n.articleId)},` +
        `"createdAt":${JSON.stringify(n.createdAt)},"tags":${JSON.stringify(n.tags)}}`
    }
    return `${s}]}`
  }

  private static encodeTasks(): string {
    let s = '{"list":['
    for (let i = 0; i < ExploreStore.tasks.length; i++) {
      const t = ExploreStore.tasks[i]
      if (i > 0) {
        s += ','
      }
      s += `{"id":${JSON.stringify(t.id)},"title":${JSON.stringify(t.title)},"done":"${t.done ? '1' : '0'}",` +
        `"dateKey":${JSON.stringify(t.dateKey)}}`
    }
    return `${s}]}`
  }

  private static encodeCards(): string {
    let s = '{"list":['
    for (let i = 0; i < ExploreStore.cards.length; i++) {
      const c = ExploreStore.cards[i]
      if (i > 0) {
        s += ','
      }
      s += `{"id":${JSON.stringify(c.id)},"title":${JSON.stringify(c.title)},"body":${JSON.stringify(c.body)},` +
        `"articleId":${JSON.stringify(c.articleId)},"tags":${JSON.stringify(c.tags)}}`
    }
    return `${s}]}`
  }

  private static encodeAlbums(): string {
    let s = '{"list":['
    for (let i = 0; i < ExploreStore.albums.length; i++) {
      const a = ExploreStore.albums[i]
      if (i > 0) {
        s += ','
      }
      s += `{"id":${JSON.stringify(a.id)},"title":${JSON.stringify(a.title)},"ids":${JSON.stringify(a.ids)}}`
    }
    return `${s}]}`
  }

  private static copyNotes(src: ExploreNote[]): ExploreNote[] {
    const out: ExploreNote[] = []
    for (const n of src) {
      out.push(n)
    }
    return out
  }

  private static copyCards(src: ExploreCard[]): ExploreCard[] {
    const out: ExploreCard[] = []
    for (const c of src) {
      out.push(c)
    }
    return out
  }

  private static copyAlbums(src: ExploreAlbum[]): ExploreAlbum[] {
    const out: ExploreAlbum[] = []
    for (const a of src) {
      out.push(a)
    }
    return out
  }
}
