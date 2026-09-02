import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { SportGoal, UserProfile } from '../models/SportRecord'

const KEY_PROFILE = 'profile'
const KEY_GOAL = 'goal'
const KEY_DARK = 'dark_mode'

export class ProfileStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ProfileStore.pref = await preferences.getPreferences(context, 'yundong_profile_v1')
    } catch {
      ProfileStore.pref = null
    }
  }

  static async loadProfile(): Promise<UserProfile> {
    const raw = await ProfileStore.getString(KEY_PROFILE, '')
    const p = new UserProfile()
    if (raw.length === 0) {
      return p
    }
    const parts = raw.split('\t')
    if (parts.length >= 1) {
      p.nickname = parts[0]
    }
    if (parts.length >= 2) {
      p.avatarPath = parts[1]
    }
    return p
  }

  static async saveProfile(profile: UserProfile): Promise<void> {
    await ProfileStore.putString(KEY_PROFILE, `${profile.nickname}\t${profile.avatarPath}`)
  }

  static async loadGoal(): Promise<SportGoal> {
    const raw = await ProfileStore.getString(KEY_GOAL, '')
    const g = new SportGoal()
    if (raw.length === 0) {
      return g
    }
    const parts = raw.split('\t')
    if (parts.length >= 1) {
      g.monthlySessions = parseInt(parts[0], 10)
    }
    if (parts.length >= 2) {
      g.yearlySessions = parseInt(parts[1], 10)
    }
    return g
  }

  static async saveGoal(goal: SportGoal): Promise<void> {
    await ProfileStore.putString(KEY_GOAL, `${goal.monthlySessions}\t${goal.yearlySessions}`)
  }

  static async isDarkMode(): Promise<boolean> {
    const v = await ProfileStore.getString(KEY_DARK, '0')
    return v === '1'
  }

  static async setDarkMode(on: boolean): Promise<void> {
    await ProfileStore.putString(KEY_DARK, on ? '1' : '0')
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ProfileStore.pref === null) {
      return fallback
    }
    try {
      const v = await ProfileStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ProfileStore.pref === null) {
      return
    }
    try {
      await ProfileStore.pref.put(key, value)
      await ProfileStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
