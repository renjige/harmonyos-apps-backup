/** 筑科建筑 — SaaS 内容存储（与 App MockData 对齐，供后台管理与客户端同步） */

export interface BannerRow {
  id: string;
  title: string;
  subtitle: string;
  imageKey: string;
  sortOrder: number;
  enabled: boolean;
}

export interface ProjectRow {
  id: string;
  title: string;
  category: string;
  coverKey: string;
  summary: string;
  location: string;
  completedAt: string;
  description: string;
  featured: boolean;
}

export interface NewsRow {
  id: string;
  title: string;
  category: string;
  summary: string;
  content: string;
  publishedAt: string;
  coverKey: string;
}

export interface CertificateRow {
  id: string;
  name: string;
  issuer: string;
  validUntil: string;
  coverKey: string;
}

export interface HonorRow {
  id: string;
  title: string;
  year: string;
  issuer: string;
  description: string;
  imageKey: string;
}

export interface BusinessRow {
  id: string;
  title: string;
  summary: string;
  icon: string;
  highlights: string[];
}

export interface CompanyRow {
  name: string;
  intro: string;
  culture: string;
  vision: string;
  foundedYear: string;
  employeeCount: string;
  registeredCapital: string;
}

export interface ContactRow {
  address: string;
  phone: string;
  email: string;
  workHours: string;
  imageKey: string;
  latitude: number;
  longitude: number;
}

export interface JobRow {
  id: string;
  title: string;
  department: string;
  location: string;
  salary: string;
  experience: string;
  education: string;
  publishedAt: string;
  contactPhone: string;
  contactEmail: string;
  requirements: string[];
  responsibilities: string[];
}

export interface NotificationRow {
  id: string;
  title: string;
  body: string;
  fullBody: string;
  createdAt: string;
}

export interface GuestMessageRow {
  id: string;
  name: string;
  phone: string;
  content: string;
  type: 'contact' | 'feedback';
  status: 'pending' | 'handled';
  createdAt: string;
}

function newsCoverKey(category: string): string {
  if (category === 'company') return 'news_company';
  if (category === 'industry') return 'news_industry';
  if (category === 'project') return 'news_project';
  if (category === 'notice') return 'news_notice';
  return 'news_company';
}

export class ContentService {
  company: CompanyRow = {
    name: '筑科建筑工程有限公司',
    foundedYear: '2008',
    registeredCapital: '5000万元',
    employeeCount: '680+',
    intro:
      '筑科建筑是一家专注于房建、市政、装饰装修及园林工程的综合性建筑企业。' +
      '公司秉承"筑造精品、科技赋能"的理念，以高标准质量管理和精细化施工著称，' +
      '累计承建各类工程项目200余项，多次荣获省市优质工程奖。',
    culture:
      '诚信 · 专业 · 创新 · 共赢\n' +
      '我们倡导工匠精神，以安全为底线、质量为生命、客户为中心，' +
      '打造有温度、有责任的建筑品牌。',
    vision: '成为区域领先的建筑工程综合服务商，以品质工程助力城市发展。',
  };

  contact: ContactRow = {
    address: '北京市朝阳区建国路88号筑科大厦18层',
    phone: '400-888-6688',
    email: 'contact@zhuke-arch.com',
    workHours: '周一至周五 9:00-18:00',
    imageKey: 'contact_office',
    latitude: 39.9087,
    longitude: 116.4716,
  };

  banners: BannerRow[] = [
    { id: 'b1', title: '筑造城市地标', subtitle: '20年匠心 · 200+精品工程', imageKey: 'banner_landmark', sortOrder: 1, enabled: true },
    { id: 'b2', title: '市政工程专家', subtitle: '道路 · 桥梁 · 管网一体化施工', imageKey: 'banner_municipal', sortOrder: 2, enabled: true },
    { id: 'b3', title: '绿色建造 智慧管理', subtitle: 'BIM应用 · 绿色施工 · 安全零事故', imageKey: 'banner_green', sortOrder: 3, enabled: true },
  ];

