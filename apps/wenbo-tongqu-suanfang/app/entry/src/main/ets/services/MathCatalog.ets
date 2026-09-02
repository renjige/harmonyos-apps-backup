import { CatalogItem, TableRowItem } from '../models/MathModels'

export class MathCatalog {
  static modes(): CatalogItem[] {
    const list: CatalogItem[] = []
    list.push(MathCatalog.mode('add', '加法', '把两个数字加在一起', '题目形式如 7 + 8 = ？数字清晰，每题独立作答。', 'cover_add', 'basic', 1))
    list.push(MathCatalog.mode('sub', '减法', '算一算还剩多少', '被减数大于或等于减数，避免出现负数困扰。', 'cover_sub', 'basic', 2))
    list.push(MathCatalog.mode('mul', '乘法', '几倍是多少', '帮助熟悉整数乘法，不引入分数与小数。', 'cover_mul', 'basic', 3))
    list.push(MathCatalog.mode('div', '除法', '平均分成几份', '只出能够整除的题目，降低挫败感。', 'cover_div', 'basic', 4))
    list.push(MathCatalog.mode('mix', '混合练习', '加减乘除轮流出题', '适合已经熟悉单一运算后的综合练习。', 'cover_mix', 'basic', 5))
    list.push(MathCatalog.mode('make10', '凑十练习', '凑成 10 的小搭档', '例如 3 + 7、6 + 4，帮助建立数感。', 'cover_add', 'skill', 6))
    list.push(MathCatalog.mode('blank', '填空练习', '找出缺少的数', '例如 ? + 7 = 15，训练逆向思考。', 'cover_sub', 'skill', 7))
    list.push(MathCatalog.mode('chain', '连加练习', '三个数连加', '例如 2 + 3 + 4 = ？，培养连续运算能力。', 'cover_mix', 'skill', 8))
    list.push(MathCatalog.mode('add2', '两位数加法', '更大的加法', '十位与个位组合，难度随设置变化。', 'cover_add', 'advance', 9))
    list.push(MathCatalog.mode('sub2', '两位数减法', '更大的减法', '结果始终为非负整数，循序渐进。', 'cover_sub', 'advance', 10))
    list.push(MathCatalog.mode('table_mul', '乘法口诀', '表内乘法', '1～9 或 1～12 的乘法口算，按难度调整。', 'cover_mul', 'advance', 11))
    list.push(MathCatalog.mode('table_div', '除法口诀', '表内整除', '由乘法口诀反推，巩固乘除关系。', 'cover_div', 'advance', 12))
    list.push(MathCatalog.mode('mix_adv', '综合进阶', '多题型混合', '凑十、填空、连加与四则运算穿插出现。', 'cover_mix', 'advance', 13))
    list.push(MathCatalog.mode('compare', '比大小', '选出大于、等于或小于', '观察两个数，点选它们的关系。', 'cover_sub', 'sense', 14))
    list.push(MathCatalog.mode('compose', '分与合', '一个数可以分成几和几', '例如 10 可以分成 3 和 7。', 'cover_add', 'sense', 15))
    list.push(MathCatalog.mode('sequence', '找规律', '填出下一个数', '例如 2，4，6，？', 'cover_mix', 'sense', 16))
    list.push(MathCatalog.mode('odd_even', '单双数', '分辨单数和双数', '用选择作答，建立奇偶数感。', 'cover_div', 'sense', 17))
    list.push(MathCatalog.mode('place', '数位认识', '十位和个位', '看一个两位数，说出十位或个位。', 'cover_mul', 'sense', 18))
    list.push(MathCatalog.mode('story', '应用题', '读一小段再列式', '糖、苹果、铅笔等生活情境，先读题再计算。', 'hero_paper', 'life', 19))
    list.push(MathCatalog.mode('choice', '选择题', '三个选项选一个', '适合想换一种作答方式的时候。', 'cover_challenge', 'life', 20))
    list.push(MathCatalog.mode('judge', '判断题', '这个算式对不对', '看算式是否成立，点「是这样」或「再想想」。', 'cover_wrong', 'life', 21))
    list.push(MathCatalog.mode('sort', '数字排序', '从小到大找中间的数', '给出三个数字，选出从小到大排在中间的那个。', 'cover_mix', 'game', 25))
    list.push(MathCatalog.mode('shape', '图形认知', '数一数有几条边', '三角形、正方形、五边形，认识基本图形。', 'cover_challenge', 'game', 26))
    list.push(MathCatalog.mode('link', '数字连线', '接着往后数', '看到前面两个数，选出后面该接上的数。', 'hero_paper', 'game', 27))
    list.push(MathCatalog.mode('game', '趣味数学', '排序、图形、连线混合', '把几种轻量游戏题串在一起练。', 'cover_mix', 'game', 28))
    list.push(MathCatalog.mode('age35', '幼儿启蒙 3-5 岁', '分与合、单双数、图形', '数字小、选项清楚，适合刚接触数的孩子。', 'hero_desk', 'age', 29))
    list.push(MathCatalog.mode('age68', '基础计算 6-8 岁', '加减、凑十、应用题', '对应小学低年级常见口算。', 'cover_add', 'age', 30))
    list.push(MathCatalog.mode('age912', '思维提升 9-12 岁', '口诀、数位、两位数', '乘除与更大数字，可随时改回更轻松的阶段。', 'cover_mul', 'age', 31))
    return list
  }

