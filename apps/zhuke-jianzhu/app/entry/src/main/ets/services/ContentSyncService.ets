import { HttpClient } from './HttpClient'
import { ContentCache, ProjectListPayload, NewsListPayload, RemoteNotificationRow } from './ContentCache'
import { UserPrefsService } from './UserPrefsService'
import { UserPrefsSyncService } from './UserPrefsSyncService'
import {
  BannerItem, BusinessItem, ProjectItem, NewsItem,
  CertificateItem, HonorItem, JobItem, CompanyProfile, ContactInfo
} from '../models/ZhukeModels'
import { ApiResponse } from '../models/ApiModels'

/** 从 SaaS 后台拉取展示内容并写入 ContentCache */
export class ContentSyncService {
  static async sync(): Promise<boolean> {
    try {
      const bannersOk = await ContentSyncService.fetchBanners()
      const companyOk = await ContentSyncService.fetchCompany()
      const contactOk = await ContentSyncService.fetchContact()
      const businessesOk = await ContentSyncService.fetchBusinesses()
      const projectsOk = await ContentSyncService.fetchProjects()
      const newsOk = await ContentSyncService.fetchNews()
      const certsOk = await ContentSyncService.fetchCertificates()
      const honorsOk = await ContentSyncService.fetchHonors()
      const jobsOk = await ContentSyncService.fetchJobs()
      await ContentSyncService.fetchNotifications()
      await UserPrefsSyncService.pull()

      const ok = bannersOk || companyOk || contactOk || businessesOk ||
        projectsOk || newsOk || certsOk || honorsOk || jobsOk
      if (ok) {
        ContentCache.synced = true
        AppStorage.setOrCreate('contentSynced', true)
      }
      return ok
    } catch {
      AppStorage.setOrCreate('contentSynced', false)
      return false
    }
  }

  private static isOk<T>(res: ApiResponse<T>): boolean {
    return res.code === 0 && res.data !== undefined && res.data !== null
  }

  private static async fetchBanners(): Promise<boolean> {
    const res = await HttpClient.get<BannerItem[]>('/content/banners')
    if (!ContentSyncService.isOk(res) || res.data === undefined) return false
    ContentCache.banners = res.data
    return res.data.length > 0
  }

  private static async fetchCompany(): Promise<boolean> {
    const res = await HttpClient.get<CompanyProfile>('/content/company')
    if (!ContentSyncService.isOk(res) || res.data === undefined) return false
    ContentCache.company = res.data
    return true
  }

  private static async fetchContact(): Promise<boolean> {
    const res = await HttpClient.get<ContactInfo>('/content/contact')
    if (!ContentSyncService.isOk(res) || res.data === undefined) return false
    ContentCache.contact = res.data
    return true
  }

  private static async fetchBusinesses(): Promise<boolean> {
    const res = await HttpClient.get<BusinessItem[]>('/content/businesses')
    if (!ContentSyncService.isOk(res) || res.data === undefined) return false
    ContentCache.businesses = res.data
    return res.data.length > 0
  }

  private static async fetchProjects(): Promise<boolean> {
    const res = await HttpClient.get<ProjectListPayload>('/content/projects')
    if (!ContentSyncService.isOk(res) || res.data === undefined) return false
    const list = res.data.list ?? []
    for (const p of list) {
      if (p.galleryKeys === undefined || p.galleryKeys.length === 0) {
        p.galleryKeys = [p.coverKey, p.coverKey, p.coverKey]
      }
    }
    ContentCache.projects = list
    return list.length > 0
  }

  private static async fetchNews(): Promise<boolean> {
    const res = await HttpClient.get<NewsListPayload>('/content/news')
    if (!ContentSyncService.isOk(res) || res.data === undefined) return false
    ContentCache.news = res.data.list ?? []
    return ContentCache.news.length > 0
  }

  private static async fetchCertificates(): Promise<boolean> {
    const res = await HttpClient.get<CertificateItem[]>('/content/certificates')
    if (!ContentSyncService.isOk(res) || res.data === undefined) return false
    ContentCache.certificates = res.data
    return res.data.length > 0
  }

  private static async fetchHonors(): Promise<boolean> {
    const res = await HttpClient.get<HonorItem[]>('/content/honors')
    if (!ContentSyncService.isOk(res) || res.data === undefined) return false
    ContentCache.honors = res.data
    return res.data.length > 0
  }

  private static async fetchJobs(): Promise<boolean> {
    const res = await HttpClient.get<JobItem[]>('/content/jobs')
    if (!ContentSyncService.isOk(res) || res.data === undefined) return false
    ContentCache.jobs = res.data
    return res.data.length > 0
  }

  private static async fetchNotifications(): Promise<void> {
    const res = await HttpClient.get<RemoteNotificationRow[]>('/content/notifications')
    if (!ContentSyncService.isOk(res) || res.data === undefined || res.data.length === 0) {
      return
    }
    const remote: RemoteNotificationRow[] = res.data
    UserPrefsService.mergeRemoteNotifications(remote)
  }
}
