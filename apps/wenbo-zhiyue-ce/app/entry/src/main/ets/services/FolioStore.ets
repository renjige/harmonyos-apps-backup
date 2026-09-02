import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { ExcerptItem, EnsureFolioResult, FolioOverview, KnowledgeFolio, ReadingDoc, RhythmPersistResult } from '../models/FolioModels'
import { DiagnoseReport } from '../models/DiagnoseModels'
import { DiagnoseService } from './DiagnoseService'

const STORE = 'zhiyue_ce_v1'
const KEY_DOCS = 'reading_docs'
const KEY_EXCERPTS = 'excerpts'
const KEY_FOLIOS = 'folios'
const KEY_DARK = 'dark_mode'

export class FolioStore {
  private static pref: preferences.Preferences | null = null
  private static filesDir: string = ''
  private static epoch: number = 1

  static async init(context: common.UIAbilityContext): Promise<void> {
    FolioStore.filesDir = context.filesDir
    try {
      FolioStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      FolioStore.pref = null
    }
  }

  static importsDir(): string {
    if (FolioStore.filesDir.length === 0) {
      return ''
    }
    return `${FolioStore.filesDir}/imports`
  }

  static bumpEpoch(): void {
    FolioStore.epoch++
    AppStorage.setOrCreate('folioEpoch', FolioStore.epoch)
  }

  static async ensureNamedFolio(title: string): Promise<EnsureFolioResult> {
    const out = new EnsureFolioResult()
    const list = await FolioStore.loadFolios()
    for (const it of list) {
      if (it.title === title) {
        out.folio = it
        out.created = false
        return out
      }
    }
    let cover = 'cover_folio_study'
    if (title.indexOf('职场') >= 0) {
      cover = 'cover_folio_work'
    } else if (title.indexOf('生活') >= 0) {
      cover = 'cover_folio_life'
    }
    const created = KnowledgeFolio.create(title, '由阅读节律自检创建，用于归类摘录与主题整理', cover)
    await FolioStore.saveFolio(created)
    out.folio = created
    out.created = true
    return out
  }

  static async saveRhythmFromReport(report: DiagnoseReport): Promise<RhythmPersistResult> {
    const ensured = await FolioStore.ensureNamedFolio(report.matchCategory)
    const doc = ReadingDoc.create(
      `${report.title} · ${report.generatedAt}`,
      'paste',
      DiagnoseService.planDocBody(report)
    )
    doc.folioId = ensured.folio.id
    await FolioStore.saveDoc(doc)
    const excerpt = ExcerptItem.create(doc.id, DiagnoseService.excerptQuote(report), DiagnoseService.excerptReflection(report))
    excerpt.folioId = ensured.folio.id
    excerpt.isFavorite = true
    const tags: string[] = []
    tags.push('阅读节律')
    tags.push(FolioStore.coverTag(ensured.folio.coverKey))
    excerpt.tags = tags
    await FolioStore.saveExcerpt(excerpt)
    const out = new RhythmPersistResult()
    out.folio = ensured.folio
    out.doc = doc
    out.excerpt = excerpt
    return out
  }

  private static coverTag(coverKey: string): string {
    if (coverKey === 'cover_folio_work') {
      return '职场'
    }
    if (coverKey === 'cover_folio_life') {
      return '生活'
    }
    return '学习'
  }

  static async loadDocs(): Promise<ReadingDoc[]> {
    return FolioStore.parseDocs(await FolioStore.getString(KEY_DOCS, ''))
  }

  static async loadExcerpts(): Promise<ExcerptItem[]> {
    return FolioStore.parseExcerpts(await FolioStore.getString(KEY_EXCERPTS, ''))
  }

  static async loadFolios(): Promise<KnowledgeFolio[]> {
    return FolioStore.parseFolios(await FolioStore.getString(KEY_FOLIOS, ''))
  }

