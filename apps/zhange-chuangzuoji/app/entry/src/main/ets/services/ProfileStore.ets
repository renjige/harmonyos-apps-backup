import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { CreatorProfile } from '../models/PortfolioModels'

const STORE = 'zhange_profile_v1'
const KEY_PROFILE = 'profile'

export class ProfileStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ProfileStore.pref = await preferences.getPreferences(context, STORE)
      await ProfileStore.ensureDefault()
    } catch {
      ProfileStore.pref = null
    }
  }

  static async load(): Promise<CreatorProfile> {
    const raw = await ProfileStore.getString(KEY_PROFILE, '')
    if (raw.length === 0) {
      return ProfileStore.defaultProfile()
    }
    try {
      const parsed = JSON.parse(raw) as object
      return ProfileStore.mapProfile(parsed)
    } catch {
      return ProfileStore.defaultProfile()
    }
  }

  static async save(profile: CreatorProfile): Promise<void> {
    const row: Record<string, string | string[]> = {}
    row['name'] = profile.name
    row['avatarKey'] = profile.avatarKey
    row['title'] = profile.title
    row['bio'] = profile.bio
    row['skills'] = profile.skills
    row['email'] = profile.email
    await ProfileStore.putString(KEY_PROFILE, JSON.stringify(row), true)
  }

  private static async ensureDefault(): Promise<void> {
    const raw = await ProfileStore.getString(KEY_PROFILE, '')
    if (raw.length > 0) {
      return
    }
    await ProfileStore.save(ProfileStore.defaultProfile())
  }

  private static defaultProfile(): CreatorProfile {
    const p = new CreatorProfile()
    p.name = '林展格'
    p.avatarKey = 'hero_studio'
    p.title = '视觉与交互创作者 · 用作品讲述故事'
    p.bio = '专注 UI/UX 设计、插画与摄影创作，相信好的作品需要留白与层次。' +
      '曾在互联网与设计工作室参与多个鸿蒙原生项目，现独立创作并持续探索数字化展示方式。'
    p.skills = ['UI设计', '插画', '摄影', 'ArkUI', '品牌视觉', '动效']
    p.email = 'hello@mozhan.studio'
    return p
  }

  private static mapProfile(row: object): CreatorProfile {
    const p = new CreatorProfile()
    const r = row as Record<string, string | string[]>
    p.name = typeof r['name'] === 'string' ? r['name'] : ''
    p.avatarKey = typeof r['avatarKey'] === 'string' ? r['avatarKey'] : 'hero_studio'
    p.title = typeof r['title'] === 'string' ? r['title'] : ''
    p.bio = typeof r['bio'] === 'string' ? r['bio'] : ''
    p.email = typeof r['email'] === 'string' ? r['email'] : ''
    if (Array.isArray(r['skills'])) {
      p.skills = r['skills'] as string[]
    }
    return p
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

  private static async putString(key: string, value: string, flush: boolean): Promise<void> {
    if (ProfileStore.pref === null) {
      return
    }
    try {
      await ProfileStore.pref.put(key, value)
      if (flush) {
        await ProfileStore.pref.flush()
      }
    } catch {
      // ignore
    }
  }
}
