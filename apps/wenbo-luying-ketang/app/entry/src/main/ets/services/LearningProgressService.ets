import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE = 'learning_progress'
const KEY_LEARNED = 'learnedGuideIds'

/** 本地学习进度（按用户设备；新用户默认空） */
export class LearningProgressService {
  private static pref: preferences.Preferences | null = null

  static async ensure(context: common.UIAbilityContext): Promise<void> {
    if (LearningProgressService.pref !== null) {
      return
    }
    LearningProgressService.pref = await preferences.getPreferences(context, STORE)
    const raw = await LearningProgressService.pref.get(KEY_LEARNED, '')
    const text: string = typeof raw === 'string' ? raw : ''
    AppStorage.setOrCreate(KEY_LEARNED, text)
  }

  private static ids(): string[] {
    const raw = AppStorage.get<string>(KEY_LEARNED) ?? ''
    if (raw.length === 0) {
      return []
    }
    const parts = raw.split(',')
    const out: string[] = []
    for (const p of parts) {
      if (p.length > 0) {
        out.push(p)
      }
    }
    return out
  }

  private static async persist(ids: string[]): Promise<void> {
    const joined = ids.join(',')
    AppStorage.setOrCreate(KEY_LEARNED, joined)
    if (LearningProgressService.pref !== null) {
      await LearningProgressService.pref.put(KEY_LEARNED, joined)
      await LearningProgressService.pref.flush()
    }
  }

  static isLearned(id: string): boolean {
    const ids = LearningProgressService.ids()
    for (const x of ids) {
      if (x === id) {
        return true
      }
    }
    return false
  }

  static learnedCount(): number {
    return LearningProgressService.ids().length
  }

  static progressPercent(total: number): number {
    if (total <= 0) {
      return 0
    }
    return Math.min(100, Math.round((LearningProgressService.learnedCount() * 100) / total))
  }

  static async markLearned(id: string): Promise<void> {
    if (LearningProgressService.isLearned(id)) {
      return
    }
    const ids = LearningProgressService.ids()
    ids.push(id)
    await LearningProgressService.persist(ids)
  }

  static badgeLabel(count: number): string {
    if (count >= 5) {
      return '林野导师'
    }
    if (count >= 3) {
      return '露营学徒'
    }
    if (count >= 1) {
      return '入门学员'
    }
    return '待开课'
  }
}
