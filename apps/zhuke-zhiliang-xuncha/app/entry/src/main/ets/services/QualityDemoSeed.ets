import {
  InspectionItem,
  InspectionRecord,
  IssueRecord,
  LocalBundle,
  NoticeItem,
  ProjectItem,
  QualityCatalog,
  QualityDates,
  RectifyRecord,
  UserProfile
} from '../models/QualityModels'

export class QualityDemoSeed {
  static build(): LocalBundle {
    const today = QualityDates.today()
    const bundle = new LocalBundle()
    bundle.profile = new UserProfile()
    bundle.profile.displayName = '林启明'
    bundle.profile.roleTitle = '现场质量员'
    bundle.projects = QualityDemoSeed.projects()
    bundle.inspections = QualityDemoSeed.inspections(today)
    bundle.issues = QualityDemoSeed.issues(today)
    bundle.rectifies = QualityDemoSeed.rectifies(today)
    bundle.notices = QualityDemoSeed.notices()
    return bundle
  }

  static projects(): ProjectItem[] {
    const rows: ProjectItem[] = []
    rows.push(QualityDemoSeed.project('sq_proj_1', '滨江住宅一期', '滨江片区', 'cover_binjiang', '主体已封顶，当前重点为墙面、地面与门窗安装质量。本条为示例数据，可删除。'))
    rows.push(QualityDemoSeed.project('sq_proj_2', '云栖商业中心', '城南商务区', 'cover_yunqi', '装饰与机电安装阶段，适合记录观感与安装偏差。本条为示例数据，可删除。'))
    rows.push(QualityDemoSeed.project('sq_proj_3', '中央广场改造项目', '城市中心', 'cover_plaza', '公共区域与防水工程并行。本条为示例数据，可删除。'))
    return rows
  }

  static inspections(today: string): InspectionRecord[] {
    const rows: InspectionRecord[] = []
    rows.push(QualityDemoSeed.inspect('ins_1', 'sq_proj_1', '滨江住宅一期', '1号楼', '主体结构', today, '已完成', 4, 3, 1))
    rows.push(QualityDemoSeed.inspect('ins_2', 'sq_proj_1', '滨江住宅一期', '地下车库', '防水工程', today, '已完成', 4, 2, 2))
    rows.push(QualityDemoSeed.inspect('ins_3', 'sq_proj_1', '滨江住宅一期', '2号楼', '装饰装修', today, '已完成', 4, 3, 1))
    rows.push(QualityDemoSeed.inspect('ins_4', 'sq_proj_2', '云栖商业中心', '公共区域', '装饰装修', today, '已完成', 4, 3, 1))
    rows.push(QualityDemoSeed.inspect('ins_5', 'sq_proj_2', '云栖商业中心', '1号楼', '机电安装', today, '进行中', 4, 4, 0))
    rows.push(QualityDemoSeed.inspect('ins_6', 'sq_proj_3', '中央广场改造项目', '公共区域', '防水工程', today, '已完成', 4, 3, 1))
    rows.push(QualityDemoSeed.inspect('ins_7', 'sq_proj_3', '中央广场改造项目', '地下车库', '主体结构', today, '已完成', 4, 4, 0))
    rows.push(QualityDemoSeed.inspect('ins_8', 'sq_proj_1', '滨江住宅一期', '公共区域', '安全文明', today, '进行中', 4, 4, 0))
    return rows
  }

  static issues(today: string): IssueRecord[] {
    const rows: IssueRecord[] = []
    rows.push(QualityDemoSeed.issue('iss_1', '卫生间墙面空鼓', 'sq_proj_1', '滨江住宅一期', '1号楼卫生间', '砌体', '重要', '待整改', today, 'cover_wall', '墙面敲击有空鼓，局部粉刷层脱离。'))
    rows.push(QualityDemoSeed.issue('iss_2', '地下车库地面裂缝', 'sq_proj_1', '滨江住宅一期', '地下车库A区', '混凝土', '严重', '整改中', today, 'cover_floor', '地面出现贯通裂缝，需核查厚度与养护。'))
    rows.push(QualityDemoSeed.issue('iss_3', '门窗安装偏差', 'sq_proj_2', '云栖商业中心', '1号楼3层', '装饰', '一般', '待整改', today, 'cover_window', '窗框垂直度偏差超出允许范围。'))
    rows.push(QualityDemoSeed.issue('iss_4', '防水层局部处理不到位', 'sq_proj_3', '中央广场改造项目', '公共卫生间', '防水', '重要', '整改中', today, 'cover_waterproof', '管根与阴阳角防水附加层不足。'))
    rows.push(QualityDemoSeed.issue('iss_5', '吊顶收口不齐', 'sq_proj_2', '云栖商业中心', '公共区域连廊', '装饰', '一般', '待整改', today, 'cover_yunqi', '吊顶收口缝隙不均匀，影响观感。'))
    rows.push(QualityDemoSeed.issue('iss_6', '外墙涂料色差', 'sq_proj_1', '滨江住宅一期', '2号楼东立面', '装饰', '一般', '整改中', `${today.substring(0, 8)}01`, 'cover_binjiang', '相邻分格涂料色差明显。'))
    const closedTitles: string[] = [
      '楼梯间踏步缺损', '栏杆焊接不饱满', '地漏周边渗水', '剪力墙蜂窝麻面',
      '窗台泛水不足', '电缆桥架固定松动', '砌体灰缝不饱满', '屋面找坡不到位',
      '卫生间反坎高度不足', '管道套管未封堵', '地面起砂', '踢脚空鼓'
    ]
    const closedProjects: string[] = [
      'sq_proj_1', 'sq_proj_1', 'sq_proj_1', 'sq_proj_1',
      'sq_proj_2', 'sq_proj_2', 'sq_proj_1', 'sq_proj_3',
      'sq_proj_3', 'sq_proj_2', 'sq_proj_1', 'sq_proj_3'
    ]
    const closedNames: string[] = [
      '滨江住宅一期', '滨江住宅一期', '滨江住宅一期', '滨江住宅一期',
      '云栖商业中心', '云栖商业中心', '滨江住宅一期', '中央广场改造项目',
      '中央广场改造项目', '云栖商业中心', '滨江住宅一期', '中央广场改造项目'
    ]
    for (let i = 0; i < closedTitles.length; i++) {
      const id = `iss_c${i + 1}`
      rows.push(QualityDemoSeed.issue(id, closedTitles[i], closedProjects[i], closedNames[i], '已闭环区域', '其他', '一般', '已完成', `${today.substring(0, 8)}01`, 'cover_plaza', '示例已闭环问题，可删除。'))
    }
    return rows
  }

