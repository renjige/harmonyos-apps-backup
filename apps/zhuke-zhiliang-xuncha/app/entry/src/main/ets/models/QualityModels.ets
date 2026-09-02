export class ProjectItem {
  id: string = ''
  title: string = ''
  location: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = 'hero_home'
  status: string = 'active'
  isSample: boolean = false
}

export class InspectionItem {
  id: string = ''
  title: string = ''
  status: string = 'ok'
}

export class InspectionRecord {
  id: string = ''
  title: string = ''
  projectId: string = ''
  projectName: string = ''
  area: string = ''
  inspectType: string = '主体结构'
  inspectDate: string = ''
  remark: string = ''
  status: string = '进行中'
  itemsJson: string = '[]'
  itemCount: number = 0
  okCount: number = 0
  issueCount: number = 0
  userId: string = ''
  isSample: boolean = false
  createdAt: string = ''
  updatedAt: string = ''
}

export class IssueRecord {
  id: string = ''
  title: string = ''
  projectId: string = ''
  projectName: string = ''
  location: string = ''
  category: string = '其他'
  severity: string = '一般'
  description: string = ''
  requirement: string = ''
  photosJson: string = '[]'
  coverKey: string = 'cover_wall'
  status: string = '待整改'
  inspectionId: string = ''
  foundAt: string = ''
  userId: string = ''
  isSample: boolean = false
  createdAt: string = ''
  updatedAt: string = ''
}

export class RectifyRecord {
  id: string = ''
  issueId: string = ''
  title: string = ''
  note: string = ''
  status: string = '发现问题'
  photosJson: string = '[]'
  createdAt: string = ''
  userId: string = ''
}

export class NoticeItem {
  id: string = ''
  title: string = ''
  body: string = ''
  read: boolean = false
}

export class UserProfile {
  displayName: string = '现场质量员'
  roleTitle: string = '质量巡查'
}

export class ListPayload<T> {
  list: T[] = []
  items: T[] = []
}

export class LocalBundle {
  projects: ProjectItem[] = []
  inspections: InspectionRecord[] = []
  issues: IssueRecord[] = []
  rectifies: RectifyRecord[] = []
  notices: NoticeItem[] = []
  profile: UserProfile = new UserProfile()
}

export class QualityStats {
  todayInspect: number = 0
  foundToday: number = 0
  rectifying: number = 0
  closed: number = 0
  monthInspect: number = 0
  monthFound: number = 0
  monthClosed: number = 0
}

export class QualityDates {
  static pad(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  static today(): string {
    const d = new Date()
    return `${d.getFullYear()}-${QualityDates.pad(d.getMonth() + 1)}-${QualityDates.pad(d.getDate())}`
  }

  static display(isoOrYmd: string): string {
    if (isoOrYmd.length >= 10) {
      const y = isoOrYmd.substring(0, 4)
      const m = isoOrYmd.substring(5, 7)
      const d = isoOrYmd.substring(8, 10)
      return `${m}月${d}日`
    }
    return isoOrYmd
  }

  static displayTime(iso: string): string {
    if (iso.length === 0) {
      return ''
    }
    if (iso.endsWith('Z') || iso.indexOf('+') >= 10) {
      const d = new Date(iso)
      if (!isNaN(d.getTime())) {
        return `${QualityDates.pad(d.getMonth() + 1)}月${QualityDates.pad(d.getDate())}日 ${QualityDates.pad(d.getHours())}:${QualityDates.pad(d.getMinutes())}`
      }
    }
    if (iso.length >= 16) {
      return `${QualityDates.display(iso)} ${iso.substring(11, 16)}`
    }
    return QualityDates.display(iso)
  }

  static monthPrefix(): string {
    const d = new Date()
    return `${d.getFullYear()}-${QualityDates.pad(d.getMonth() + 1)}`
  }
}

export class QualityCatalog {
  static areas(): string[] {
    return ['地下车库', '1号楼', '2号楼', '公共区域']
  }

  static types(): string[] {
    return ['主体结构', '装饰装修', '防水工程', '机电安装', '安全文明', '其他']
  }

  static categories(): string[] {
    return ['混凝土', '砌体', '防水', '装饰', '安装', '其他']
  }

  static severities(): string[] {
    return ['一般', '重要', '严重']
  }

  static issueFilters(): string[] {
    return ['全部', '待整改', '整改中', '已完成']
  }

  static inspectStatuses(): string[] {
    return ['待完成', '进行中', '已完成']
  }

  static checklist(inspectType: string): string[] {
    if (inspectType === '装饰装修') {
      return ['墙面质量', '地面平整度', '门窗安装', '吊顶观感']
    }
    if (inspectType === '防水工程') {
      return ['防水施工', '节点密封', '蓄水试验', '管根处理']
    }
    if (inspectType === '机电安装') {
      return ['管线固定', '设备安装', '接地保护', '标识完整']
    }
    if (inspectType === '安全文明') {
      return ['材料堆放', '通道整洁', '成品保护', '作业面清理']
    }
    if (inspectType === '其他') {
      return ['观感质量', '成品保护', '尺寸偏差', '其他问题']
    }
    return ['墙面质量', '混凝土表观', '结构尺寸', '钢筋保护层']
  }

  static coverForCategory(category: string): string {
    if (category === '混凝土' || category === '砌体') {
      return 'cover_wall'
    }
    if (category === '防水') {
      return 'cover_waterproof'
    }
    if (category === '装饰') {
      return 'cover_window'
    }
    if (category === '安装') {
      return 'cover_yunqi'
    }
    return 'cover_floor'
  }
}

export class CreateInspectBody {
  title: string = ''
  projectId: string = ''
  projectName: string = ''
  area: string = ''
  inspectType: string = ''
  inspectDate: string = ''
  remark: string = ''
  itemsJson: string = '[]'
  status: string = '进行中'
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"projectId":${JSON.stringify(this.projectId)},"projectName":${JSON.stringify(this.projectName)},"area":${JSON.stringify(this.area)},"inspectType":${JSON.stringify(this.inspectType)},"inspectDate":${JSON.stringify(this.inspectDate)},"remark":${JSON.stringify(this.remark)},"itemsJson":${JSON.stringify(this.itemsJson)},"status":${JSON.stringify(this.status)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateIssueBody {
  title: string = ''
  projectId: string = ''
  projectName: string = ''
  location: string = ''
  category: string = ''
  severity: string = ''
  description: string = ''
  requirement: string = ''
  photosJson: string = '[]'
  inspectionId: string = ''
  coverKey: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"projectId":${JSON.stringify(this.projectId)},"projectName":${JSON.stringify(this.projectName)},"location":${JSON.stringify(this.location)},"category":${JSON.stringify(this.category)},"severity":${JSON.stringify(this.severity)},"description":${JSON.stringify(this.description)},"requirement":${JSON.stringify(this.requirement)},"photosJson":${JSON.stringify(this.photosJson)},"inspectionId":${JSON.stringify(this.inspectionId)},"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class RectifyBody {
  note: string = ''
  photosJson: string = '[]'
  status: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"note":${JSON.stringify(this.note)},"photosJson":${JSON.stringify(this.photosJson)},"status":${JSON.stringify(this.status)},"userId":${JSON.stringify(this.userId)}}`
  }
}
