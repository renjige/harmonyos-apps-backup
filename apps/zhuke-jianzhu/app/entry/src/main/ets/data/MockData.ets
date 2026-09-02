import {
  BannerItem, BusinessItem, ProjectItem, NewsItem,
  CertificateItem, HonorItem, JobItem, CompanyProfile, ContactInfo
} from '../models/ZhukeModels'

export class MockData {
  static company(): CompanyProfile {
    const c = new CompanyProfile()
    c.name = '筑科建筑工程有限公司'
    c.foundedYear = '2008'
    c.registeredCapital = '5000万元'
    c.employeeCount = '680+'
    c.intro = '筑科建筑是一家专注于房建、市政、装饰装修及园林工程的综合性建筑企业。' +
      '公司秉承"筑造精品、科技赋能"的理念，以高标准质量管理和精细化施工著称，' +
      '累计承建各类工程项目200余项，多次荣获省市优质工程奖。'
    c.culture = '诚信 · 专业 · 创新 · 共赢\n' +
      '我们倡导工匠精神，以安全为底线、质量为生命、客户为中心，' +
      '打造有温度、有责任的建筑品牌。'
    c.vision = '成为区域领先的建筑工程综合服务商，以品质工程助力城市发展。'
    return c
  }

  static contact(): ContactInfo {
    const c = new ContactInfo()
    c.address = '北京市朝阳区建国路88号筑科大厦18层'
    c.phone = '400-888-6688'
    c.email = 'contact@zhuke-arch.com'
    c.workHours = '周一至周五 9:00-18:00'
    c.imageKey = 'contact_office'
    c.latitude = 39.9087
    c.longitude = 116.4716
    return c
  }

  static banners(): BannerItem[] {
    const list: BannerItem[] = []
    const b1 = new BannerItem()
    b1.id = 'b1'
    b1.title = '筑造城市地标'
    b1.subtitle = '20年匠心 · 200+精品工程'
    b1.imageKey = 'banner_landmark'
    list.push(b1)
    const b2 = new BannerItem()
    b2.id = 'b2'
    b2.title = '市政工程专家'
    b2.subtitle = '道路 · 桥梁 · 管网一体化施工'
    b2.imageKey = 'banner_municipal'
    list.push(b2)
    const b3 = new BannerItem()
    b3.id = 'b3'
    b3.title = '绿色建造 智慧管理'
    b3.subtitle = 'BIM应用 · 绿色施工 · 安全零事故'
    b3.imageKey = 'banner_green'
    list.push(b3)
    return list
  }

  static businesses(): BusinessItem[] {
    const list: BusinessItem[] = []
    const items: string[][] = [
      ['b1', '建筑工程', '房建、工业厂房、公共建筑总承包', '房屋建筑、结构工程、机电安装'],
      ['b2', '市政工程', '道路、桥梁、管网、综合管廊', '市政道路、给排水、照明工程'],
      ['b3', '装饰装修', '商业空间、办公、酒店精装修', '室内装修、幕墙、软装配套'],
      ['b4', '工程咨询', '可研、造价、招投标咨询', '前期策划、投资估算、方案优化'],
      ['b5', '工程管理', '全过程项目管理与监理', '进度管控、质量安全、成本控制']
    ]
    for (const row of items) {
      const b = new BusinessItem()
      b.id = row[0]
      b.title = row[1]
      b.summary = row[2]
      b.highlights = row[3].split('、')
      list.push(b)
    }
    return list
  }

