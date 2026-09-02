import { BrowseRecord, AppNotification } from '../models/ZhukeModels'
import { RemoteNotificationRow } from './ContentCache'
import { UserPrefsSyncService } from './UserPrefsSyncService'

/** 收藏、浏览记录、通知 — 本地持久化（AppStorage），登录后与 SaaS 同步 */
export class UserPrefsService {
  private static favKey(): string {
    return 'zhuke_favorites'
  }

  private static historyKey(): string {
    return 'zhuke_history'
  }

  private static notifyKey(): string {
    return 'zhuke_notifications'
  }

  static isFavorite(type: string, id: string): boolean {
    const key = `${type}:${id}`
    const raw = AppStorage.get<string>(UserPrefsService.favKey()) ?? ''
    return raw.indexOf(key) >= 0
  }

  static toggleFavorite(type: string, id: string, title: string): boolean {
    const key = `${type}:${id}`
    const raw = AppStorage.get<string>(UserPrefsService.favKey()) ?? ''
    const parts = raw.length > 0 ? raw.split('|') : []
    let found = false
    const next: string[] = []
    for (const p of parts) {
      if (p.startsWith(key + '::') || p === key) {
        found = true
      } else if (p.length > 0) {
        next.push(p)
      }
    }
    if (!found) {
      next.unshift(`${key}::${title}`)
    }
    AppStorage.setOrCreate(UserPrefsService.favKey(), next.join('|'))
    UserPrefsSyncService.pushFavoriteToggle(type, id, title)
    return !found
  }

  static removeFavorite(type: string, id: string): void {
    const key = `${type}:${id}`
    const raw = AppStorage.get<string>(UserPrefsService.favKey()) ?? ''
    const parts = raw.length > 0 ? raw.split('|') : []
    const next: string[] = []
    for (const p of parts) {
      if (!p.startsWith(key + '::') && p !== key) {
        next.push(p)
      }
    }
    AppStorage.setOrCreate(UserPrefsService.favKey(), next.join('|'))
    UserPrefsSyncService.pushFavoritesSnapshot()
  }

  static favorites(): BrowseRecord[] {
    const raw = AppStorage.get<string>(UserPrefsService.favKey()) ?? ''
    const list: BrowseRecord[] = []
    if (raw.length === 0) return list
    const parts = raw.split('|')
    for (const p of parts) {
      const segs = p.split('::')
      if (segs.length < 2) continue
      const idParts = segs[0].split(':')
      const r = new BrowseRecord()
      r.type = idParts[0]
      r.id = idParts[1]
      r.title = segs[1]
      r.viewedAt = ''
      list.push(r)
    }
    return list
  }

  static addHistory(type: string, id: string, title: string): void {
    const key = `${type}:${id}`
    const raw = AppStorage.get<string>(UserPrefsService.historyKey()) ?? ''
    const parts = raw.length > 0 ? raw.split('|') : []
    const next: string[] = [`${key}::${title}::${Date.now()}`]
    for (const p of parts) {
      if (!p.startsWith(key + '::')) {
        next.push(p)
      }
      if (next.length >= 30) break
    }
    AppStorage.setOrCreate(UserPrefsService.historyKey(), next.join('|'))
    UserPrefsSyncService.pushHistory(type, id, title)
  }

  static history(): BrowseRecord[] {
    const raw = AppStorage.get<string>(UserPrefsService.historyKey()) ?? ''
    const list: BrowseRecord[] = []
    if (raw.length === 0) return list
    const parts = raw.split('|')
    for (const p of parts) {
      const segs = p.split('::')
      if (segs.length < 3) continue
      const idParts = segs[0].split(':')
      const r = new BrowseRecord()
      r.type = idParts[0]
      r.id = idParts[1]
      r.title = segs[1]
      r.viewedAt = UserPrefsService.formatTime(Number(segs[2]))
      list.push(r)
    }
    return list
  }

  static clearHistory(): void {
    AppStorage.setOrCreate(UserPrefsService.historyKey(), '')
    UserPrefsSyncService.pushClearHistory()
  }

