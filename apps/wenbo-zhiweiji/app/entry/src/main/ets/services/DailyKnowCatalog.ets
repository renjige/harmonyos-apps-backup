import { DailyKnowItem } from '../models/ZhiweiModels'

export class DailyKnowCatalog {
  static today(): DailyKnowItem {
    const pool = DailyKnowCatalog.all()
    const d = new Date()
    const seed = d.getFullYear() * 10000 + (d.getMonth() + 1) * 100 + d.getDate()
    const len = pool.length
    let idx = seed % len
    if (idx < 0) {
      idx = 0
    }
    let picked = new DailyKnowItem()
    let i = 0
    for (const row of pool) {
      if (i === idx) {
        picked = row
        break
      }
      i += 1
    }
    return picked
  }

  static findById(id: string): DailyKnowItem | null {
    const pool = DailyKnowCatalog.all()
    for (const row of pool) {
      if (row.id === id) {
        return row
      }
    }
    return null
  }

  static all(): DailyKnowItem[] {
    const list: DailyKnowItem[] = []
    list.push(DailyKnowCatalog.make('dk01', '热水比冷水结冰更快？',
      '过冷的热水在特定条件下可能更快结冰，这叫 Mpemba 效应。生活里烧开的水放凉再冰冻，不一定更快，但提醒我们：观察现象时先记下条件，再下结论。',
      'science', 'cover_study'))
    list.push(DailyKnowCatalog.make('dk02', '读书时只划线很少记得住',
      '主动回忆比反复阅读更有效：合上书，用自己的话写出三点，再对照原文。知微集里可把这三点收成一条「学习成长」笔记。',
      'growth', 'banner_insight'))
    list.push(DailyKnowCatalog.make('dk03', '厨房里的小安全',
      '油锅起火不要浇水。应关火、盖上锅盖隔绝氧气。把这一条放进「生活百科」，关键时刻能派上用场。',
      'life_wiki', 'cover_life'))
    list.push(DailyKnowCatalog.make('dk04', '会议纪要的三句话',
      '写清：决定了什么、谁负责、截止日期。比长篇流水账更可执行。可标成「工作技巧 / 常用技巧」。',
      'work_tip', 'cover_work'))
    list.push(DailyKnowCatalog.make('dk05', '故宫为什么是红墙黄瓦',
      '明清宫殿用黄色琉璃瓦象征皇权，红墙来自传统五色与礼仪制度。散步看到古建，随手记一条「历史文化」。',
      'culture', 'empty_ink'))
    list.push(DailyKnowCatalog.make('dk06', '番茄工作法不必死守 25 分钟',
      '核心是「专注一块、短休一次」。25 分钟只是起点，按任务难度改成 15 或 50 都可以，记下适合自己的节奏。',
      'growth', 'banner_insight'))
    list.push(DailyKnowCatalog.make('dk07', '植物向光生长',
      '茎尖的生长素在背光侧积累，细胞伸长更快，植株就弯向光源。阳台观察也可拍一张放进微知识。',
      'science', 'cover_study'))
    list.push(DailyKnowCatalog.make('dk08', '问路先说地名再问路',
      '先报你要去的地点，对方更容易给出路线。把这类沟通技巧收进「兴趣探索」或「工作技巧」。',
      'interest', 'cover_spark'))
    list.push(DailyKnowCatalog.make('dk09', '盐能降低水的冰点',
      '冬日给路面撒盐，是让冰水混合物在更低温度才凝固。生活百科里值得留一条，避免和「化雪原理」搞混。',
      'life_wiki', 'cover_life'))
    list.push(DailyKnowCatalog.make('dk10', '反馈要具体到行为',
      '「这次汇报把结论放在第一页」比「再专业一点」更容易改进。工作笔记可标「已掌握」方便复习。',
      'work_tip', 'cover_work'))
    list.push(DailyKnowCatalog.make('dk11', '丝绸之路不只是一条路',
      '它是多条商路组成的网络，丝绸、香料、技术与信仰沿途互传。读到相关段落，可收入「历史文化」专题。',
      'culture', 'empty_ink'))
    list.push(DailyKnowCatalog.make('dk12', '睡眠前一小时少看强光屏',
      '蓝光会抑制褪黑素。睡前把一条感悟写成短笔记，比刷信息流更利于入睡和记忆巩固。',
      'growth', 'banner_insight'))
    list.push(DailyKnowCatalog.make('dk13', '电梯里为什么有镜子',
      '早期设计为缓解等待焦虑，也便于轮椅使用者确认位置。观察公共设施，可收进「历史文化」。',
      'culture', 'empty_ink'))
    list.push(DailyKnowCatalog.make('dk14', '复利不只属于理财',
      '每天多记一条可复用的微知识，一年就是三百多条检索入口。用专题把同类技巧串起来。',
      'growth', 'banner_insight'))
    list.push(DailyKnowCatalog.make('dk15', '冰箱里的交叉污染',
      '生肉汁液不要滴到即食食品上；砧板生熟分开。生活百科里值得单独留一条。',
      'life_wiki', 'cover_life'))
    list.push(DailyKnowCatalog.make('dk16', '为什么天空是蓝的',
      '瑞利散射让短波长的蓝光更易被大气散射到眼中。科普类笔记可配一张实拍云图。',
      'science', 'cover_study'))
    list.push(DailyKnowCatalog.make('dk17', '写邮件先写结论',
      '商务沟通把「结论 / 需要对方做什么 / 截止时间」放首段。标为工作技巧 / 常用技巧。',
      'work_tip', 'cover_work'))
    list.push(DailyKnowCatalog.make('dk18', '榫卯为什么能稳',
      '木构件凹凸咬合，靠形位约束传力。看展或读建筑史，可收一条「兴趣探索」。',
      'interest', 'cover_spark'))
    list.push(DailyKnowCatalog.make('dk19', '散步时记灵感',
      '短时步行能激活发散思维。手机只用来记关键词，回家再扩写成微知识正文。',
      'interest', 'cover_spark'))
    list.push(DailyKnowCatalog.make('dk20', '遗忘曲线提醒复习',
      '学习后第 1、3、7 天复习效果最好。把待学习条目加入间隔复习队列即可。',
      'growth', 'banner_insight'))
    list.push(DailyKnowCatalog.make('dk21', '地震时室内先躲后跑',
      '就地躲在结实桌下护头，强震过后再向开阔处转移。安全类务必标「生活百科」。',
      'life_wiki', 'cover_life'))
    list.push(DailyKnowCatalog.make('dk22', 'pH 值是什么',
      '表示酸碱性强弱，7 为中性。厨房用小苏打去油污，本质是弱碱中和油脂。可配实验笔记。',
      'science', 'cover_study'))
    list.push(DailyKnowCatalog.make('dk23', '长城不止一条',
      '不同朝代修筑多段墙体，功能从北防游牧到交通驿道。读史时按朝代拆成多条卡片。',
      'culture', 'empty_ink'))
    list.push(DailyKnowCatalog.make('dk24', '清单式待办要加情境',
      '「买电池」不如「周末去超市买电池」。在微知识正文写清何时何地执行。',
      'work_tip', 'cover_work'))
    list.push(DailyKnowCatalog.make('dk25', '教别人是最好的复习',
      '能用自己的话讲明白，才算初步掌握。每日一知读完可写「一句话教给别人」。',
      'growth', 'banner_insight'))
    list.push(DailyKnowCatalog.make('dk26', '相机里的三要素',
      '光圈、快门、ISO 共同决定曝光。摄影兴趣可把参数组合记成技巧卡。',
      'interest', 'cover_spark'))
    list.push(DailyKnowCatalog.make('dk27', '泡茶水温不是越高越好',
      '绿茶约 80℃，红茶可接近沸腾。不同茶叶写进生活百科，避免泡苦。',
      'life_wiki', 'cover_life'))
    list.push(DailyKnowCatalog.make('dk28', 'DNA 双螺旋结构',
      '沃森与克里克模型揭示遗传信息存储方式。科普阅读可拆「是什么 / 为什么重要」。',
      'science', 'cover_study'))
    list.push(DailyKnowCatalog.make('dk29', '会议纪要要发行动项',
      '会后 24 小时内发出：结论、负责人、截止时间。工作场景可标跟进中直到完成。',
      'work_tip', 'cover_work'))
    list.push(DailyKnowCatalog.make('dk30', '博物馆参观三件套',
      '提前查重点展项、带笔记本、出口处写一条今日收获。历史文化类可配现场照片。',
      'culture', 'empty_ink'))
    return list
  }

  private static make(id: string, title: string, body: string, category: string, coverKey: string): DailyKnowItem {
    const row = new DailyKnowItem()
    row.id = id
    row.title = title
    row.body = body
    row.category = category
    row.coverKey = coverKey
    return row
  }
}
