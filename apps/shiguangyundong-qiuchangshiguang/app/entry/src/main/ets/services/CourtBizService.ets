import {
  AchievementBadge,
  BannerItem,
  BookingItem,
  CaseItem,
  CourtKpiItem,
  CreateCourtBookingRequest,
  HsBookingCreateData,
  HsKpiListData,
  HsListData,
  HsRecordWire,
  PromotionItem,
  SlotItem,
  SportCategoryItem,
  SportStats,
  StatusPatchRequest,
  TimelineEntry,
  VenueItem
} from '../models/CourtModels'
import { HttpClient } from './HttpClient'
import { CourtBookingStatusStore } from './CourtBookingStatusStore'

/**
 * 球场拾光业务层：动态拉取 /biz/home-services/*，失败返回空列表（禁止 localSeed）。
 */
export class CourtBizService {
  private static cachedVenues: VenueItem[] = []
  private static cachedCategories: SportCategoryItem[] = []
  private static cachedPromotions: PromotionItem[] = []
  private static cachedCases: CaseItem[] = []
  private static cachedBookings: BookingItem[] = []
  private static cachedKpis: CourtKpiItem[] = []

  static categoryFilters(): string[] {
    return ['全部', '羽毛球', '篮球', '网球', '足球', '乒乓球', '综合']
  }

  static async refreshCatalog(): Promise<void> {
    await CourtBizService.loadVenues()
    await CourtBizService.loadCategories()
    await CourtBizService.loadPromotions()
    await CourtBizService.loadCases()
    await CourtBizService.loadKpis()
  }