  businesses: BusinessRow[] = [
    { id: 'b1', title: '建筑工程', summary: '房建、工业厂房、公共建筑总承包', icon: 'biz', highlights: ['房屋建筑', '结构工程', '机电安装'] },
    { id: 'b2', title: '市政工程', summary: '道路、桥梁、管网、综合管廊', icon: 'biz', highlights: ['市政道路', '给排水', '照明工程'] },
    { id: 'b3', title: '装饰装修', summary: '商业空间、办公、酒店精装修', icon: 'biz', highlights: ['室内装修', '幕墙', '软装配套'] },
    { id: 'b4', title: '工程咨询', summary: '可研、造价、招投标咨询', icon: 'biz', highlights: ['前期策划', '投资估算', '方案优化'] },
    { id: 'b5', title: '工程管理', summary: '全过程项目管理与监理', icon: 'biz', highlights: ['进度管控', '质量安全', '成本控制'] },
  ];

  projects: ProjectRow[] = [
    { id: 'p1', title: '筑科总部大厦', category: 'building', coverKey: 'project_building', summary: '5A甲级写字楼', location: '北京朝阳', completedAt: '2024-06', description: '筑科总部大厦是筑科建筑承建的代表性工程。项目采用标准化管理体系，严格把控安全质量，获得业主及主管部门一致好评。', featured: true },
    { id: 'p2', title: '星河湾住宅小区', category: 'building', coverKey: 'project_building', summary: '32万㎡高品质社区', location: '河北廊坊', completedAt: '2023-12', description: '星河湾住宅小区是筑科建筑承建的代表性工程。项目采用标准化管理体系，严格把控安全质量，获得业主及主管部门一致好评。', featured: true },
    { id: 'p3', title: '城市快速路改造', category: 'municipal', coverKey: 'project_municipal', summary: '12公里市政道路升级', location: '天津滨海', completedAt: '2024-03', description: '城市快速路改造是筑科建筑承建的代表性工程。项目采用标准化管理体系，严格把控安全质量，获得业主及主管部门一致好评。', featured: true },
    { id: 'p4', title: '滨江景观大道', category: 'municipal', coverKey: 'project_municipal', summary: '景观带+慢行系统', location: '江苏南京', completedAt: '2023-09', description: '滨江景观大道是筑科建筑承建的代表性工程。项目采用标准化管理体系，严格把控安全质量，获得业主及主管部门一致好评。', featured: false },
    { id: 'p5', title: '国际酒店精装修', category: 'decoration', coverKey: 'project_decoration', summary: '五星酒店全案装饰', location: '上海浦东', completedAt: '2024-01', description: '国际酒店精装修是筑科建筑承建的代表性工程。项目采用标准化管理体系，严格把控安全质量，获得业主及主管部门一致好评。', featured: true },
    { id: 'p6', title: '科技园区办公装修', category: 'decoration', coverKey: 'project_decoration', summary: '3万㎡办公空间', location: '深圳南山', completedAt: '2023-11', description: '科技园区办公装修是筑科建筑承建的代表性工程。项目采用标准化管理体系，严格把控安全质量，获得业主及主管部门一致好评。', featured: false },
    { id: 'p7', title: '中央公园景观工程', category: 'landscape', coverKey: 'project_landscape', summary: '城市核心生态公园', location: '浙江杭州', completedAt: '2023-08', description: '中央公园景观工程是筑科建筑承建的代表性工程。项目采用标准化管理体系，严格把控安全质量，获得业主及主管部门一致好评。', featured: true },
    { id: 'p8', title: '湿地保护园林项目', category: 'landscape', coverKey: 'project_landscape', summary: '生态修复+景观营造', location: '山东青岛', completedAt: '2024-02', description: '湿地保护园林项目是筑科建筑承建的代表性工程。项目采用标准化管理体系，严格把控安全质量，获得业主及主管部门一致好评。', featured: false },
  ];

