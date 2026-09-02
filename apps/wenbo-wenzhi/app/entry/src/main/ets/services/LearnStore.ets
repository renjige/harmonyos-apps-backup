import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { InsightItem } from '../models/AskModels'
import { AskHistoryItem, KnowledgeCardItem, QuizWrongItem } from '../models/LearnModels'

const STORE_NAME = 'wenzhi_learn'
const KEY_HISTORY = 'history_json'
const KEY_WRONG = 'wrong_json'
const KEY_CARDS = 'cards_json'
const KEY_QUIZ = 'quiz_count'
const KEY_QUIZ_OK = 'quiz_correct'
const KEY_GOAL = 'daily_goal'
const KEY_TODAY_N = 'today_learn'
const KEY_TODAY_D = 'today_learn_day'
const KEY_READ = 'read_count'

export class LearnStore {
  private static pref: preferences.Preferences | null = null
  private static history: AskHistoryItem[] = []
  private static wrongs: QuizWrongItem[] = []
  private static cards: KnowledgeCardItem[] = []
  private static quizCount: number = 0
  private static quizCorrect: number = 0
  private static dailyGoal: number = 3
  private static todayLearn: number = 0
  private static todayDay: string = ''
  private static readCount: number = 0

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      LearnStore.pref = await preferences.getPreferences(context, STORE_NAME)
      LearnStore.history = LearnStore.parseHistory(await LearnStore.str(KEY_HISTORY, '[]'))
      LearnStore.wrongs = LearnStore.parseWrong(await LearnStore.str(KEY_WRONG, '[]'))
      LearnStore.cards = LearnStore.parseCards(await LearnStore.str(KEY_CARDS, '[]'))
      LearnStore.quizCount = await LearnStore.num(KEY_QUIZ, 0)
      LearnStore.quizCorrect = await LearnStore.num(KEY_QUIZ_OK, 0)
      LearnStore.dailyGoal = await LearnStore.num(KEY_GOAL, 3)
      LearnStore.todayLearn = await LearnStore.num(KEY_TODAY_N, 0)
      LearnStore.todayDay = await LearnStore.str(KEY_TODAY_D, '')
      LearnStore.readCount = await LearnStore.num(KEY_READ, 0)
      LearnStore.rollToday()
    } catch {
      LearnStore.history = []
    }
  }

  static historyAll(): AskHistoryItem[] {
    return LearnStore.copyHistory()
  }

  static wrongAll(): QuizWrongItem[] {
    return LearnStore.copyWrong()
  }

  static cardAll(): KnowledgeCardItem[] {
    return LearnStore.copyCards()
  }

  static quizTimes(): number {
    return LearnStore.quizCount
  }

  static quizHits(): number {
    return LearnStore.quizCorrect
  }

  static goal(): number {
    return LearnStore.dailyGoal
  }

  static todayCount(): number {
    LearnStore.rollToday()
    return LearnStore.todayLearn
  }

  static reads(): number {
    return LearnStore.readCount
  }

  static async setGoal(n: number): Promise<void> {
    LearnStore.dailyGoal = n
    await LearnStore.flush()
  }

  static async addHistory(question: string, insight: InsightItem): Promise<void> {
    const row = new AskHistoryItem()
    row.id = `hs_${Date.now()}`
    row.question = question
    row.insightId = insight.id
    row.title = insight.title
    row.category = insight.category
    row.createdAt = Date.now()
    LearnStore.history.unshift(row)
    if (LearnStore.history.length > 80) {
      LearnStore.history = LearnStore.history.slice(0, 80)
    }
    await LearnStore.bumpLearn()
    await LearnStore.flush()
  }

  static async addWrong(insight: InsightItem, picked: string, correct: string): Promise<void> {
    const row = new QuizWrongItem()
    row.id = `wr_${Date.now()}`
    row.insightId = insight.id
    row.title = insight.title
    row.picked = picked
    row.correct = correct
    row.createdAt = Date.now()
    LearnStore.wrongs.unshift(row)
    if (LearnStore.wrongs.length > 50) {
      LearnStore.wrongs = LearnStore.wrongs.slice(0, 50)
    }
    await LearnStore.flush()
  }

  static async removeWrong(id: string): Promise<void> {
    const next: QuizWrongItem[] = []
    for (const n of LearnStore.wrongs) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    LearnStore.wrongs = next
    await LearnStore.flush()
  }

  static async recordQuiz(correct: boolean): Promise<void> {
    LearnStore.quizCount += 1
    if (correct) {
      LearnStore.quizCorrect += 1
    }
    await LearnStore.bumpLearn()
    await LearnStore.flush()
  }

  static async markRead(): Promise<void> {
    LearnStore.readCount += 1
    await LearnStore.bumpLearn()
    await LearnStore.flush()
  }

  static async addTodayProgress(): Promise<void> {
    await LearnStore.bumpLearn()
    await LearnStore.flush()
  }

  static async saveCard(insight: InsightItem): Promise<KnowledgeCardItem> {
    const row = new KnowledgeCardItem()
    row.id = `cd_${Date.now()}`
    row.insightId = insight.id
    row.title = insight.title
    row.summary = insight.summary
    row.body = insight.body
    row.category = insight.category
    row.createdAt = Date.now()
    LearnStore.cards.unshift(row)
    if (LearnStore.cards.length > 40) {
      LearnStore.cards = LearnStore.cards.slice(0, 40)
    }
    await LearnStore.flush()
    return row
  }

  static async removeCard(id: string): Promise<void> {
    const next: KnowledgeCardItem[] = []
    for (const n of LearnStore.cards) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    LearnStore.cards = next
    await LearnStore.flush()
  }

  static cardText(title: string, summary: string, body: string, category: string): string {
    return `【问知】${category}\n${title}\n\n${summary}\n\n${body}\n\n——来自问知，仅供学习参考`
  }

  private static async bumpLearn(): Promise<void> {
    LearnStore.rollToday()
    LearnStore.todayLearn += 1
  }

  private static rollToday(): void {
    const d = new Date()
    const key = `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
    if (LearnStore.todayDay !== key) {
      LearnStore.todayDay = key
      LearnStore.todayLearn = 0
    }
  }

  private static async str(key: string, fallback: string): Promise<string> {
    if (!LearnStore.pref) {
      return fallback
    }
    try {
      const raw = await LearnStore.pref.get(key, fallback)
      return typeof raw === 'string' ? raw : fallback
    } catch {
      return fallback
    }
  }

  private static async num(key: string, fallback: number): Promise<number> {
    if (!LearnStore.pref) {
      return fallback
    }
    try {
      const raw = await LearnStore.pref.get(key, fallback)
      return typeof raw === 'number' ? raw : fallback
    } catch {
      return fallback
    }
  }

  private static async flush(): Promise<void> {
    if (!LearnStore.pref) {
      return
    }
    try {
      await LearnStore.pref.put(KEY_HISTORY, LearnStore.encodeHistory())
      await LearnStore.pref.put(KEY_WRONG, LearnStore.encodeWrong())
      await LearnStore.pref.put(KEY_CARDS, LearnStore.encodeCards())
      await LearnStore.pref.put(KEY_QUIZ, LearnStore.quizCount)
      await LearnStore.pref.put(KEY_QUIZ_OK, LearnStore.quizCorrect)
      await LearnStore.pref.put(KEY_GOAL, LearnStore.dailyGoal)
      await LearnStore.pref.put(KEY_TODAY_N, LearnStore.todayLearn)
      await LearnStore.pref.put(KEY_TODAY_D, LearnStore.todayDay)
      await LearnStore.pref.put(KEY_READ, LearnStore.readCount)
      await LearnStore.pref.flush()
    } catch {
    }
  }

  private static encodeHistory(): string {
    let json = '['
    for (let i = 0; i < LearnStore.history.length; i++) {
      const n = LearnStore.history[i]
      if (i > 0) {
        json += ','
      }
      json += `{"id":${JSON.stringify(n.id)},"question":${JSON.stringify(n.question)},` +
        `"insightId":${JSON.stringify(n.insightId)},"title":${JSON.stringify(n.title)},` +
        `"category":${JSON.stringify(n.category)},"createdAt":${n.createdAt}}`
    }
    json += ']'
    return json
  }

  private static encodeWrong(): string {
    let json = '['
    for (let i = 0; i < LearnStore.wrongs.length; i++) {
      const n = LearnStore.wrongs[i]
      if (i > 0) {
        json += ','
      }
      json += `{"id":${JSON.stringify(n.id)},"insightId":${JSON.stringify(n.insightId)},` +
        `"title":${JSON.stringify(n.title)},"picked":${JSON.stringify(n.picked)},` +
        `"correct":${JSON.stringify(n.correct)},"createdAt":${n.createdAt}}`
    }
    json += ']'
    return json
  }

  private static encodeCards(): string {
    let json = '['
    for (let i = 0; i < LearnStore.cards.length; i++) {
      const n = LearnStore.cards[i]
      if (i > 0) {
        json += ','
      }
      json += `{"id":${JSON.stringify(n.id)},"insightId":${JSON.stringify(n.insightId)},` +
        `"title":${JSON.stringify(n.title)},"summary":${JSON.stringify(n.summary)},` +
        `"body":${JSON.stringify(n.body)},"category":${JSON.stringify(n.category)},` +
        `"createdAt":${n.createdAt}}`
    }
    json += ']'
    return json
  }

  private static parseHistory(raw: string): AskHistoryItem[] {
    const out: AskHistoryItem[] = []
    try {
      const arr = JSON.parse(raw) as AskHistoryItem[]
      if (arr) {
        for (const n of arr) {
          const row = new AskHistoryItem()
          row.id = n.id
          row.question = n.question
          row.insightId = n.insightId
          row.title = n.title
          row.category = n.category
          row.createdAt = n.createdAt
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  private static parseWrong(raw: string): QuizWrongItem[] {
    const out: QuizWrongItem[] = []
    try {
      const arr = JSON.parse(raw) as QuizWrongItem[]
      if (arr) {
        for (const n of arr) {
          const row = new QuizWrongItem()
          row.id = n.id
          row.insightId = n.insightId
          row.title = n.title
          row.picked = n.picked
          row.correct = n.correct
          row.createdAt = n.createdAt
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  private static parseCards(raw: string): KnowledgeCardItem[] {
    const out: KnowledgeCardItem[] = []
    try {
      const arr = JSON.parse(raw) as KnowledgeCardItem[]
      if (arr) {
        for (const n of arr) {
          const row = new KnowledgeCardItem()
          row.id = n.id
          row.insightId = n.insightId
          row.title = n.title
          row.summary = n.summary
          row.body = n.body
          row.category = n.category
          row.createdAt = n.createdAt
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  private static copyHistory(): AskHistoryItem[] {
    const out: AskHistoryItem[] = []
    for (const n of LearnStore.history) {
      out.push(n)
    }
    return out
  }

  private static copyWrong(): QuizWrongItem[] {
    const out: QuizWrongItem[] = []
    for (const n of LearnStore.wrongs) {
      out.push(n)
    }
    return out
  }

  private static copyCards(): KnowledgeCardItem[] {
    const out: KnowledgeCardItem[] = []
    for (const n of LearnStore.cards) {
      out.push(n)
    }
    return out
  }
}