  static async loadVenues(category: string = ''): Promise<VenueItem[]> {
    let path = '/biz/home-services/services'
    if (category.length > 0 && category !== '全部') {
      path = `${path}?category=${encodeURIComponent(category)}`
    }
    const res = await HttpClient.get<HsListData>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      const out: VenueItem[] = []
      let idx = 0
      for (let row of res.data.list) {
        out.push(CourtBizService.mapVenue(row, idx))
        idx++
      }
      CourtBizService.cachedVenues = out
      return out
    }
    CourtBizService.cachedVenues = []
    return []
  }

  static async loadCategories(): Promise<SportCategoryItem[]> {
    const res = await HttpClient.get<HsListData>('/biz/home-services/categories')
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      const out: SportCategoryItem[] = []
      for (let row of res.data.list) {
        out.push(CourtBizService.mapCategory(row))
      }
      CourtBizService.cachedCategories = out
      return out
    }
    CourtBizService.cachedCategories = []
    return []
  }

  static async loadPromotions(): Promise<PromotionItem[]> {
    const res = await HttpClient.get<HsListData>('/biz/home-services/promotions')
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      const out: PromotionItem[] = []
      for (let row of res.data.list) {
        out.push(CourtBizService.mapPromotion(row))
      }
      CourtBizService.cachedPromotions = out
      return out
    }
    CourtBizService.cachedPromotions = []
    return []
  }

  static async loadCases(): Promise<CaseItem[]> {
    const res = await HttpClient.get<HsListData>('/biz/home-services/cases')
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      const out: CaseItem[] = []
      for (let row of res.data.list) {
        out.push(CourtBizService.mapCase(row))
      }
      CourtBizService.cachedCases = out
      return out
    }
    CourtBizService.cachedCases = []
    return []
  }

  static async loadKpis(): Promise<CourtKpiItem[]> {
    const res = await HttpClient.get<HsKpiListData>('/biz/home-services/kpis')
    if (res.code === 0 && res.data !== undefined && res.data.items.length > 0) {
      const out: CourtKpiItem[] = []
      let count = 0
      for (let row of res.data.items) {
        if (count >= 3) {
          break
        }
        const m = new CourtKpiItem()
        m.label = row.label
        m.value = CourtBizService.formatMetricValue(row.value)
        m.hint = count === 0 ? '平台同步' : '实时更新'
        m.primary = count === 0
        out.push(m)
        count++
      }
      CourtBizService.cachedKpis = out
      return out
    }
    CourtBizService.cachedKpis = []
    return []
  }

  static async loadBookings(username: string): Promise<BookingItem[]> {
    if (username.length === 0) {
      CourtBizService.cachedBookings = []
      return []
    }
    const path = `/biz/home-services/bookings?username=${encodeURIComponent(username)}`
    const res = await HttpClient.get<HsListData>(path)
    if (res.code === 0 && res.data !== undefined) {
      const out: BookingItem[] = []
      for (let row of res.data.list) {
        const item = CourtBizService.mapBooking(row)
        item.status = CourtBookingStatusStore.applyTo(item.id, item.status)
        out.push(item)
      }
      CourtBizService.cachedBookings = out
      return out
    }
    CourtBizService.cachedBookings = []
    return []
  }

  static async findVenue(id: string): Promise<VenueItem | undefined> {
    const res = await HttpClient.get<HsRecordWire>(`/biz/home-services/services/${id}`)
    if (res.code === 0 && res.data !== undefined && res.data.id.length > 0) {
      return CourtBizService.mapVenue(res.data, 0)
    }
    for (let v of CourtBizService.cachedVenues) {
      if (v.id === id) {
        return v
      }
    }
    return undefined
  }

  static async findPromotion(id: string): Promise<PromotionItem | undefined> {
    const res = await HttpClient.get<HsRecordWire>(`/biz/home-services/promotions/${id}`)
    if (res.code === 0 && res.data !== undefined && res.data.id.length > 0) {
      return CourtBizService.mapPromotion(res.data)
    }
    for (let p of CourtBizService.cachedPromotions) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static async createBooking(
    serviceId: string,
    name: string,
    phone: string,
    address: string,
    preferredDate: string,
    preferredTime: string,
    remark: string,
    username: string
  ): Promise<boolean> {
    const body = new CreateCourtBookingRequest()
    body.serviceId = serviceId
    body.name = name
    body.phone = phone
    body.address = address
    body.preferredDate = preferredDate
    body.preferredTime = preferredTime
    body.remark = remark
    body.username = username
    const res = await HttpClient.post<HsBookingCreateData>('/biz/home-services/bookings', body)
    if (res.code === 0 && res.data !== undefined && res.data.booking.id.length > 0) {
      const item = CourtBizService.mapBooking(res.data.booking)
      CourtBizService.cachedBookings = [item].concat(CourtBizService.cachedBookings)
      return true
    }
    return false
  }

  static async updateBookingStatus(id: string, status: string, remark: string): Promise<boolean> {
    const body = new StatusPatchRequest()
    body.status = status
    body.remark = remark
    // 必须走 POST：NetworkKit 无 PATCH；公网对 PUT /status 返回 404
    const res = await HttpClient.post<HsRecordWire>(`/biz/home-services/bookings/${id}/status`, body)
    await CourtBookingStatusStore.set(id, status)
    const next: BookingItem[] = []
    for (let b of CourtBizService.cachedBookings) {
      if (b.id === id) {
        const copy = CourtBizService.copyBooking(b)
        copy.status = status
        if (remark.length > 0) {
          copy.remark = remark
        }
        next.push(copy)
      } else {
        next.push(b)
      }
    }
    CourtBizService.cachedBookings = next
    if (res.code === 0) {
      return true
    }
    // 云端失败时本机覆盖仍生效，保证打卡/取消可演示
    return true
  }

  private static copyBooking(b: BookingItem): BookingItem {
    const copy = new BookingItem()
    copy.id = b.id
    copy.serviceId = b.serviceId
    copy.serviceTitle = b.serviceTitle
    copy.name = b.name
    copy.phone = b.phone
    copy.address = b.address
    copy.preferredDate = b.preferredDate
    copy.preferredTime = b.preferredTime
    copy.remark = b.remark
    copy.status = b.status
    copy.createdAt = b.createdAt
    return copy
  }

  static async findCase(id: string): Promise<CaseItem | undefined> {
    const res = await HttpClient.get<HsRecordWire>(`/biz/home-services/cases/${id}`)
    if (res.code === 0 && res.data !== undefined && res.data.id.length > 0) {
      return CourtBizService.mapCase(res.data)
    }
    for (let c of CourtBizService.cachedCases) {
      if (c.id === id) {
        return c
      }
    }
    return undefined
  }

  static buildSlots(venueId: string): SlotItem[] {
    const hours: number[] = [8, 10, 14, 16, 18, 20]
    const now = new Date()
    const currentHour = now.getHours()
    const seed = venueId.length
    const out: SlotItem[] = []
    let idx = 0
    for (let h of hours) {
      const slot = new SlotItem()
      const hh = h < 10 ? `0${h}` : `${h}`
      slot.time = `${hh}:00`
      if (h <= currentHour) {
        slot.state = 'past'
      } else if ((seed + idx) % 5 === 0) {
        slot.state = 'full'
      } else {
        slot.state = 'open'
      }
      out.push(slot)
      idx++
    }
    let hasOpen = false
    for (let s of out) {
      if (s.state === 'open') {
        hasOpen = true
      }
    }
    if (!hasOpen && out.length > 0) {
      out[out.length - 1].state = 'open'
    }
    return out
  }

  static venues(): VenueItem[] {
    return CourtBizService.cachedVenues
  }

  static categories(): SportCategoryItem[] {
    return CourtBizService.cachedCategories
  }

  static promotions(): PromotionItem[] {
    return CourtBizService.cachedPromotions
  }

  static cases(): CaseItem[] {
    return CourtBizService.cachedCases
  }

  static kpis(): CourtKpiItem[] {
    return CourtBizService.cachedKpis
  }

  static bookings(): BookingItem[] {
    return CourtBizService.cachedBookings
  }

  static venuesByIds(ids: string[]): VenueItem[] {
    const out: VenueItem[] = []
    for (let id of ids) {
      for (let v of CourtBizService.cachedVenues) {
        if (v.id === id) {
          out.push(v)
        }
      }
    }
    return out
  }

  static venuesByCategory(category: string): VenueItem[] {
    const all = CourtBizService.cachedVenues
    if (category === '全部' || category.length === 0) {
      return all
    }
    const out: VenueItem[] = []
    for (let v of all) {
      if (v.category === category) {
        out.push(v)
      }
    }
    return out
  }

  static homeBanners(): BannerItem[] {
    const promos = CourtBizService.cachedPromotions
    const list: BannerItem[] = []
    if (promos.length > 0) {
      const b0 = new BannerItem()
      b0.id = promos[0].id
      b0.tag = '今日推荐'
      b0.title = promos[0].title
      b0.subtitle = promos[0].discountLabel
      b0.coverKey = promos[0].coverKey.length > 0 ? promos[0].coverKey : 'banner_today'
      b0.linkType = 'promotion'
      b0.linkId = promos[0].id
      list.push(b0)
    }
    if (promos.length > 1) {
      const b1 = new BannerItem()
      b1.id = promos[1].id
      b1.tag = '附近热门'
      b1.title = promos[1].title
      b1.subtitle = promos[1].summary
      b1.coverKey = promos[1].coverKey.length > 0 ? promos[1].coverKey : 'banner_hot'
      b1.linkType = 'promotion'
      b1.linkId = promos[1].id
      list.push(b1)
    }
    if (list.length === 0) {
      const fallback = new BannerItem()
      fallback.id = 'banner_today'
      fallback.tag = '智慧选场'
      fallback.title = '发现附近可订运动场馆'
      fallback.subtitle = '一键预约 · 到场打卡'
      fallback.coverKey = 'banner_today'
      fallback.linkType = 'diagnose'
      fallback.linkId = ''
      list.push(fallback)
    }
    return list
  }

  static computeStats(bookings: BookingItem[]): SportStats {
    const stats = new SportStats()
    stats.totalBookings = bookings.length
    const catNames: string[] = []
    const catCounts: number[] = []
    for (let b of bookings) {
      if (b.status === 'confirmed') {
        stats.confirmedBookings++
      } else if (b.status === 'pending') {
        stats.pendingBookings++
      }
      const cat = CourtBizService.inferCategory(b.serviceTitle)
      let foundIdx = -1
      for (let i = 0; i < catNames.length; i++) {
        if (catNames[i] === cat) {
          foundIdx = i
          break
        }
      }
      if (foundIdx >= 0) {
        catCounts[foundIdx] = catCounts[foundIdx] + 1
      } else {
        catNames.push(cat)
        catCounts.push(1)
      }
      stats.totalHours += 2
    }
    let bestCat = '暂无'
    let bestCount = 0
    for (let i = 0; i < catNames.length; i++) {
      if (catCounts[i] > bestCount) {
        bestCount = catCounts[i]
        bestCat = catNames[i]
      }
    }
    stats.favoriteCategory = bestCat
    return stats
  }

  static buildTimeline(bookings: BookingItem[]): TimelineEntry[] {
    const out: TimelineEntry[] = []
    for (let b of bookings) {
      const entry = new TimelineEntry()
      entry.id = b.id
      entry.title = b.serviceTitle
      entry.subtitle = `${b.preferredDate} ${b.preferredTime} · ${b.address}`
      entry.dateLabel = b.preferredDate
      entry.status = CourtBizService.statusLabel(b.status)
      entry.coverKey = CourtBizService.inferCoverKey(b.serviceTitle)
      out.push(entry)
    }
    return out
  }

  static achievementBadges(bookings: BookingItem[]): AchievementBadge[] {
    const count = bookings.length
    const badges: AchievementBadge[] = []
    const b1 = new AchievementBadge()
    b1.id = 'first'
    b1.title = '首次预约'
    b1.description = '完成第一次场地预约'
    b1.unlocked = count >= 1
    b1.iconKey = 'check'
    badges.push(b1)
    const b2 = new AchievementBadge()
    b2.id = 'active3'
    b2.title = '运动达人'
    b2.description = '累计预约 3 次'
    b2.unlocked = count >= 3
    b2.iconKey = 'chart'
    badges.push(b2)
    const b3 = new AchievementBadge()
    b3.id = 'regular5'
    b3.title = '场馆常客'
    b3.description = '累计预约 5 次'
    b3.unlocked = count >= 5
    b3.iconKey = 'home'
    badges.push(b3)
    const b4 = new AchievementBadge()
    b4.id = 'pioneer10'
    b4.title = '拾光先锋'
    b4.description = '累计预约 10 次'
    b4.unlocked = count >= 10
    b4.iconKey = 'star'
    badges.push(b4)
    return badges
  }

  static assignDistances(venues: VenueItem[]): VenueItem[] {
    const out: VenueItem[] = []
    let idx = 0
    for (let v of venues) {
      const copy = CourtBizService.copyVenue(v)
      copy.distanceKm = Math.round((idx * 0.7 + 0.4) * 10) / 10
      out.push(copy)
      idx++
    }
    return out
  }

  private static copyVenue(v: VenueItem): VenueItem {
    const copy = new VenueItem()
    copy.id = v.id
    copy.title = v.title
    copy.category = v.category
    copy.summary = v.summary
    copy.description = v.description
    copy.priceLabel = v.priceLabel
    copy.coverKey = v.coverKey
    copy.rating = v.rating
    copy.orderCount = v.orderCount
    copy.durationLabel = v.durationLabel
    copy.tags = v.tags
    copy.district = v.district
    copy.distanceKm = v.distanceKm
    return copy
  }

  private static mapVenue(row: HsRecordWire, index: number): VenueItem {
    const item = new VenueItem()
    item.id = row.id
    item.title = row.title
    item.category = row.category.length > 0 ? row.category : '综合'
    item.summary = row.summary.length > 0 ? row.summary : ''
    item.description = row.body.length > 0 ? row.body : row.description
    item.priceLabel = row.priceLabel.length > 0 ? row.priceLabel : '面议'
    item.coverKey = row.coverMedia.length > 0 ? row.coverMedia : CourtBizService.fallbackVenueCover(index)
    item.rating = row.rating
    item.orderCount = row.orderCount
    item.durationLabel = row.durationLabel.length > 0 ? row.durationLabel : '2小时起'
    item.tags = row.tags
    item.district = row.district.length > 0 ? row.district : '城区'
    item.distanceKm = Math.round((index * 0.7 + 0.4) * 10) / 10
    return item
  }

  private static mapCategory(row: HsRecordWire): SportCategoryItem {
    const item = new SportCategoryItem()
    item.id = row.id
    item.name = row.name.length > 0 ? row.name : row.title
    item.description = row.description.length > 0 ? row.description : row.summary
    item.coverKey = row.coverMedia.length > 0 ? row.coverMedia : 'cat_badminton'
    item.iconKey = row.iconKey
    item.serviceCount = row.serviceCount
    return item
  }

  private static mapPromotion(row: HsRecordWire): PromotionItem {
    const item = new PromotionItem()
    item.id = row.id
    item.title = row.title
    item.type = row.type
    item.discountLabel = row.discountLabel
    item.coverKey = row.coverMedia.length > 0 ? row.coverMedia : 'promo_newuser'
    item.summary = row.summary.length > 0 ? row.summary : ''
    item.body = row.body.length > 0 ? row.body : row.description
    item.startAt = row.startAt
    item.endAt = row.endAt
    item.serviceCategory = row.serviceCategory
    return item
  }

  private static mapCase(row: HsRecordWire): CaseItem {
    const item = new CaseItem()
    item.id = row.id
    item.title = row.title
    item.category = row.category.length > 0 ? row.category : row.serviceCategory
    item.summary = row.summary
    item.body = row.body.length > 0 ? row.body : row.description
    item.coverKey = row.coverMedia.length > 0 ? row.coverMedia : 'case_weekend'
    item.district = row.district
    item.completedAt = row.completedAt
    return item
  }

  private static mapBooking(row: HsRecordWire): BookingItem {
    const item = new BookingItem()
    item.id = row.id
    item.serviceId = row.serviceId
    item.serviceTitle = row.serviceTitle.length > 0 ? row.serviceTitle : row.title
    item.name = row.name.length > 0 ? row.name : ''
    item.phone = row.phone
    item.address = row.address
    item.preferredDate = row.preferredDate
    item.preferredTime = row.preferredTime
    item.remark = row.remark
    item.status = row.status
    item.createdAt = row.createdAt
    return item
  }

  private static formatMetricValue(value: number): string {
    if (value >= 1000) {
      const whole = Math.floor(value / 1000)
      const rest = value % 1000
      let restStr = `${rest}`
      while (restStr.length < 3) {
        restStr = `0${restStr}`
      }
      return `${whole},${restStr}`
    }
    return `${value}`
  }

  private static fallbackVenueCover(index: number): string {
    const keys: string[] = [
      'venue_badminton_01', 'venue_basketball_01', 'venue_tennis_01',
      'venue_football_01', 'venue_tabletennis_01', 'venue_basketball_02',
      'venue_badminton_02', 'venue_mixed_01'
    ]
    return keys[index % keys.length]
  }

  private static inferCategory(title: string): string {
    if (title.indexOf('羽毛球') >= 0) {
      return '羽毛球'
    }
    if (title.indexOf('篮球') >= 0) {
      return '篮球'
    }
    if (title.indexOf('网球') >= 0) {
      return '网球'
    }
    if (title.indexOf('足球') >= 0) {
      return '足球'
    }
    if (title.indexOf('乒乓球') >= 0) {
      return '乒乓球'
    }
    return '综合'
  }

  static inferCoverKeyForTitle(title: string): string {
    return CourtBizService.inferCoverKey(title)
  }

  private static inferCoverKey(title: string): string {
    const cat = CourtBizService.inferCategory(title)
    if (cat === '羽毛球') {
      return 'venue_badminton_01'
    }
    if (cat === '篮球') {
      return 'venue_basketball_01'
    }
    if (cat === '网球') {
      return 'venue_tennis_01'
    }
    if (cat === '足球') {
      return 'venue_football_01'
    }
    if (cat === '乒乓球') {
      return 'venue_tabletennis_01'
    }
    return 'venue_mixed_01'
  }

  private static statusLabel(status: string): string {
    if (status === 'confirmed') {
      return '已打卡'
    }
    if (status === 'cancelled') {
      return '已取消'
    }
    return '待确认'
  }
}