  static notifications(): AppNotification[] {
    const seeded = AppStorage.get<boolean>('zhuke_notify_seeded_v2')
    if (seeded !== true) {
      UserPrefsService.seedNotifications()
      AppStorage.setOrCreate('zhuke_notify_seeded_v2', true)
    }
    const raw = AppStorage.get<string>(UserPrefsService.notifyKey()) ?? ''
    const list: AppNotification[] = []
    if (raw.length === 0) return list
    const parts = raw.split('|')
    for (const p of parts) {
      const segs = p.split('::')
      if (segs.length < 4) continue
      const n = new AppNotification()
      n.id = segs[0]
      n.title = segs[1]
      n.body = segs[2]
      n.read = segs[3] === '1'
      n.createdAt = segs[4] ?? ''
      n.fullBody = segs[5] ?? segs[2]
      list.push(n)
    }
    return list
  }

  static unreadCount(): number {
    let count = 0
    for (const n of UserPrefsService.notifications()) {
      if (!n.read) count++
    }
    return count
  }

  static markAllRead(): void {
    const list = UserPrefsService.notifications()
    const parts: string[] = []
    for (const n of list) {
      parts.push(UserPrefsService.serializeNotification(n, true))
    }
    AppStorage.setOrCreate(UserPrefsService.notifyKey(), parts.join('|'))
  }

  static markRead(id: string): void {
    const list = UserPrefsService.notifications()
    const parts: string[] = []
    for (const n of list) {
      parts.push(UserPrefsService.serializeNotification(n, n.id === id ? true : n.read))
    }
    AppStorage.setOrCreate(UserPrefsService.notifyKey(), parts.join('|'))
  }

  static notificationById(id: string): AppNotification | null {
    for (const n of UserPrefsService.notifications()) {
      if (n.id === id) return n
    }
    return null
  }

  /** 合并后台推送的通知，保留本地已读状态 */
  static mergeRemoteNotifications(remote: RemoteNotificationRow[]): void {
    const readMap: Map<string, boolean> = new Map()
    for (const n of UserPrefsService.notifications()) {
      readMap.set(n.id, n.read)
    }
    const parts: string[] = []
    for (const row of remote) {
      const n = row.toAppNotification()
      const read = readMap.get(n.id) === true
      parts.push(UserPrefsService.serializeNotification(n, read))
    }
    AppStorage.setOrCreate(UserPrefsService.notifyKey(), parts.join('|'))
    AppStorage.setOrCreate('zhuke_notify_seeded_v2', true)
  }

  private static serializeNotification(n: AppNotification, read: boolean): string {
    const full = n.fullBody.length > 0 ? n.fullBody : n.body
    return `${n.id}::${n.title}::${n.body}::${read ? '1' : '0'}::${n.createdAt}::${full}`
  }

  private static seedNotifications(): void {
    const parts: string[] = [
      'nt1::欢迎了解筑科建筑::感谢您下载筑科建筑，浏览工程案例与企业资质。::0::2024-05-20::' +
        '感谢您下载并使用筑科建筑 App。\n\n' +
        '在这里您可以浏览精品工程案例、了解企业资质与荣誉、查看行业资讯，' +
        '还可以在线留言咨询与投递简历。登录后可同步收藏内容与浏览记录。\n\n' +
        '如有任何问题，欢迎通过「联系我们」或「意见反馈」与我们取得联系。',
      'nt2::春季招聘进行中::工程部、市政部多个岗位热招中。::0::2024-05-18::' +
        '筑科建筑 2024 年春季校园与社会招聘已正式启动。\n\n' +
        '热招岗位包括：项目经理、市政工程师、装饰设计师、安全员等。\n' +
        '工作地点覆盖北京、天津、上海及全国在建项目。\n\n' +
        '请进入「人才招聘」查看岗位详情，或通过 hr@zhuke-arch.com 投递简历。',
      'nt3::新工程案例上线::筑科总部大厦项目已加入精品工程展示。::1::2024-05-15::' +
        '筑科总部大厦项目现已上线「工程案例」专区。\n\n' +
        '该项目为 5A 甲级写字楼，采用 BIM 全过程管理与绿色施工技术，' +
        '已于 2024 年 6 月顺利竣工。欢迎前往案例详情页查看项目介绍与施工亮点。'
    ]
    AppStorage.setOrCreate(UserPrefsService.notifyKey(), parts.join('|'))
  }

  private static formatTime(ts: number): string {
    const d = new Date(ts)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const h = d.getHours()
    const min = d.getMinutes()
    return `${m}月${day}日 ${h}:${min < 10 ? '0' + min : min}`
  }
}
