import { HttpClient } from './HttpClient'
import {
  BadgeListData,
  KpiItem,
  KpiListData,
  MapListData,
  MsgItem,
  MsgListData,
  OptionItem,
  QuestBadge,
  QuestMap,
  QuestQuestion,
  QuestTreasure,
  QuestionListData,
  TreasureListData
} from '../models/QuestModels'

const BASE = '/biz/knowledge-quest'

export class QuestBizService {
  private static memMaps: QuestMap[] = []
  private static memQuestions: QuestQuestion[] = []
  private static memTreasures: QuestTreasure[] = []
  static lastHint: string = ''

  static async loadRecommended(): Promise<QuestMap[]> {
    return QuestBizService.fetchMaps(`${BASE}/maps?recommend=1`)
  }

  static async loadHot(): Promise<QuestMap[]> {
    const list = await QuestBizService.fetchMaps(`${BASE}/maps`)
    return QuestBizService.sortByHeat(list)
  }

  static async loadMapsByCategory(category: string): Promise<QuestMap[]> {
    const path = category.length > 0 && category !== 'all' ?
      `${BASE}/maps?category=${category}` : `${BASE}/maps`
    return QuestBizService.fetchMaps(path)
  }

  static async loadMap(id: string): Promise<QuestMap | undefined> {
    const found = QuestBizService.findMap(QuestBizService.memMaps, id)
    if (found !== undefined) {
      return found
    }
    const res = await HttpClient.get<QuestMap>(`${BASE}/maps/${id}`)
    if (res.code === 0 && res.data !== undefined && res.data.id.length > 0) {
      const item = QuestBizService.mapMap(res.data)
      QuestBizService.rememberMap(item)
      return item
    }
    QuestBizService.lastHint = '暂时无法加载地图详情'
    return undefined
  }

  static async loadQuestions(mapId: string): Promise<QuestQuestion[]> {
    const res = await HttpClient.get<QuestionListData>(`${BASE}/questions?mapId=${mapId}`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      const list = QuestBizService.mapQuestions(res.data.list)
      QuestBizService.memQuestions = list
      return list
    }
    QuestBizService.lastHint = '暂时无法加载题目'
    return []
  }

  static async loadTreasures(): Promise<QuestTreasure[]> {
    const res = await HttpClient.get<TreasureListData>(`${BASE}/treasures`)
    if (res.code === 0 && res.data !== undefined) {
      const list = QuestBizService.mapTreasures(res.data.list)
      QuestBizService.memTreasures = list
      return list
    }
    return []
  }

