import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { CheckState, KnowledgeCard, MoveItem, StageGoal, TrainPlan } from '../models/TrainingModels'

const STORE_NAME = 'training_practice_hub_v1'

export class PracticeHubStore {
  private static pref: preferences.Preferences | null = null
  private static plans: TrainPlan[] = []
  private static moves: MoveItem[] = []
  private static goals: StageGoal[] = []
  private static cards: KnowledgeCard[] = []
  private static checks: CheckState = new CheckState()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      PracticeHubStore.pref = await preferences.getPreferences(context, STORE_NAME)
      PracticeHubStore.plans = PracticeHubStore.parsePlans(await PracticeHubStore.readKey('plans_json', '[]'))
      PracticeHubStore.moves = PracticeHubStore.parseMoves(await PracticeHubStore.readKey('moves_json', '[]'))
      PracticeHubStore.goals = PracticeHubStore.parseGoals(await PracticeHubStore.readKey('goals_json', '[]'))
      PracticeHubStore.cards = PracticeHubStore.parseCards(await PracticeHubStore.readKey('cards_json', '[]'))
      PracticeHubStore.checks = PracticeHubStore.parseChecks(await PracticeHubStore.readKey('checks_json', '{}'))
    } catch {
      PracticeHubStore.plans = []
      PracticeHubStore.moves = []
      PracticeHubStore.goals = []
      PracticeHubStore.cards = []
      PracticeHubStore.checks = new CheckState()
    }
  }

  static listPlans(): TrainPlan[] {
    return PracticeHubStore.plans.slice()
  }

  static listMoves(): MoveItem[] {
    return PracticeHubStore.moves.slice()
  }

  static listGoals(): StageGoal[] {
    return PracticeHubStore.goals.slice()
  }

  static listCards(): KnowledgeCard[] {
    return PracticeHubStore.cards.slice()
  }

  static getChecks(): CheckState {
    const c = new CheckState()
    c.beforePacked = PracticeHubStore.checks.beforePacked
    c.afterPacked = PracticeHubStore.checks.afterPacked
    return c
  }

  static findPlan(id: string): TrainPlan | null {
    for (const p of PracticeHubStore.plans) {
      if (p.id === id) {
        return p
      }
    }
    return null
  }

  static findMove(id: string): MoveItem | null {
    for (const m of PracticeHubStore.moves) {
      if (m.id === id) {
        return m
      }
    }
    return null
  }

  static findCard(id: string): KnowledgeCard | null {
    for (const k of PracticeHubStore.cards) {
      if (k.id === id) {
        return k
      }
    }
    return null
  }

  static async savePlan(item: TrainPlan): Promise<void> {
    PracticeHubStore.plans = PracticeHubStore.upsertPlan(item)
    await PracticeHubStore.put('plans_json', JSON.stringify(PracticeHubStore.plans))
  }

  static async deletePlan(id: string): Promise<void> {
    const next: TrainPlan[] = []
    for (const p of PracticeHubStore.plans) {
      if (p.id !== id) {
        next.push(p)
      }
    }
    PracticeHubStore.plans = next
    await PracticeHubStore.put('plans_json', JSON.stringify(PracticeHubStore.plans))
  }

  static async saveMove(item: MoveItem): Promise<void> {
    PracticeHubStore.moves = PracticeHubStore.upsertMove(item)
    await PracticeHubStore.put('moves_json', JSON.stringify(PracticeHubStore.moves))
  }

  static async deleteMove(id: string): Promise<void> {
    const next: MoveItem[] = []
    for (const m of PracticeHubStore.moves) {
      if (m.id !== id) {
        next.push(m)
      }
    }
    PracticeHubStore.moves = next
    await PracticeHubStore.put('moves_json', JSON.stringify(PracticeHubStore.moves))
  }

  static async saveGoal(item: StageGoal): Promise<void> {
    PracticeHubStore.goals = PracticeHubStore.upsertGoal(item)
    await PracticeHubStore.put('goals_json', JSON.stringify(PracticeHubStore.goals))
  }

  static async deleteGoal(id: string): Promise<void> {
    const next: StageGoal[] = []
    for (const g of PracticeHubStore.goals) {
      if (g.id !== id) {
        next.push(g)
      }
    }
    PracticeHubStore.goals = next
    await PracticeHubStore.put('goals_json', JSON.stringify(PracticeHubStore.goals))
  }

  static async saveCard(item: KnowledgeCard): Promise<void> {
    PracticeHubStore.cards = PracticeHubStore.upsertCard(item)
    await PracticeHubStore.put('cards_json', JSON.stringify(PracticeHubStore.cards))
  }

  static async deleteCard(id: string): Promise<void> {
    const next: KnowledgeCard[] = []
    for (const k of PracticeHubStore.cards) {
      if (k.id !== id) {
        next.push(k)
      }
    }
    PracticeHubStore.cards = next
    await PracticeHubStore.put('cards_json', JSON.stringify(PracticeHubStore.cards))
  }

  static async saveChecks(state: CheckState): Promise<void> {
    PracticeHubStore.checks = state
    await PracticeHubStore.put('checks_json', JSON.stringify(state))
  }

  private static upsertPlan(item: TrainPlan): TrainPlan[] {
    const next: TrainPlan[] = []
    let found = false
    for (const p of PracticeHubStore.plans) {
      if (p.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(p)
      }
    }
    if (!found) {
      next.push(item)
    }
    return next
  }

  private static upsertMove(item: MoveItem): MoveItem[] {
    const next: MoveItem[] = []
    let found = false
    for (const m of PracticeHubStore.moves) {
      if (m.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(m)
      }
    }
    if (!found) {
      next.push(item)
    }
    return next
  }

  private static upsertGoal(item: StageGoal): StageGoal[] {
    const next: StageGoal[] = []
    let found = false
    for (const g of PracticeHubStore.goals) {
      if (g.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(g)
      }
    }
    if (!found) {
      next.push(item)
    }
    return next
  }

  private static upsertCard(item: KnowledgeCard): KnowledgeCard[] {
    const next: KnowledgeCard[] = []
    let found = false
    for (const k of PracticeHubStore.cards) {
      if (k.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(k)
      }
    }
    if (!found) {
      next.push(item)
    }
    return next
  }

  private static async readKey(key: string, fallback: string): Promise<string> {
    if (PracticeHubStore.pref === null) {
      return fallback
    }
    const raw = await PracticeHubStore.pref.get(key, fallback)
    return typeof raw === 'string' ? raw : fallback
  }

  private static async put(key: string, text: string): Promise<void> {
    if (PracticeHubStore.pref === null) {
      return
    }
    await PracticeHubStore.pref.put(key, text)
    await PracticeHubStore.pref.flush()
  }

  private static parsePlans(text: string): TrainPlan[] {
    try {
      const arr = JSON.parse(text) as object[]
      const out: TrainPlan[] = []
      for (const raw of arr) {
        const o = raw as Record<string, string>
        const p = new TrainPlan()
        p.id = typeof o['id'] === 'string' ? o['id'] : ''
        p.title = typeof o['title'] === 'string' ? o['title'] : ''
        p.summary = typeof o['summary'] === 'string' ? o['summary'] : ''
        p.templateKey = typeof o['templateKey'] === 'string' ? o['templateKey'] : 'custom'
        p.tasksPacked = typeof o['tasksPacked'] === 'string' ? o['tasksPacked'] : ''
        p.status = typeof o['status'] === 'string' ? o['status'] : 'active'
        p.createdAt = typeof o['createdAt'] === 'string' ? o['createdAt'] : ''
        if (p.id.length > 0) {
          out.push(p)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseMoves(text: string): MoveItem[] {
    try {
      const arr = JSON.parse(text) as object[]
      const out: MoveItem[] = []
      for (const raw of arr) {
        const o = raw as Record<string, string>
        const m = new MoveItem()
        m.id = typeof o['id'] === 'string' ? o['id'] : ''
        m.title = typeof o['title'] === 'string' ? o['title'] : ''
        m.category = typeof o['category'] === 'string' ? o['category'] : '热身'
        m.tips = typeof o['tips'] === 'string' ? o['tips'] : ''
        m.purpose = typeof o['purpose'] === 'string' ? o['purpose'] : ''
        m.combo = typeof o['combo'] === 'string' ? o['combo'] : ''
        m.favorited = typeof o['favorited'] === 'string' ? o['favorited'] : '0'
        m.createdAt = typeof o['createdAt'] === 'string' ? o['createdAt'] : ''
        if (m.id.length > 0) {
          out.push(m)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseGoals(text: string): StageGoal[] {
    try {
      const arr = JSON.parse(text) as object[]
      const out: StageGoal[] = []
      for (const raw of arr) {
        const o = raw as Record<string, string | number>
        const g = new StageGoal()
        g.id = typeof o['id'] === 'string' ? o['id'] : ''
        g.title = typeof o['title'] === 'string' ? o['title'] : ''
        g.targetCount = typeof o['targetCount'] === 'number' ? o['targetCount'] : 20
        g.currentCount = typeof o['currentCount'] === 'number' ? o['currentCount'] : 0
        g.unit = typeof o['unit'] === 'string' ? o['unit'] : '次'
        g.syncKind = typeof o['syncKind'] === 'string' ? o['syncKind'] : ''
        g.syncKind = g.syncKind.length > 0 ? g.syncKind : (g.unit === '分钟' || g.unit === '分' ? 'minutes' : 'sessions')
        g.createdAt = typeof o['createdAt'] === 'string' ? o['createdAt'] : ''
        if (g.id.length > 0) {
          out.push(g)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseCards(text: string): KnowledgeCard[] {
    try {
      const arr = JSON.parse(text) as object[]
      const out: KnowledgeCard[] = []
      for (const raw of arr) {
        const o = raw as Record<string, string>
        const k = new KnowledgeCard()
        k.id = typeof o['id'] === 'string' ? o['id'] : ''
        k.title = typeof o['title'] === 'string' ? o['title'] : ''
        k.body = typeof o['body'] === 'string' ? o['body'] : ''
        k.tag = typeof o['tag'] === 'string' ? o['tag'] : '动作要点'
        k.createdAt = typeof o['createdAt'] === 'string' ? o['createdAt'] : ''
        if (k.id.length > 0) {
          out.push(k)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseChecks(text: string): CheckState {
    const c = new CheckState()
    try {
      const o = JSON.parse(text) as Record<string, string>
      c.beforePacked = typeof o['beforePacked'] === 'string' ? o['beforePacked'] : ''
      c.afterPacked = typeof o['afterPacked'] === 'string' ? o['afterPacked'] : ''
    } catch {
      c.beforePacked = ''
      c.afterPacked = ''
    }
    return c
  }
}