  static challenges(): CatalogItem[] {
    const list: CatalogItem[] = []
    list.push(MathCatalog.challenge('km_ch_daily', '今日挑战', '按设置题量完成', '每天一组题目，做完即可记录星星。', 'hero_desk', 1, 10))
    list.push(MathCatalog.challenge('km_ch_cog', '闯关 · 数字认知', '单双数、比大小、图形', '完成这一关，解锁加减关卡。', 'cover_mix', 2, 8))
    list.push(MathCatalog.challenge('km_ch_add', '闯关 · 加减运算', '加法、减法、凑十', '完成这一关，解锁乘除关卡。', 'cover_add', 3, 10))
    list.push(MathCatalog.challenge('km_ch_mul', '闯关 · 乘除练习', '表内乘除', '完成这一关，解锁应用题关卡。', 'cover_mul', 4, 10))
    list.push(MathCatalog.challenge('km_ch_life', '闯关 · 趣味应用题', '生活情境 8 题', '四条主线通关后点亮这枚进阶。', 'hero_paper', 5, 8))
    list.push(MathCatalog.challenge('km_ch_level2', '闯关 · 凑十填空', '凑十与填空', '在基础运算上加入凑十、填空题型。', 'cover_add', 6, 10))
    list.push(MathCatalog.challenge('km_ch_level3', '闯关 · 两位数口诀', '两位数与口诀', '两位数加减与表内乘除，适合进阶。', 'cover_mul', 7, 10))
    list.push(MathCatalog.challenge('km_ch_speed', '速算小试', '连续 15 题', '题量略多，保持专注完成即可。', 'hero_paper', 8, 15))
    list.push(MathCatalog.challenge('km_ch_timed', '专注挑战', '90 秒内完成 10 题', '有倒计时。时间到了会温和进入下一题，没有批评。', 'cover_challenge', 9, 10))
    list.push(MathCatalog.challenge('km_ch_story', '应用题闯关', '生活情境 8 题', '读短句、列算式、算出得数。', 'hero_paper', 10, 8))
    list.push(MathCatalog.challenge('km_ch_sense', '数感闯关', '比大小与规律', '把数感题型串成一关。', 'cover_mix', 11, 10))
    return list
  }

