import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { SeasonGoal } from '../models/SportExtra'

export class GoalStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      GoalStore.pref = await preferences.getPreferences(context, 'saichang_goal_v1')
    } catch {
      GoalStore.pref = null
    }
  }

  static async load(): Promise<SeasonGoal> {
    const g = new SeasonGoal()
    g.year = new Date().getFullYear()
    if (GoalStore.pref === null) {
      return g
    }
    try {
      const y = await GoalStore.pref.get('year', `${g.year}`)
      const m = await GoalStore.pref.get('matches', `${g.targetMatches}`)
      const min = await GoalStore.pref.get('minutes', `${g.targetMinutes}`)
      g.year = parseInt(`${y}`, 10)
      g.targetMatches = parseInt(`${m}`, 10)
      g.targetMinutes = parseInt(`${min}`, 10)
    } catch {
      // keep defaults
    }
    return g
  }

  static async save(goal: SeasonGoal): Promise<void> {
    if (GoalStore.pref === null) {
      return
    }
    try {
      await GoalStore.pref.put('year', `${goal.year}`)
      await GoalStore.pref.put('matches', `${goal.targetMatches}`)
      await GoalStore.pref.put('minutes', `${goal.targetMinutes}`)
      await GoalStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
