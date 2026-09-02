/** 球场拾光 — 场馆 / 预约领域模型（映射 home-services API） */

export class VenueItem {
  id: string = ''
  title: string = ''
  category: string = ''
  summary: string = ''
  description: string = ''
  priceLabel: string = ''
  coverKey: string = ''
  rating: number = 0
  orderCount: number = 0
  durationLabel: string = ''
  tags: string[] = []
  district: string = ''
  distanceKm: number = 0
}

export class SportCategoryItem {
  id: string = ''
  name: string = ''
  description: string = ''
  coverKey: string = ''
  iconKey: string = ''
  serviceCount: number = 0
}

export class PromotionItem {
  id: string = ''
  title: string = ''
  type: string = ''
  discountLabel: string = ''
  coverKey: string = ''
  summary: string = ''
  body: string = ''
  startAt: string = ''
  endAt: string = ''
  serviceCategory: string = ''
}

export class CaseItem {
  id: string = ''
  title: string = ''
  category: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  district: string = ''
  completedAt: string = ''
}

export class BookingItem {
  id: string = ''
  serviceId: string = ''
  serviceTitle: string = ''
  name: string = ''
  phone: string = ''
  address: string = ''
  preferredDate: string = ''
  preferredTime: string = ''
  remark: string = ''
  status: string = ''
  createdAt: string = ''
}

export class CourtKpiItem {
  label: string = ''
  value: string = ''
  hint: string = ''
  primary: boolean = false
}

export class BannerItem {
  id: string = ''
  tag: string = ''
  title: string = ''
  subtitle: string = ''
  coverKey: string = ''
  linkType: string = ''
  linkId: string = ''
}

export class SportStats {
  totalBookings: number = 0
  confirmedBookings: number = 0
  pendingBookings: number = 0
  favoriteCategory: string = '暂无'
  totalHours: number = 0
}

export class TimelineEntry {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  dateLabel: string = ''
  status: string = ''
  coverKey: string = ''
}

export class AchievementBadge {
  id: string = ''
  title: string = ''
  description: string = ''
  unlocked: boolean = false
  iconKey: string = ''
}

/** 可订时段：open 可订 / full 已满 / past 已过时 */
export class SlotItem {
  time: string = ''
  state: string = 'open'
}

export class StatusPatchRequest {
  status: string = ''
  remark: string = ''

  toJsonString(): string {
    return `{"status":${JSON.stringify(this.status)},"remark":${JSON.stringify(this.remark)}}`
  }
}

export class CreateCourtBookingRequest {
  serviceId: string = ''
  name: string = ''
  phone: string = ''
  address: string = ''
  preferredDate: string = ''
  preferredTime: string = ''
  remark: string = ''
  username: string = ''

  toJsonString(): string {
    return `{"serviceId":${JSON.stringify(this.serviceId)},"name":${JSON.stringify(this.name)},"phone":${JSON.stringify(this.phone)},"address":${JSON.stringify(this.address)},"preferredDate":${JSON.stringify(this.preferredDate)},"preferredTime":${JSON.stringify(this.preferredTime)},"remark":${JSON.stringify(this.remark)},"username":${JSON.stringify(this.username)}}`
  }
}

export class HsRecordWire {
  id: string = ''
  title: string = ''
  name: string = ''
  category: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  priceLabel: string = ''
  coverMedia: string = ''
  rating: number = 0
  orderCount: number = 0
  durationLabel: string = ''
  tags: string[] = []
  iconKey: string = ''
  serviceCount: number = 0
  type: string = ''
  discountLabel: string = ''
  startAt: string = ''
  endAt: string = ''
  serviceCategory: string = ''
  district: string = ''
  completedAt: string = ''
  serviceId: string = ''
  serviceTitle: string = ''
  preferredDate: string = ''
  preferredTime: string = ''
  address: string = ''
  phone: string = ''
  remark: string = ''
  status: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class HsListData {
  list: HsRecordWire[] = []
}

export class HsKpiWire {
  key: string = ''
  label: string = ''
  value: number = 0
}

export class HsKpiListData {
  items: HsKpiWire[] = []
}

export class HsBookingCreateData {
  booking: HsRecordWire = new HsRecordWire()
  order: HsRecordWire = new HsRecordWire()
}