  static medals(): CatalogItem[] {
    const list: CatalogItem[] = []
    list.push(MathCatalog.medal('km_medal_first', '初次挑战', '完成第一次练习', '这是第一枚勋章。它只记录你迈出的第一步。', 'medal_star', 'sessions>=1'))
    list.push(MathCatalog.medal('km_medal_streak7', '连续 7 天', '连续练习一周', '连续七天都完成至少一组练习。中间中断会重新累计。', 'medal_streak', 'streak>=7'))
    list.push(MathCatalog.medal('km_medal_fifty', '五十题达人', '累计作答 50 题', '坚持练习的一半里程碑。', 'medal_hundred', 'answered>=50'))
    list.push(MathCatalog.medal('km_medal_hundred', '百题达人', '累计作答 100 题', '包含每日挑战、练习与闯关中的全部作答题数。', 'medal_hundred', 'answered>=100'))
    list.push(MathCatalog.medal('km_medal_ace', '计算小能手', '正确率达到 90%', '累计至少 30 题且平均正确率达到 90%。', 'medal_ace', 'accuracy>=90'))
    list.push(MathCatalog.medal('km_medal_perfect', '一次全对', '单组练习全对', '任意一组练习全部答对即可点亮。', 'medal_star', 'perfect>=1'))
    list.push(MathCatalog.medal('km_medal_story', '读题小能手', '完成应用题练习', '完成一组应用题即可点亮。', 'medal_ace', 'story>=1'))
    list.push(MathCatalog.medal('km_medal_plan', '七日同行', '开启七日计划并练满 5 天', '计划提醒坚持，不比较别人。', 'medal_streak', 'plan>=5'))
    list.push(MathCatalog.medal('km_medal_tower', '闯关小勇士', '打通数字认知关', '完成「数字认知」闯关即可点亮。', 'medal_star', 'tower>=1'))
    list.push(MathCatalog.medal('km_medal_custom', '家长出题', '写下第一份题单', '家长出题并保存一份题单即可点亮。', 'medal_ace', 'custom>=1'))
    list.push(MathCatalog.medal('km_medal_fav10', '收藏达人', '收藏 10 题', '答题时收藏满 10 题。', 'medal_hundred', 'fav>=10'))
    list.push(MathCatalog.medal('km_medal_checkin7', '打卡一周', '累计打卡 7 天', '完成练习会自动记下一天。', 'medal_streak', 'checkin>=7'))
    list.push(MathCatalog.medal('km_medal_streak30', '坚持一月', '连续练习 30 天', '连续三十天都完成至少一组练习。', 'medal_streak', 'streak>=30'))
    return list
  }

  static tips(): CatalogItem[] {
    const list: CatalogItem[] = []
    list.push(MathCatalog.tip('km_tip_pace', '慢慢算也可以', '不赶时间', '每题都可以想一想再作答。答错时会看到正确答案，然后可以再试。', 'hero_paper'))
    list.push(MathCatalog.tip('km_tip_wrong', '错题小本', '再算一次', '错过的题目会安静地留在小本里。点「再算一次」即可复习。', 'cover_wrong'))
    list.push(MathCatalog.tip('km_tip_make10', '凑十小技巧', '先凑整再算', '看到 8 + 5，可以先想 8 + 2 = 10，再加 3。', 'cover_add'))
    list.push(MathCatalog.tip('km_tip_story', '应用题怎么读', '先找已知，再问什么', '看到「一共」「还剩」「平均」，先想用加、减还是除。', 'hero_paper'))
    list.push(MathCatalog.tip('km_tip_odd', '单数和双数', '隔一个数跳一跳', '1、3、5 是单数；2、4、6 是双数。看个位就能判断。', 'cover_div'))
    list.push(MathCatalog.tip('km_tip_shape', '先数边再认形', '三角形 3 条边', '正方形 4 条边一样长。数边是认识图形的第一步。', 'cover_challenge'))
    list.push(MathCatalog.tip('km_tip_sort', '从小到大排队', '先找最小，再找最大', '剩下的就是中间的数。排序能帮助比较大小。', 'cover_mix'))
    list.push(MathCatalog.tip('km_tip_age', '按年龄选路径', '3-5 / 6-8 / 9-12', '在设置里切换年龄阶段，今日挑战会跟着换成合适的题。', 'hero_desk'))
    list.push(MathCatalog.tip('km_tip_parent', '给家长', '一起看成长与周报', '成长页可以看日历、周报和需要加强的题型。不排名，不承诺成绩。', 'texture_wood'))
    list.push(MathCatalog.tip('km_tip_table', '九九口诀怎么记', '先读表，再专练一行', '打开口诀表，点「7 的口诀」只练这一行。乘法和除法可以对着看。', 'cover_mul'))
    return list
  }