  static rectifies(today: string): RectifyRecord[] {
    const rows: RectifyRecord[] = []
    rows.push(QualityDemoSeed.rectify('rec_1', 'iss_1', '卫生间墙面空鼓', '发现问题', '发现问题', `${today}T08:20:00`))
    rows.push(QualityDemoSeed.rectify('rec_2', 'iss_2', '地下车库地面裂缝', '发现问题', '发现问题', `${today}T09:10:00`))
    rows.push(QualityDemoSeed.rectify('rec_3', 'iss_2', '地下车库地面裂缝', '开始整改', '开始整改', `${today}T11:30:00`))
    rows.push(QualityDemoSeed.rectify('rec_4', 'iss_4', '防水层局部处理不到位', '发现问题', '发现问题', `${today}T10:00:00`))
    rows.push(QualityDemoSeed.rectify('rec_5', 'iss_4', '防水层局部处理不到位', '开始整改', '开始整改', `${today}T14:20:00`))
    rows.push(QualityDemoSeed.rectify('rec_6', 'iss_6', '外墙涂料色差', '发现问题', '发现问题', `${today.substring(0, 8)}01T16:40:00`))
    rows.push(QualityDemoSeed.rectify('rec_7', 'iss_6', '外墙涂料色差', '开始整改', '开始整改', `${today}T08:00:00`))
    return rows
  }

  static notices(): NoticeItem[] {
    const n1 = new NoticeItem()
    n1.id = 'msg_sq1'
    n1.title = '记录每一次巡查'
    n1.body = '完成检查项后可直接创建质量问题，整改过程会留在时间线中。'
    const n2 = new NoticeItem()
    n2.id = 'msg_sq2'
    n2.title = '示例数据可删除'
    n2.body = '首页项目与示例问题均已标明「示例」，可随时删除后从空白开始。'
    const rows: NoticeItem[] = []
    rows.push(n1)
    rows.push(n2)
    return rows
  }

  private static project(id: string, title: string, location: string, cover: string, body: string): ProjectItem {
    const row = new ProjectItem()
    row.id = id
    row.title = title
    row.location = location
    row.coverKey = cover
    row.summary = '示例项目'
    row.body = body
    row.status = 'active'
    row.isSample = true
    return row
  }

  private static inspect(id: string, projectId: string, projectName: string, area: string, inspectType: string, date: string, status: string, itemCount: number, okCount: number, issueCount: number): InspectionRecord {
    const row = new InspectionRecord()
    row.id = id
    row.title = `${projectName} · ${area}`
    row.projectId = projectId
    row.projectName = projectName
    row.area = area
    row.inspectType = inspectType
    row.inspectDate = date
    row.status = status
    row.itemCount = itemCount
    row.okCount = okCount
    row.issueCount = issueCount
    const titles = QualityCatalog.checklist(inspectType)
    const items: InspectionItem[] = []
    for (let i = 0; i < titles.length; i++) {
      const it = new InspectionItem()
      it.id = `${id}_it_${i}`
      it.title = titles[i]
      it.status = i < issueCount ? 'issue' : 'ok'
      items.push(it)
    }
    row.itemsJson = JSON.stringify(items)
    row.userId = 'local'
    row.isSample = true
    row.createdAt = `${date}T08:00:00`
    row.updatedAt = row.createdAt
    return row
  }

  private static issue(id: string, title: string, projectId: string, projectName: string, location: string, category: string, severity: string, status: string, foundAt: string, cover: string, description: string): IssueRecord {
    const row = new IssueRecord()
    row.id = id
    row.title = title
    row.projectId = projectId
    row.projectName = projectName
    row.location = location
    row.category = category
    row.severity = severity
    row.status = status
    row.foundAt = foundAt.length === 10 ? `${foundAt}T09:00:00` : foundAt
    row.coverKey = cover
    row.photosJson = `["${cover}"]`
    row.description = `${description}（示例数据，可删除）`
    row.requirement = '按规范完成整改后提交整改结果。'
    row.userId = 'local'
    row.isSample = true
    row.createdAt = row.foundAt
    row.updatedAt = row.foundAt
    return row
  }

  private static rectify(id: string, issueId: string, title: string, status: string, note: string, createdAt: string): RectifyRecord {
    const row = new RectifyRecord()
    row.id = id
    row.issueId = issueId
    row.title = title
    row.status = status
    row.note = note
    row.createdAt = createdAt
    row.userId = 'local'
    return row
  }
}
