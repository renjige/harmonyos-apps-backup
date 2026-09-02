import {
  BannerItem, BusinessItem, ProjectItem, NewsItem,
  CertificateItem, HonorItem, JobItem, CompanyProfile, ContactInfo, AppNotification
} from '../models/ZhukeModels'

/** 后台同步内容缓存 — ContentSyncService 写入，ContentService 读取 */
export class ContentCache {
  static synced: boolean = false
  static banners: BannerItem[] = []
  static company: CompanyProfile | null = null
  static contact: ContactInfo | null = null
  static businesses: BusinessItem[] = []
  static projects: ProjectItem[] = []
  static news: NewsItem[] = []
  static certificates: CertificateItem[] = []
  static honors: HonorItem[] = []
  static jobs: JobItem[] = []

  static reset(): void {
    ContentCache.synced = false
    ContentCache.banners = []
    ContentCache.company = null
    ContentCache.contact = null
    ContentCache.businesses = []
    ContentCache.projects = []
    ContentCache.news = []
    ContentCache.certificates = []
    ContentCache.honors = []
    ContentCache.jobs = []
  }
}

export class ProjectListPayload {
  list: ProjectItem[] = []
  total: number = 0
}

export class NewsListPayload {
  list: NewsItem[] = []
  total: number = 0
}

export class RemoteNotificationRow {
  id: string = ''
  title: string = ''
  body: string = ''
  fullBody: string = ''
  createdAt: string = ''

  toAppNotification(): AppNotification {
    const n = new AppNotification()
    n.id = this.id
    n.title = this.title
    n.body = this.body
    n.fullBody = this.fullBody.length > 0 ? this.fullBody : this.body
    n.createdAt = this.createdAt
    n.read = false
    return n
  }
}

export class MessageSubmitResult {
  id: string = ''
}