  static projects(): ProjectItem[] {
    const list: ProjectItem[] = []
    const raw: string[][] = [
      ['p1', '筑科总部大厦', 'building', 'project_building', '5A甲级写字楼', '北京朝阳', '2024-06', 'true'],
      ['p2', '星河湾住宅小区', 'building', 'project_building', '32万㎡高品质社区', '河北廊坊', '2023-12', 'true'],
      ['p3', '城市快速路改造', 'municipal', 'project_municipal', '12公里市政道路升级', '天津滨海', '2024-03', 'true'],
      ['p4', '滨江景观大道', 'municipal', 'project_municipal', '景观带+慢行系统', '江苏南京', '2023-09', 'false'],
      ['p5', '国际酒店精装修', 'decoration', 'project_decoration', '五星酒店全案装饰', '上海浦东', '2024-01', 'true'],
      ['p6', '科技园区办公装修', 'decoration', 'project_decoration', '3万㎡办公空间', '深圳南山', '2023-11', 'false'],
      ['p7', '中央公园景观工程', 'landscape', 'project_landscape', '城市核心生态公园', '浙江杭州', '2023-08', 'true'],
      ['p8', '湿地保护园林项目', 'landscape', 'project_landscape', '生态修复+景观营造', '山东青岛', '2024-02', 'false']
    ]
    for (const row of raw) {
      const p = new ProjectItem()
      p.id = row[0]
      p.title = row[1]
      p.category = row[2]
      p.coverKey = row[3]
      p.summary = row[4]
      p.location = row[5]
      p.completedAt = row[6]
      p.featured = row[7] === 'true'
      p.description = `${row[1]}是筑科建筑承建的代表性工程。项目采用标准化管理体系，` +
        `严格把控安全质量，获得业主及主管部门一致好评。`
      p.galleryKeys = [row[3], row[3], row[3]]
      list.push(p)
    }
    return list
  }

  static newsCoverKey(category: string): string {
    if (category === 'company') return 'news_company'
    if (category === 'industry') return 'news_industry'
    if (category === 'project') return 'news_project'
    if (category === 'notice') return 'news_notice'
    return 'news_company'
  }

  static news(): NewsItem[] {
    const list: NewsItem[] = []
    const raw: string[][] = [
      ['n1', '筑科建筑荣获"年度优质施工企业"', 'company', '2024-05-18'],
      ['n2', 'BIM技术在总部大厦项目成功应用', 'project', '2024-05-10'],
      ['n3', '2024年建筑行业绿色施工趋势解读', 'industry', '2024-04-28'],
      ['n4', '关于2024年端午节放假的通知', 'notice', '2024-04-25'],
      ['n5', '筑科建筑与某高校签署产学研合作', 'company', '2024-04-15'],
      ['n6', '市政快速路项目顺利通过竣工验收', 'project', '2024-04-08'],
      ['n7', '住建部发布工程质量管理新规', 'industry', '2024-03-30'],
      ['n8', '2024年春季校园招聘启动公告', 'notice', '2024-03-20']
    ]
    for (const row of raw) {
      const n = new NewsItem()
      n.id = row[0]
      n.title = row[1]
      n.category = row[2]
      n.publishedAt = row[3]
      n.coverKey = MockData.newsCoverKey(row[2])
      n.summary = `${row[1]}，详情请阅读全文。`
      n.content = `${row[1]}\n\n` +
        '筑科建筑始终坚持质量第一、安全至上的原则，持续推进技术创新与管理升级。' +
        '本次事件/项目/政策对行业发展具有积极意义，公司将密切关注并落实相关要求。'
      list.push(n)
    }
    return list
  }

  static certificates(): CertificateItem[] {
    const list: CertificateItem[] = []
    const raw: string[][] = [
      ['c1', '建筑工程施工总承包壹级', '住建部', '2028-12'],
      ['c2', '市政公用工程施工总承包贰级', '住建部', '2027-06'],
      ['c3', 'ISO 9001 质量管理体系', '中国质量认证中心', '2026-03'],
      ['c4', '安全生产许可证', '北京市住建委', '2025-09']
    ]
    for (const row of raw) {
      const c = new CertificateItem()
      c.id = row[0]
      c.name = row[1]
      c.issuer = row[2]
      c.validUntil = row[3]
      c.coverKey = 'cert_qualification'
      list.push(c)
    }
    return list
  }

