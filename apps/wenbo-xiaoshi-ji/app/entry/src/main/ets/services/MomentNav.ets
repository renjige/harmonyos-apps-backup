import { DateHelper } from './DateHelper'
import { MomentStore } from './MomentStore'

const KEY_KIND = 'momentNavKind'
const KEY_ID = 'momentNavId'
const KEY_TOKEN = 'momentNavToken'

/** kind: none | note | todo | editor | todoEditor | weeklyReview | dailyWrap | insight | moodTrend | checkin | memorials | memorialEditor | reviewCenter | search | plan | planEditor | topics | topic | topicEditor */
export class MomentNav {  static openNote(id: string): void {
    AppStorage.setOrCreate(KEY_KIND, 'note')
    AppStorage.setOrCreate(KEY_ID, id)
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openTodo(id: string): void {
    AppStorage.setOrCreate(KEY_KIND, 'todo')
    AppStorage.setOrCreate(KEY_ID, id)
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openEditor(id: string): void {
    AppStorage.setOrCreate(KEY_KIND, 'editor')
    AppStorage.setOrCreate(KEY_ID, id)
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openTodoEditor(id: string): void {
    AppStorage.setOrCreate(KEY_KIND, 'todoEditor')
    AppStorage.setOrCreate(KEY_ID, id)
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openWeeklyReview(): void {
    AppStorage.setOrCreate(KEY_KIND, 'weeklyReview')
    AppStorage.setOrCreate(KEY_ID, DateHelper.weekStartKey())
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openDailyWrap(): void {
    AppStorage.setOrCreate(KEY_KIND, 'dailyWrap')
    AppStorage.setOrCreate(KEY_ID, DateHelper.todayKey())
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openInsight(): void {
    AppStorage.setOrCreate(KEY_KIND, 'insight')
    AppStorage.setOrCreate(KEY_ID, '')
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openMoodTrend(): void {
    AppStorage.setOrCreate(KEY_KIND, 'moodTrend')
    AppStorage.setOrCreate(KEY_ID, '')
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openCheckin(): void {
    AppStorage.setOrCreate(KEY_KIND, 'checkin')
    AppStorage.setOrCreate(KEY_ID, '')
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openMemorials(): void {
    AppStorage.setOrCreate(KEY_KIND, 'memorials')
    AppStorage.setOrCreate(KEY_ID, '')
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openMemorialEditor(id: string): void {
    AppStorage.setOrCreate(KEY_KIND, 'memorialEditor')
    AppStorage.setOrCreate(KEY_ID, id)
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openReviewCenter(): void {
    AppStorage.setOrCreate(KEY_KIND, 'reviewCenter')
    AppStorage.setOrCreate(KEY_ID, '')
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openSearch(): void {
    AppStorage.setOrCreate(KEY_KIND, 'search')
    AppStorage.setOrCreate(KEY_ID, '')
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openPlan(id: string): void {
    AppStorage.setOrCreate(KEY_KIND, 'plan')
    AppStorage.setOrCreate(KEY_ID, id)
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openPlanEditor(id: string): void {
    AppStorage.setOrCreate(KEY_KIND, 'planEditor')
    AppStorage.setOrCreate(KEY_ID, id)
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openTopics(): void {
    AppStorage.setOrCreate(KEY_KIND, 'topics')
    AppStorage.setOrCreate(KEY_ID, '')
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openTopic(id: string): void {
    AppStorage.setOrCreate(KEY_KIND, 'topic')
    AppStorage.setOrCreate(KEY_ID, id)
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static openTopicEditor(id: string): void {
    AppStorage.setOrCreate(KEY_KIND, 'topicEditor')
    AppStorage.setOrCreate(KEY_ID, id)
    AppStorage.setOrCreate('tabBarHidden', true)
    MomentNav.bump()
  }

  static close(): void {
    AppStorage.setOrCreate(KEY_KIND, 'none')
    AppStorage.setOrCreate(KEY_ID, '')
    AppStorage.setOrCreate('tabBarHidden', false)
    MomentNav.bump()
    MomentStore.notifyChanged()
  }

  static kind(): string {
    const v = AppStorage.get<string>(KEY_KIND)
    return v !== undefined && v.length > 0 ? v : 'none'
  }

  static id(): string {
    const v = AppStorage.get<string>(KEY_ID)
    return v !== undefined ? v : ''
  }

  static token(): number {
    const v = AppStorage.get<number>(KEY_TOKEN)
    return v !== undefined ? v : 0
  }

  private static bump(): void {
    const cur = MomentNav.token()
    AppStorage.setOrCreate(KEY_TOKEN, cur + 1)
  }
}
