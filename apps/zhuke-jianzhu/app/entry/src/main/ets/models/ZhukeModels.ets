/** 筑科建筑 — 领域模型 */

export class BannerItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  imageKey: string = 'banner_landmark'
}

export class BusinessItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  icon: string = 'biz'
  highlights: string[] = []
}

export class ProjectItem {
  id: string = ''
  title: string = ''
  category: string = 'building'
  coverKey: string = 'project_building'
  summary: string = ''
  location: string = ''
  completedAt: string = ''
  galleryKeys: string[] = []
  description: string = ''
  featured: boolean = false
}

export class NewsItem {
  id: string = ''
  title: string = ''
  category: string = 'company'
  summary: string = ''
  content: string = ''
  publishedAt: string = ''
  coverKey: string = 'news_company'
}

export class CertificateItem {
  id: string = ''
  name: string = ''
  issuer: string = ''
  validUntil: string = ''
  coverKey: string = 'cert_qualification'
}

export class HonorItem {
  id: string = ''
  title: string = ''
  year: string = ''
  imageKey: string = 'honor_trophy'
  description: string = ''
  issuer: string = ''
}

export class JobItem {
  id: string = ''
  title: string = ''
  department: string = ''
  location: string = ''
  salary: string = ''
  experience: string = ''
  education: string = ''
  requirements: string[] = []
  responsibilities: string[] = []
  contactPhone: string = ''
  contactEmail: string = ''
  publishedAt: string = ''
}

export class CompanyProfile {
  name: string = ''
  intro: string = ''
  culture: string = ''
  vision: string = ''
  foundedYear: string = ''
  employeeCount: string = ''
  registeredCapital: string = ''
}

export class ContactInfo {
  address: string = ''
  phone: string = ''
  email: string = ''
  workHours: string = ''
  imageKey: string = 'contact_office'
  latitude: number = 39.9042
  longitude: number = 116.4074
}

export class MessageForm {
  name: string = ''
  phone: string = ''
  content: string = ''
}

export class BrowseRecord {
  id: string = ''
  type: string = ''
  title: string = ''
  viewedAt: string = ''
}

export class AppNotification {
  id: string = ''
  title: string = ''
  body: string = ''
  fullBody: string = ''
  read: boolean = false
  createdAt: string = ''
}

export class CategoryTab {
  key: string = ''
  label: string = ''

  static make(key: string, label: string): CategoryTab {
    const t = new CategoryTab()
    t.key = key
    t.label = label
    return t
  }
}