  static honors(): HonorItem[] {
    const list: HonorItem[] = []
    const raw: string[][] = [
      ['h1', '北京市优质工程奖', '2023', '北京市建筑业联合会', '筑科总部大厦项目凭借卓越的质量管理与绿色施工标准，荣获北京市优质工程奖。'],
      ['h2', '全国建筑业AAA级信用企业', '2023', '中国建筑业协会', '经行业信用评价，筑科建筑获评全国建筑业AAA级信用企业，体现良好的履约能力与社会信誉。'],
      ['h3', '安全生产标准化示范工地', '2022', '北京市住建委', '星河湾住宅小区项目严格执行安全标准化管理，获评安全生产标准化示范工地。'],
      ['h4', '绿色施工示范工程', '2022', '中国施工企业管理协会', '城市快速路改造项目在节能降耗、扬尘治理等方面表现突出，入选绿色施工示范工程。']
    ]
    for (const row of raw) {
      const h = new HonorItem()
      h.id = row[0]
      h.title = row[1]
      h.year = row[2]
      h.issuer = row[3]
      h.description = row[4]
      h.imageKey = 'honor_trophy'
      list.push(h)
    }
    return list
  }

  static jobs(): JobItem[] {
    const list: JobItem[] = []
    const j1 = new JobItem()
    j1.id = 'j1'
    j1.title = '项目经理'
    j1.department = '工程部'
    j1.location = '北京'
    j1.salary = '15K-25K'
    j1.experience = '5年以上'
    j1.education = '本科及以上'
    j1.publishedAt = '2024-05-01'
    j1.contactPhone = '400-888-6688'
    j1.contactEmail = 'hr@zhuke-arch.com'
    j1.requirements = ['持有一级建造师证书', '有大型房建项目管理经验', '熟悉GB50300系列规范']
    j1.responsibilities = ['全面负责项目施工管理', '协调各参建单位', '确保质量安全进度目标']
    list.push(j1)
    const j2 = new JobItem()
    j2.id = 'j2'
    j2.title = '市政工程师'
    j2.department = '市政事业部'
    j2.location = '天津'
    j2.salary = '12K-18K'
    j2.experience = '3年以上'
    j2.education = '本科及以上'
    j2.publishedAt = '2024-05-01'
    j2.contactPhone = '400-888-6688'
    j2.contactEmail = 'hr@zhuke-arch.com'
    j2.requirements = ['市政相关专业', '熟悉道路管网施工工艺', '能独立编制施工方案']
    j2.responsibilities = ['负责市政项目技术管理', '现场技术指导', '参与方案评审']
    list.push(j2)
    const j3 = new JobItem()
    j3.id = 'j3'
    j3.title = '装饰设计师'
    j3.department = '装饰事业部'
    j3.location = '上海'
    j3.salary = '10K-16K'
    j3.experience = '2年以上'
    j3.education = '大专及以上'
    j3.publishedAt = '2024-04-20'
    j3.contactPhone = '400-888-6688'
    j3.contactEmail = 'hr@zhuke-arch.com'
    j3.requirements = ['熟练使用CAD/3Dmax', '有商业空间设计案例', '审美与沟通能力佳']
    j3.responsibilities = ['方案设计与效果图', '材料选型与成本配合', '施工交底跟进']
    list.push(j3)
    const j4 = new JobItem()
    j4.id = 'j4'
    j4.title = '安全员'
    j4.department = '安监部'
    j4.location = '全国项目'
    j4.salary = '8K-12K'
    j4.experience = '1年以上'
    j4.education = '中专及以上'
    j4.publishedAt = '2024-04-15'
    j4.contactPhone = '400-888-6688'
    j4.contactEmail = 'hr@zhuke-arch.com'
    j4.requirements = ['持有安全员C证', '熟悉施工现场安全管理', '责任心强']
    j4.responsibilities = ['日常安全巡检', '隐患排查与整改跟踪', '安全资料整理']
    list.push(j4)
    return list
  }
}