  news: NewsRow[] = [
    { id: 'n1', title: '筑科建筑荣获"年度优质施工企业"', category: 'company', summary: '筑科建筑荣获"年度优质施工企业"，详情请阅读全文。', content: '筑科建筑荣获"年度优质施工企业"\n\n筑科建筑始终坚持质量第一、安全至上的原则，持续推进技术创新与管理升级。', publishedAt: '2024-05-18', coverKey: newsCoverKey('company') },
    { id: 'n2', title: 'BIM技术在总部大厦项目成功应用', category: 'project', summary: 'BIM技术在总部大厦项目成功应用，详情请阅读全文。', content: 'BIM技术在总部大厦项目成功应用\n\n筑科建筑始终坚持质量第一、安全至上的原则，持续推进技术创新与管理升级。', publishedAt: '2024-05-10', coverKey: newsCoverKey('project') },
    { id: 'n3', title: '2024年建筑行业绿色施工趋势解读', category: 'industry', summary: '2024年建筑行业绿色施工趋势解读，详情请阅读全文。', content: '2024年建筑行业绿色施工趋势解读\n\n筑科建筑始终坚持质量第一、安全至上的原则，持续推进技术创新与管理升级。', publishedAt: '2024-04-28', coverKey: newsCoverKey('industry') },
    { id: 'n4', title: '关于2024年端午节放假的通知', category: 'notice', summary: '关于2024年端午节放假的通知，详情请阅读全文。', content: '关于2024年端午节放假的通知\n\n筑科建筑始终坚持质量第一、安全至上的原则，持续推进技术创新与管理升级。', publishedAt: '2024-04-25', coverKey: newsCoverKey('notice') },
    { id: 'n5', title: '筑科建筑与某高校签署产学研合作', category: 'company', summary: '筑科建筑与某高校签署产学研合作，详情请阅读全文。', content: '筑科建筑与某高校签署产学研合作\n\n筑科建筑始终坚持质量第一、安全至上的原则，持续推进技术创新与管理升级。', publishedAt: '2024-04-15', coverKey: newsCoverKey('company') },
    { id: 'n6', title: '市政快速路项目顺利通过竣工验收', category: 'project', summary: '市政快速路项目顺利通过竣工验收，详情请阅读全文。', content: '市政快速路项目顺利通过竣工验收\n\n筑科建筑始终坚持质量第一、安全至上的原则，持续推进技术创新与管理升级。', publishedAt: '2024-04-08', coverKey: newsCoverKey('project') },
    { id: 'n7', title: '住建部发布工程质量管理新规', category: 'industry', summary: '住建部发布工程质量管理新规，详情请阅读全文。', content: '住建部发布工程质量管理新规\n\n筑科建筑始终坚持质量第一、安全至上的原则，持续推进技术创新与管理升级。', publishedAt: '2024-03-30', coverKey: newsCoverKey('industry') },
    { id: 'n8', title: '2024年春季校园招聘启动公告', category: 'notice', summary: '2024年春季校园招聘启动公告，详情请阅读全文。', content: '2024年春季校园招聘启动公告\n\n筑科建筑始终坚持质量第一、安全至上的原则，持续推进技术创新与管理升级。', publishedAt: '2024-03-20', coverKey: newsCoverKey('notice') },
  ];

  certificates: CertificateRow[] = [
    { id: 'c1', name: '建筑工程施工总承包壹级', issuer: '住建部', validUntil: '2028-12', coverKey: 'cert_qualification' },
    { id: 'c2', name: '市政公用工程施工总承包贰级', issuer: '住建部', validUntil: '2027-06', coverKey: 'cert_qualification' },
    { id: 'c3', name: 'ISO 9001 质量管理体系', issuer: '中国质量认证中心', validUntil: '2026-03', coverKey: 'cert_qualification' },
    { id: 'c4', name: '安全生产许可证', issuer: '北京市住建委', validUntil: '2025-09', coverKey: 'cert_qualification' },
  ];

  honors: HonorRow[] = [
    { id: 'h1', title: '北京市优质工程奖', year: '2023', issuer: '北京市建筑业联合会', description: '筑科总部大厦项目凭借卓越的质量管理与绿色施工标准，荣获北京市优质工程奖。', imageKey: 'honor_trophy' },
    { id: 'h2', title: '全国建筑业AAA级信用企业', year: '2023', issuer: '中国建筑业协会', description: '经行业信用评价，筑科建筑获评全国建筑业AAA级信用企业，体现良好的履约能力与社会信誉。', imageKey: 'honor_trophy' },
    { id: 'h3', title: '安全生产标准化示范工地', year: '2022', issuer: '北京市住建委', description: '星河湾住宅小区项目严格执行安全标准化管理，获评安全生产标准化示范工地。', imageKey: 'honor_trophy' },
    { id: 'h4', title: '绿色施工示范工程', year: '2022', issuer: '中国施工企业管理协会', description: '城市快速路改造项目在节能降耗、扬尘治理等方面表现突出，入选绿色施工示范工程。', imageKey: 'honor_trophy' },
  ];

