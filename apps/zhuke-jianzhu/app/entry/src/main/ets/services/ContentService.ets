import { MockData } from '../data/MockData'
import { ContentCache } from './ContentCache'
import {
  BannerItem, BusinessItem, ProjectItem, NewsItem,
  CertificateItem, HonorItem, JobItem, CompanyProfile, ContactInfo, CategoryTab
} from '../models/ZhukeModels'

export class ContentService {
  static projectCategoryLabel(key: string): string {
    if (key === 'building') return '房建工程'
    if (key === 'municipal') return '市政工程'
    if (key === 'decoration') return '装饰装修'
    if (key === 'landscape') return '园林工程'
    return '全部'
  }

  static newsCategoryLabel(key: string): string {
    if (key === 'company') return '企业新闻'
    if (key === 'industry') return '行业资讯'
    if (key === 'project') return '项目动态'
    if (key === 'notice') return '通知公告'
    return '全部'
  }

  static projectCategories(): CategoryTab[] {
    return [
      CategoryTab.make('all', '全部'),
      CategoryTab.make('building', '房建工程'),
      CategoryTab.make('municipal', '市政工程'),
      CategoryTab.make('decoration', '装饰装修'),
      CategoryTab.make('landscape', '园林工程')
    ]
  }

  static newsCategories(): CategoryTab[] {
    return [
      CategoryTab.make('all', '全部'),
      CategoryTab.make('company', '企业新闻'),
      CategoryTab.make('industry', '行业资讯'),
      CategoryTab.make('project', '项目动态'),
      CategoryTab.make('notice', '通知公告')
    ]
  }

  static banners(): BannerItem[] {
    if (ContentCache.synced && ContentCache.banners.length > 0) {
      return ContentCache.banners
    }
    return MockData.banners()
  }

  static company(): CompanyProfile {
    if (ContentCache.synced && ContentCache.company !== null) {
      return ContentCache.company
    }
    return MockData.company()
  }

  static contact(): ContactInfo {
    if (ContentCache.synced && ContentCache.contact !== null) {
      return ContentCache.contact
    }
    return MockData.contact()
  }

  static businesses(): BusinessItem[] {
    if (ContentCache.synced && ContentCache.businesses.length > 0) {
      return ContentCache.businesses
    }
    return MockData.businesses()
  }

  static businessById(id: string): BusinessItem | null {
    for (const b of ContentService.businesses()) {
      if (b.id === id) return b
    }
    return null
  }

  static projects(category: string = 'all'): ProjectItem[] {
    const all = ContentCache.synced && ContentCache.projects.length > 0 ?
      ContentCache.projects : MockData.projects()
    if (category === 'all') return all
    const filtered: ProjectItem[] = []
    for (const p of all) {
      if (p.category === category) filtered.push(p)
    }
    return filtered
  }

  static featuredProjects(): ProjectItem[] {
    const result: ProjectItem[] = []
    for (const p of ContentService.projects()) {
      if (p.featured) result.push(p)
    }
    return result.slice(0, 4)
  }

  static projectById(id: string): ProjectItem | null {
    for (const p of ContentService.projects()) {
      if (p.id === id) return p
    }
    return null
  }

  static news(category: string = 'all'): NewsItem[] {
    const all = ContentCache.synced && ContentCache.news.length > 0 ?
      ContentCache.news : MockData.news()
    if (category === 'all') return all
    const filtered: NewsItem[] = []
    for (const n of all) {
      if (n.category === category) filtered.push(n)
    }
    return filtered
  }

  static latestNews(limit: number = 3): NewsItem[] {
    return ContentService.news().slice(0, limit)
  }

  static newsById(id: string): NewsItem | null {
    for (const n of ContentService.news()) {
      if (n.id === id) return n
    }
    return null
  }

  static certificates(): CertificateItem[] {
    if (ContentCache.synced && ContentCache.certificates.length > 0) {
      return ContentCache.certificates
    }
    return MockData.certificates()
  }

  static honors(): HonorItem[] {
    if (ContentCache.synced && ContentCache.honors.length > 0) {
      return ContentCache.honors
    }
    return MockData.honors()
  }

  static honorById(id: string): HonorItem | null {
    for (const h of ContentService.honors()) {
      if (h.id === id) return h
    }
    return null
  }

  static jobs(): JobItem[] {
    if (ContentCache.synced && ContentCache.jobs.length > 0) {
      return ContentCache.jobs
    }
    return MockData.jobs()
  }

  static jobById(id: string): JobItem | null {
    for (const j of ContentService.jobs()) {
      if (j.id === id) return j
    }
    return null
  }

  static isRemoteSynced(): boolean {
    return ContentCache.synced
  }
}