  static async loadTreasure(id: string): Promise<QuestTreasure | undefined> {
    const list = QuestBizService.memTreasures.length > 0 ?
      QuestBizService.memTreasures : await QuestBizService.loadTreasures()
    const found = QuestBizService.findTreasure(list, id)
    if (found !== undefined) {
      return found
    }
    const res = await HttpClient.get<QuestTreasure>(`${BASE}/treasures/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return QuestBizService.mapTreasure(res.data)
    }
    return undefined
  }

  static treasureForMap(mapId: string): QuestTreasure | undefined {
    for (const t of QuestBizService.memTreasures) {
      if (t.mapId === mapId) {
        return t
      }
    }
    return undefined
  }

  static async loadBadges(): Promise<QuestBadge[]> {
    const res = await HttpClient.get<BadgeListData>(`${BASE}/badges`)
    if (res.code === 0 && res.data !== undefined) {
      return QuestBizService.mapBadges(res.data.list)
    }
    return []
  }

  static async loadBadge(id: string): Promise<QuestBadge | undefined> {
    const list = await QuestBizService.loadBadges()
    for (const b of list) {
      if (b.id === id) {
        return b
      }
    }
    return undefined
  }

  static async loadKpis(): Promise<KpiItem[]> {
    const res = await HttpClient.get<KpiListData>(`${BASE}/kpis`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadMessages(): Promise<MsgItem[]> {
    const res = await HttpClient.get<MsgListData>(`${BASE}/messages`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    const res2 = await HttpClient.get<MsgListData>('/messages')
    if (res2.code === 0 && res2.data !== undefined) {
      return res2.data.list
    }
    return []
  }

  static findMap(list: QuestMap[], id: string): QuestMap | undefined {
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static findTreasure(list: QuestTreasure[], id: string): QuestTreasure | undefined {
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static difficultyStars(map: QuestMap): string {
    const d = map.difficulty > 0 ? map.difficulty : 1
    let stars = ''
    for (let i = 0; i < d && i < 3; i++) {
      stars = `${stars}★`
    }
    return stars.length > 0 ? stars : '★'
  }

  static optionsOf(q: QuestQuestion): OptionItem[] {
    const out: OptionItem[] = []
    const texts: string[] = [q.optionA, q.optionB, q.optionC, q.optionD]
    for (let i = 0; i < texts.length; i++) {
      if (texts[i].length > 0) {
        const o = new OptionItem()
        o.index = i
        o.text = texts[i]
        out.push(o)
      }
    }
    return out
  }

  private static async fetchMaps(path: string): Promise<QuestMap[]> {
    const res = await HttpClient.get<MapListData>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      const list = QuestBizService.mapMaps(res.data.list)
      for (const m of list) {
        QuestBizService.rememberMap(m)
      }
      QuestBizService.lastHint = ''
      return list
    }
    QuestBizService.lastHint = '知识地图暂时无法加载，请稍后重试'
    return []
  }

  private static sortByHeat(list: QuestMap[]): QuestMap[] {
    const copy: QuestMap[] = []
    for (const m of list) {
      copy.push(m)
    }
    copy.sort((a: QuestMap, b: QuestMap) => b.heat - a.heat)
    return copy
  }

  private static mapMap(raw: QuestMap): QuestMap {
    const m = new QuestMap()
    m.id = raw.id ?? ''
    m.title = raw.title ?? ''
    m.subtitle = raw.subtitle ?? ''
    m.summary = raw.summary ?? ''
    m.body = raw.body ?? ''
    m.description = raw.description ?? ''
    m.coverMedia = raw.coverMedia ?? ''
    if (raw.coverKey !== undefined && raw.coverKey.length > 0) {
      m.coverKey = raw.coverKey
    } else if (m.coverMedia.length > 0) {
      m.coverKey = m.coverMedia
    } else {
      m.coverKey = 'hero_discover'
    }
    m.category = raw.category ?? ''
    m.categoryLabel = raw.categoryLabel ?? ''
    m.difficulty = raw.difficulty > 0 ? raw.difficulty : 1
    m.totalQuestions = raw.totalQuestions > 0 ? raw.totalQuestions : 6
    m.estimatedMinutes = raw.estimatedMinutes > 0 ? raw.estimatedMinutes : 8
    m.heat = raw.heat ?? 0
    m.recommend = raw.recommend === true
    m.wisdomReward = raw.wisdomReward > 0 ? raw.wisdomReward : 40
    m.retryLimit = raw.retryLimit > 0 ? raw.retryLimit : 3
    return m
  }

  private static mapMaps(list: QuestMap[]): QuestMap[] {
    const out: QuestMap[] = []
    for (const raw of list) {
      out.push(QuestBizService.mapMap(raw))
    }
    return out
  }

  private static mapQuestion(raw: QuestQuestion): QuestQuestion {
    const q = new QuestQuestion()
    q.id = raw.id ?? ''
    q.mapId = raw.mapId ?? ''
    q.title = raw.title ?? ''
    q.qType = raw.qType ?? 'choice'
    q.optionA = raw.optionA ?? ''
    q.optionB = raw.optionB ?? ''
    q.optionC = raw.optionC ?? ''
    q.optionD = raw.optionD ?? ''
    q.answerIndex = raw.answerIndex ?? 0
    q.explanation = raw.explanation ?? ''
    q.coverKey = raw.coverKey ?? ''
    q.sortOrder = raw.sortOrder ?? 0
    return q
  }

  private static mapQuestions(list: QuestQuestion[]): QuestQuestion[] {
    const out: QuestQuestion[] = []
    for (const raw of list) {
      out.push(QuestBizService.mapQuestion(raw))
    }
    return out
  }

  private static mapTreasure(raw: QuestTreasure): QuestTreasure {
    const t = new QuestTreasure()
    t.id = raw.id ?? ''
    t.mapId = raw.mapId ?? ''
    t.title = raw.title ?? ''
    t.subtitle = raw.subtitle ?? ''
    t.summary = raw.summary ?? ''
    t.body = raw.body ?? ''
    t.description = raw.description ?? ''
    t.coverMedia = raw.coverMedia ?? ''
    if (raw.coverKey !== undefined && raw.coverKey.length > 0) {
      t.coverKey = raw.coverKey
    } else if (t.coverMedia.length > 0) {
      t.coverKey = t.coverMedia
    } else {
      t.coverKey = 'hero_discover'
    }
    t.categoryLabel = raw.categoryLabel ?? ''
    t.wisdomReward = raw.wisdomReward > 0 ? raw.wisdomReward : 40
    return t
  }

  private static mapTreasures(list: QuestTreasure[]): QuestTreasure[] {
    const out: QuestTreasure[] = []
    for (const raw of list) {
      out.push(QuestBizService.mapTreasure(raw))
    }
    return out
  }

  private static mapBadge(raw: QuestBadge): QuestBadge {
    const b = new QuestBadge()
    b.id = raw.id ?? ''
    b.title = raw.title ?? ''
    b.summary = raw.summary ?? ''
    b.body = raw.body ?? ''
    b.description = raw.description ?? ''
    b.coverMedia = raw.coverMedia ?? ''
    if (raw.coverKey !== undefined && raw.coverKey.length > 0) {
      b.coverKey = raw.coverKey
    } else if (b.coverMedia.length > 0) {
      b.coverKey = b.coverMedia
    } else {
      b.coverKey = 'badge_first'
    }
    return b
  }

  private static mapBadges(list: QuestBadge[]): QuestBadge[] {
    const out: QuestBadge[] = []
    for (const raw of list) {
      out.push(QuestBizService.mapBadge(raw))
    }
    return out
  }

  private static rememberMap(item: QuestMap): void {
    let found = false
    for (let i = 0; i < QuestBizService.memMaps.length; i++) {
      if (QuestBizService.memMaps[i].id === item.id) {
        QuestBizService.memMaps[i] = item
        found = true
        break
      }
    }
    if (!found) {
      QuestBizService.memMaps.push(item)
    }
  }
}