  jobs: JobRow[] = [
    { id: 'j1', title: '项目经理', department: '工程部', location: '北京', salary: '15K-25K', experience: '5年以上', education: '本科及以上', publishedAt: '2024-05-01', contactPhone: '400-888-6688', contactEmail: 'hr@zhuke-arch.com', requirements: ['持有一级建造师证书', '有大型房建项目管理经验', '熟悉GB50300系列规范'], responsibilities: ['全面负责项目施工管理', '协调各参建单位', '确保质量安全进度目标'] },
    { id: 'j2', title: '市政工程师', department: '市政事业部', location: '天津', salary: '12K-18K', experience: '3年以上', education: '本科及以上', publishedAt: '2024-05-01', contactPhone: '400-888-6688', contactEmail: 'hr@zhuke-arch.com', requirements: ['市政相关专业', '熟悉道路管网施工工艺', '能独立编制施工方案'], responsibilities: ['负责市政项目技术管理', '现场技术指导', '参与方案评审'] },
    { id: 'j3', title: '装饰设计师', department: '装饰事业部', location: '上海', salary: '10K-16K', experience: '2年以上', education: '大专及以上', publishedAt: '2024-04-20', contactPhone: '400-888-6688', contactEmail: 'hr@zhuke-arch.com', requirements: ['熟练使用CAD/3Dmax', '有商业空间设计案例', '审美与沟通能力佳'], responsibilities: ['方案设计与效果图', '材料选型与成本配合', '施工交底跟进'] },
    { id: 'j4', title: '安全员', department: '安监部', location: '全国项目', salary: '8K-12K', experience: '1年以上', education: '中专及以上', publishedAt: '2024-04-15', contactPhone: '400-888-6688', contactEmail: 'hr@zhuke-arch.com', requirements: ['持有安全员C证', '熟悉施工现场安全管理', '责任心强'], responsibilities: ['日常安全巡检', '隐患排查与整改跟踪', '安全资料整理'] },
  ];

  notifications: NotificationRow[] = [
    { id: 'nt1', title: '欢迎了解筑科建筑', body: '感谢您下载筑科建筑，浏览工程案例与企业资质。', fullBody: '感谢您下载并使用筑科建筑 App。\n\n在这里您可以浏览精品工程案例、了解企业资质与荣誉、查看行业资讯，还可以在线留言咨询与投递简历。登录后可同步收藏内容与浏览记录。\n\n如有任何问题，欢迎通过「联系我们」或「意见反馈」与我们取得联系。', createdAt: '2024-05-20' },
    { id: 'nt2', title: '春季招聘进行中', body: '工程部、市政部多个岗位热招中。', fullBody: '筑科建筑 2024 年春季校园与社会招聘已正式启动。\n\n热招岗位包括：项目经理、市政工程师、装饰设计师、安全员等。\n工作地点覆盖北京、天津、上海及全国在建项目。\n\n请进入「人才招聘」查看岗位详情，或通过 hr@zhuke-arch.com 投递简历。', createdAt: '2024-05-18' },
    { id: 'nt3', title: '新工程案例上线', body: '筑科总部大厦项目已加入精品工程展示。', fullBody: '筑科总部大厦项目现已上线「工程案例」专区。\n\n该项目为 5A 甲级写字楼，采用 BIM 全过程管理与绿色施工技术，已于 2024 年 6 月顺利竣工。欢迎前往案例详情页查看项目介绍与施工亮点。', createdAt: '2024-05-15' },
  ];

  guestMessages: GuestMessageRow[] = [];

  stats() {
    return {
      bannerCount: this.banners.filter((b) => b.enabled).length,
      projectCount: this.projects.length,
      featuredProjectCount: this.projects.filter((p) => p.featured).length,
      newsCount: this.news.length,
      jobCount: this.jobs.length,
      certificateCount: this.certificates.length,
      honorCount: this.honors.length,
      pendingMessages: this.guestMessages.filter((m) => m.status === 'pending').length,
      totalMessages: this.guestMessages.length,
      pageViewsWeek: [820, 960, 1100, 980, 1250, 1180, 1320],
    };
  }
}

export const contentStore = new ContentService();