  static planDayMode(dayIndex: number): string {
    if (dayIndex === 1) {
      return 'sub'
    }
    if (dayIndex === 2) {
      return 'compare'
    }
    if (dayIndex === 3) {
      return 'make10'
    }
    if (dayIndex === 4) {
      return 'story'
    }
    if (dayIndex === 5) {
      return 'sequence'
    }
    if (dayIndex === 6) {
      return 'mix'
    }
    return 'add'
  }

  static planDayTitle(dayIndex: number): string {
    if (dayIndex === 1) {
      return '第二天 · 减法'
    }
    if (dayIndex === 2) {
      return '第三天 · 比大小'
    }
    if (dayIndex === 3) {
      return '第四天 · 凑十'
    }
    if (dayIndex === 4) {
      return '第五天 · 应用题'
    }
    if (dayIndex === 5) {
      return '第六天 · 找规律'
    }
    if (dayIndex === 6) {
      return '第七天 · 混合'
    }
    return '第一天 · 加法热身'
  }

  static tableRows(): TableRowItem[] {
    const out: TableRowItem[] = []
    for (let n = 1; n <= 9; n++) {
      const row = new TableRowItem()
      row.n = n
      row.id = `tr_${n}`
      row.title = `${n} 的口诀`
      row.preview = `${n}×1=${n}  ${n}×2=${n * 2}  ${n}×3=${n * 3} … ${n}×9=${n * 9}`
      out.push(row)
    }
    return out
  }

  static searchItems(keyword: string): CatalogItem[] {
    const key = keyword.trim()
    const all: CatalogItem[] = []
    for (const m of MathCatalog.modes()) {
      all.push(m)
    }
    for (const t of MathCatalog.tips()) {
      all.push(t)
    }
    for (const c of MathCatalog.challenges()) {
      all.push(c)
    }
    if (key.length === 0) {
      return all
    }
    const out: CatalogItem[] = []
    for (const item of all) {
      if (item.title.indexOf(key) >= 0 || item.subtitle.indexOf(key) >= 0 || item.body.indexOf(key) >= 0) {
        out.push(item)
      }
    }
    return out
  }

  static towerNeed(id: string): number {
    if (id === 'km_ch_cog') {
      return 0
    }
    if (id === 'km_ch_add') {
      return 1
    }
    if (id === 'km_ch_mul') {
      return 2
    }
    if (id === 'km_ch_life') {
      return 3
    }
    return 0
  }

  static towerGain(id: string): number {
    if (id === 'km_ch_cog') {
      return 1
    }
    if (id === 'km_ch_add') {
      return 2
    }
    if (id === 'km_ch_mul') {
      return 3
    }
    if (id === 'km_ch_life') {
      return 4
    }
    return 0
  }

  static modeTitle(op: string): string {
    const list = MathCatalog.modes()
    for (const item of list) {
      if (item.operator === op) {
        return item.title
      }
    }
    return '练习'
  }

  private static mode(op: string, title: string, subtitle: string, body: string, cover: string, section: string, order: number): CatalogItem {
    const item = new CatalogItem()
    item.id = `km_mode_${op}`
    item.title = title
    item.subtitle = subtitle
    item.summary = subtitle
    item.body = body
    item.coverKey = cover
    item.operator = op
    item.questionCount = 10
    item.rule = section
    item.sortOrder = order
    return item
  }

  private static challenge(id: string, title: string, subtitle: string, body: string, cover: string, order: number, count: number): CatalogItem {
    const item = new CatalogItem()
    item.id = id
    item.title = title
    item.subtitle = subtitle
    item.summary = subtitle
    item.body = body
    item.coverKey = cover
    item.questionCount = count
    item.sortOrder = order
    return item
  }

  private static medal(id: string, title: string, summary: string, body: string, cover: string, rule: string): CatalogItem {
    const item = new CatalogItem()
    item.id = id
    item.title = title
    item.subtitle = summary
    item.summary = summary
    item.body = body
    item.coverKey = cover
    item.rule = rule
    return item
  }

  private static tip(id: string, title: string, subtitle: string, body: string, cover: string): CatalogItem {
    const item = new CatalogItem()
    item.id = id
    item.title = title
    item.subtitle = subtitle
    item.summary = subtitle
    item.body = body
    item.coverKey = cover
    return item
  }
}
