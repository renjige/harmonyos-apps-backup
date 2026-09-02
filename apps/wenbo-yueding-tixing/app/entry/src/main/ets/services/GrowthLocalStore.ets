import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  ActivityBundle,
  ActivityLogItem,
  AchievementBundle,
  AchievementState,
  CheckInBundle,
  CheckInRecord,
  CollectionBundle,
  CommitmentPlan,
  FavoriteTemplate,
  FavoriteTemplateBundle,
  PlanBundle,
  TagBundle,
  UserCollection,
  UserTag
} from '../models/GrowthModels'

const STORE = 'growth_local'

export class GrowthLocalStore {
  private static pref: preferences.Preferences | null = null
  private static activities: ActivityBundle = new ActivityBundle()
  private static plans: PlanBundle = new PlanBundle()
  private static collections: CollectionBundle = new CollectionBundle()
  private static tags: TagBundle = new TagBundle()
  private static checkIns: CheckInBundle = new CheckInBundle()
  private static achievements: AchievementBundle = new AchievementBundle()
  private static favTemplates: FavoriteTemplateBundle = new FavoriteTemplateBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      GrowthLocalStore.pref = await preferences.getPreferences(context, STORE)
      GrowthLocalStore.activities = GrowthLocalStore.parseJson(
        await GrowthLocalStore.getString('activities'), new ActivityBundle()) as ActivityBundle
      GrowthLocalStore.plans = GrowthLocalStore.parseJson(
        await GrowthLocalStore.getString('plans'), new PlanBundle()) as PlanBundle
      GrowthLocalStore.collections = GrowthLocalStore.parseJson(
        await GrowthLocalStore.getString('collections'), new CollectionBundle()) as CollectionBundle
      GrowthLocalStore.tags = GrowthLocalStore.parseJson(
        await GrowthLocalStore.getString('tags'), new TagBundle()) as TagBundle
      GrowthLocalStore.checkIns = GrowthLocalStore.parseJson(
        await GrowthLocalStore.getString('checkIns'), new CheckInBundle()) as CheckInBundle
      GrowthLocalStore.achievements = GrowthLocalStore.parseJson(
        await GrowthLocalStore.getString('achievements'), new AchievementBundle()) as AchievementBundle
      GrowthLocalStore.favTemplates = GrowthLocalStore.parseJson(
        await GrowthLocalStore.getString('favTemplates'), new FavoriteTemplateBundle()) as FavoriteTemplateBundle
    } catch {
      GrowthLocalStore.resetCaches()
    }
  }

  private static resetCaches(): void {
    GrowthLocalStore.activities = new ActivityBundle()
    GrowthLocalStore.plans = new PlanBundle()
    GrowthLocalStore.collections = new CollectionBundle()
    GrowthLocalStore.tags = new TagBundle()
    GrowthLocalStore.checkIns = new CheckInBundle()
    GrowthLocalStore.achievements = new AchievementBundle()
    GrowthLocalStore.favTemplates = new FavoriteTemplateBundle()
  }

  static activityLogs(): ActivityLogItem[] {
    return GrowthLocalStore.activities.logs
  }

  static async saveActivities(next: ActivityBundle): Promise<void> {
    GrowthLocalStore.activities = next
    await GrowthLocalStore.putString('activities', JSON.stringify(next))
  }

  static planList(): CommitmentPlan[] {
    return GrowthLocalStore.plans.plans
  }

  static async savePlans(next: PlanBundle): Promise<void> {
    GrowthLocalStore.plans = next
    await GrowthLocalStore.putString('plans', JSON.stringify(next))
  }

  static collectionList(): UserCollection[] {
    return GrowthLocalStore.collections.collections
  }

  static async saveCollections(next: CollectionBundle): Promise<void> {
    GrowthLocalStore.collections = next
    await GrowthLocalStore.putString('collections', JSON.stringify(next))
  }

  static tagList(): UserTag[] {
    return GrowthLocalStore.tags.tags
  }

  static async saveTags(next: TagBundle): Promise<void> {
    GrowthLocalStore.tags = next
    await GrowthLocalStore.putString('tags', JSON.stringify(next))
  }

  static checkInList(): CheckInRecord[] {
    return GrowthLocalStore.checkIns.records
  }

  static async saveCheckIns(next: CheckInBundle): Promise<void> {
    GrowthLocalStore.checkIns = next
    await GrowthLocalStore.putString('checkIns', JSON.stringify(next))
  }

  static achievementList(): AchievementState[] {
    return GrowthLocalStore.achievements.states
  }

  static async saveAchievements(next: AchievementBundle): Promise<void> {
    GrowthLocalStore.achievements = next
    await GrowthLocalStore.putString('achievements', JSON.stringify(next))
  }

  static favoriteTemplates(): FavoriteTemplate[] {
    return GrowthLocalStore.favTemplates.items
  }

  static async saveFavoriteTemplates(next: FavoriteTemplateBundle): Promise<void> {
    GrowthLocalStore.favTemplates = next
    await GrowthLocalStore.putString('favTemplates', JSON.stringify(next))
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  private static async getString(key: string): Promise<string> {
    if (GrowthLocalStore.pref === null) {
      return ''
    }
    try {
      const v = await GrowthLocalStore.pref.get(key, '')
      return typeof v === 'string' ? v : ''
    } catch {
      return ''
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (GrowthLocalStore.pref === null) {
      return
    }
    try {
      await GrowthLocalStore.pref.put(key, value)
      await GrowthLocalStore.pref.flush()
    } catch {
    }
  }

  private static parseJson(raw: string, fallback: object): object {
    if (raw.length === 0) {
      return fallback
    }
    try {
      return JSON.parse(raw) as object
    } catch {
      return fallback
    }
  }
}