  static async findDoc(id: string): Promise<ReadingDoc | undefined> {
    const list = await FolioStore.loadDocs()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async findExcerpt(id: string): Promise<ExcerptItem | undefined> {
    const list = await FolioStore.loadExcerpts()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async findFolio(id: string): Promise<KnowledgeFolio | undefined> {
    const list = await FolioStore.loadFolios()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async saveDoc(doc: ReadingDoc): Promise<void> {
    doc.updatedAt = Date.now()
    doc.wordCount = doc.body.length
    const list = await FolioStore.loadDocs()
    const next: ReadingDoc[] = []
    let found = false
    for (const it of list) {
      if (it.id === doc.id) {
        next.push(doc)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(doc)
    }
    next.sort((a: ReadingDoc, b: ReadingDoc) => b.updatedAt - a.updatedAt)
    await FolioStore.persistDocs(next)
  }

  static async saveExcerpt(item: ExcerptItem): Promise<void> {
    item.updatedAt = Date.now()
    const list = await FolioStore.loadExcerpts()
    const next: ExcerptItem[] = []
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
    next.sort((a: ExcerptItem, b: ExcerptItem) => b.createdAt - a.createdAt)
    await FolioStore.persistExcerpts(next)
  }

  static async saveFolio(item: KnowledgeFolio): Promise<void> {
    item.updatedAt = Date.now()
    const list = await FolioStore.loadFolios()
    const next: KnowledgeFolio[] = []
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
    next.sort((a: KnowledgeFolio, b: KnowledgeFolio) => b.createdAt - a.createdAt)
    await FolioStore.persistFolios(next)
  }

  static async deleteDoc(id: string): Promise<void> {
    const docs = await FolioStore.loadDocs()
    const nextDocs: ReadingDoc[] = []
    for (const it of docs) {
      if (it.id !== id) {
        nextDocs.push(it)
      }
    }
    await FolioStore.persistDocs(nextDocs)
    const excerpts = await FolioStore.loadExcerpts()
    const nextEx: ExcerptItem[] = []
    for (const it of excerpts) {
      if (it.docId !== id) {
        nextEx.push(it)
      }
    }
    await FolioStore.persistExcerpts(nextEx)
  }

  static async deleteExcerpt(id: string): Promise<void> {
    const list = await FolioStore.loadExcerpts()
    const next: ExcerptItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await FolioStore.persistExcerpts(next)
  }

  static async deleteFolio(id: string): Promise<void> {
    const list = await FolioStore.loadFolios()
    const next: KnowledgeFolio[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await FolioStore.persistFolios(next)
    const excerpts = await FolioStore.loadExcerpts()
    for (const it of excerpts) {
      if (it.folioId === id) {
        it.folioId = ''
        await FolioStore.saveExcerpt(it)
      }
    }
  }

  static async excerptsOfDoc(docId: string): Promise<ExcerptItem[]> {
    const list = await FolioStore.loadExcerpts()
    const out: ExcerptItem[] = []
    for (const it of list) {
      if (it.docId === docId) {
        out.push(it)
      }
    }
    return out
  }

  static async excerptsOfFolio(folioId: string): Promise<ExcerptItem[]> {
    const list = await FolioStore.loadExcerpts()
    const out: ExcerptItem[] = []
    for (const it of list) {
      if (it.folioId === folioId) {
        out.push(it)
      }
    }
    return out
  }

  static async searchExcerpts(query: string): Promise<ExcerptItem[]> {
    const q = query.trim().toLowerCase()
    const list = await FolioStore.loadExcerpts()
    if (q.length === 0) {
      return list
    }
    const out: ExcerptItem[] = []
    for (const it of list) {
      const blob = `${it.text} ${it.reflection} ${it.tagLine()}`.toLowerCase()
      if (blob.indexOf(q) >= 0) {
        out.push(it)
      }
    }
    return out
  }

  static async searchFolios(query: string): Promise<KnowledgeFolio[]> {
    const q = query.trim().toLowerCase()
    const list = await FolioStore.loadFolios()
    if (q.length === 0) {
      return list
    }
    const out: KnowledgeFolio[] = []
    for (const it of list) {
      if (`${it.title} ${it.summary}`.toLowerCase().indexOf(q) >= 0) {
        out.push(it)
      }
    }
    return out
  }

  static async latestDoc(): Promise<ReadingDoc | undefined> {
    const list = await FolioStore.loadDocs()
    if (list.length === 0) {
      return undefined
    }
    let best = list[0]
    for (const it of list) {
      if (it.lastReadAt > best.lastReadAt) {
        best = it
      }
    }
    if (best.lastReadAt === 0) {
      return list[0]
    }
    return best
  }

  static async overview(): Promise<FolioOverview> {
    const docs = await FolioStore.loadDocs()
    const excerpts = await FolioStore.loadExcerpts()
    const folios = await FolioStore.loadFolios()
    const ov = new FolioOverview()
    ov.docCount = docs.length
    ov.excerptCount = excerpts.length
    ov.folioCount = folios.length
    for (const d of docs) {
      ov.readMinutes = ov.readMinutes + d.readMinutes
    }
    for (const e of excerpts) {
      if (e.isFavorite) {
        ov.favoriteCount++
      }
    }
    return ov
  }

  static async todayCard(): Promise<ExcerptItem | undefined> {
    const list = await FolioStore.loadExcerpts()
    const pool: ExcerptItem[] = []
    for (const it of list) {
      if (it.isFavorite) {
        pool.push(it)
      }
    }
    const use = pool.length > 0 ? pool : list
    if (use.length === 0) {
      return undefined
    }
    const d = new Date()
    let acc = d.getFullYear() * 10000 + (d.getMonth() + 1) * 100 + d.getDate()
    for (const it of use) {
      acc = acc + it.id.length
    }
    const idx = acc % use.length
    let k = 0
    for (const it of use) {
      if (k === idx) {
        return it
      }
      k++
    }
    return undefined
  }

  static async randomExcerpt(): Promise<ExcerptItem | undefined> {
    const list = await FolioStore.loadExcerpts()
    if (list.length === 0) {
      return undefined
    }
    const idx = Math.floor(Math.random() * list.length)
    let k = 0
    for (const it of list) {
      if (k === idx) {
        return it
      }
      k++
    }
    return list[0]
  }

  static async toggleFavorite(id: string): Promise<boolean> {
    const found = await FolioStore.findExcerpt(id)
    if (found === undefined) {
      return false
    }
    found.isFavorite = !found.isFavorite
    await FolioStore.saveExcerpt(found)
    return found.isFavorite
  }

  static async loadDark(): Promise<boolean> {
    return (await FolioStore.getString(KEY_DARK, '0')) === '1'
  }

  static async saveDark(on: boolean): Promise<void> {
    await FolioStore.putString(KEY_DARK, on ? '1' : '0')
  }

  static timeLabel(ts: number): string {
    if (ts <= 0) {
      return '尚未阅读'
    }
    const d = new Date(ts)
    const m = d.getMonth() + 1
    const day = d.getDate()
    return `${d.getFullYear()}-${FolioStore.pad(m)}-${FolioStore.pad(day)}`
  }

  static async exportCsv(): Promise<string> {
    const list = await FolioStore.loadExcerpts()
    const docs = await FolioStore.loadDocs()
    const lines: string[] = []
    lines.push('文稿,摘录,感想,标签,收藏,日期')
    for (const it of list) {
      let title = it.docId
      for (const d of docs) {
        if (d.id === it.docId) {
          title = d.title
        }
      }
      const row: string[] = []
      row.push(FolioStore.csvCell(title))
      row.push(FolioStore.csvCell(it.text))
      row.push(FolioStore.csvCell(it.reflection))
      row.push(FolioStore.csvCell(it.tagLine()))
      row.push(it.isFavorite ? '是' : '否')
      row.push(FolioStore.timeLabel(it.createdAt))
      lines.push(row.join(','))
    }
    return lines.join('\n')
  }

  private static csvCell(raw: string): string {
    const t = raw.replace(/"/g, '""').replace(/\n/g, ' ')
    return `"${t}"`
  }

  private static pad(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  private static flag(v: boolean): string {
    return v ? '1' : '0'
  }

  private static isOne(s: string): boolean {
    return s === '1'
  }

  private static num(s: string): number {
    if (s.length === 0) {
      return 0
    }
    const n = Number.parseInt(s, 10)
    if (n !== n) {
      return 0
    }
    return n
  }

  private static float(s: string): number {
    if (s.length === 0) {
      return 0
    }
    const n = Number.parseFloat(s)
    if (n !== n) {
      return 0
    }
    return n
  }

  private static esc(s: string): string {
    return s.replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/\t/g, '\\t')
  }

  private static unesc(s: string): string {
    return s.replace(/\\n/g, '\n').replace(/\\t/g, '\t').replace(/\\\\/g, '\\')
  }

  private static async persistDocs(items: ReadingDoc[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push([
        it.id, FolioStore.esc(it.title), it.format, FolioStore.esc(it.body),
        `${it.progress}`, `${it.lastReadAt}`, it.folioId, `${it.wordCount}`,
        `${it.readMinutes}`, `${it.createdAt}`, `${it.updatedAt}`, FolioStore.esc(it.filePath)
      ].join('\t'))
    }
    await FolioStore.putString(KEY_DOCS, lines.join('\n'))
    FolioStore.bumpEpoch()
  }

  private static async persistExcerpts(items: ExcerptItem[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push([
        it.id, it.docId, it.folioId, FolioStore.esc(it.text), FolioStore.esc(it.reflection),
        it.tags.join(','), FolioStore.flag(it.isFavorite), `${it.createdAt}`, `${it.updatedAt}`
      ].join('\t'))
    }
    await FolioStore.putString(KEY_EXCERPTS, lines.join('\n'))
    FolioStore.bumpEpoch()
  }

  private static async persistFolios(items: KnowledgeFolio[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push([
        it.id, FolioStore.esc(it.title), FolioStore.esc(it.summary), it.coverKey,
        `${it.createdAt}`, `${it.updatedAt}`
      ].join('\t'))
    }
    await FolioStore.putString(KEY_FOLIOS, lines.join('\n'))
    FolioStore.bumpEpoch()
  }

  private static parseDocs(raw: string): ReadingDoc[] {
    const out: ReadingDoc[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 10) {
        continue
      }
      const d = new ReadingDoc()
      d.id = p[0]
      d.title = FolioStore.unesc(p[1])
      d.format = p[2]
      d.body = FolioStore.unesc(p[3])
      d.progress = FolioStore.float(p[4])
      d.lastReadAt = FolioStore.num(p[5])
      d.folioId = p[6]
      d.wordCount = FolioStore.num(p[7])
      d.readMinutes = FolioStore.num(p[8])
      d.createdAt = FolioStore.num(p[9])
      if (p.length >= 11) {
        d.updatedAt = FolioStore.num(p[10])
      }
      if (p.length >= 12) {
        d.filePath = FolioStore.unesc(p[11])
      }
      out.push(d)
    }
    out.sort((a: ReadingDoc, b: ReadingDoc) => b.updatedAt - a.updatedAt)
    return out
  }

  private static parseExcerpts(raw: string): ExcerptItem[] {
    const out: ExcerptItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 8) {
        continue
      }
      const e = new ExcerptItem()
      e.id = p[0]
      e.docId = p[1]
      e.folioId = p[2]
      e.text = FolioStore.unesc(p[3])
      e.reflection = FolioStore.unesc(p[4])
      e.tags = p[5].length === 0 ? [] : p[5].split(',')
      e.isFavorite = FolioStore.isOne(p[6])
      e.createdAt = FolioStore.num(p[7])
      if (p.length >= 9) {
        e.updatedAt = FolioStore.num(p[8])
      }
      out.push(e)
    }
    out.sort((a: ExcerptItem, b: ExcerptItem) => b.createdAt - a.createdAt)
    return out
  }

  private static parseFolios(raw: string): KnowledgeFolio[] {
    const out: KnowledgeFolio[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 5) {
        continue
      }
      const f = new KnowledgeFolio()
      f.id = p[0]
      f.title = FolioStore.unesc(p[1])
      f.summary = FolioStore.unesc(p[2])
      f.coverKey = p[3]
      f.createdAt = FolioStore.num(p[4])
      if (p.length >= 6) {
        f.updatedAt = FolioStore.num(p[5])
      }
      out.push(f)
    }
    out.sort((a: KnowledgeFolio, b: KnowledgeFolio) => b.createdAt - a.createdAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (FolioStore.pref === null) {
      return fallback
    }
    try {
      const v = await FolioStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (FolioStore.pref === null) {
      return
    }
    try {
      await FolioStore.pref.put(key, value)
      await FolioStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
