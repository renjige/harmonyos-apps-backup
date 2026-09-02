import { CatalogItem } from '../models/MathModels'

export class MathCatalog {
  static modes(): CatalogItem[] {
    const list: CatalogItem[] = []
    list.push(MathCatalog.mode('add', '加法', '把两个数字加在一起', '题目形式如 7 + 8 = ？数字清晰，每题独立作答。', 'cover_add'))
    list.push(MathCatalog.mode('sub', '减法', '算一算还剩多少', '被减数大于或等于减数，避免出现负数困扰。', 'cover_sub'))
    list.push(MathCatalog.mode('mul', '乘法', '几倍是多少', '帮助熟悉整数乘法，不引入分数与小数。', 'cover_mul'))
    list.push(MathCatalog.mode('div', '除法', '平均分成几份', '只出能够整除的题目，降低挫败感。', 'cover_div'))
    list.push(MathCatalog.mode('mix', '混合练习', '加减乘除轮流出题', '适合已经熟悉单一运算后的综合练习。', 'cover_mix'))
    return list
  }

  static challenges(): CatalogItem[] {
    const a = new CatalogItem()
    a.id = 'km_ch_daily'
    a.title = '今日挑战'
    a.subtitle = '10 道计算题'
    a.summary = '每天一组十题，做完即可记录星星。'
    a.body = '从首页点「开始计算」进入。完成后可查看正确数、正确率、用时和星星。不比较排名。'
    a.coverKey = 'hero_desk'
    a.questionCount = 10
    const b = new CatalogItem()
    b.id = 'km_ch_level'
    b.title = '闯关挑战'
    b.subtitle = '每关 10 题'
    b.summary = '轻松闯关，完成后可再来一关。'
    b.body = '关卡之间没有付费解锁。完成一关即可查看星星，也可以随时返回首页。'
    b.coverKey = 'cover_challenge'
    b.questionCount = 10
    return [a, b]
  }

  static medals(): CatalogItem[] {
    const list: CatalogItem[] = []
    list.push(MathCatalog.medal('km_medal_first', '初次挑战', '完成第一次练习', '这是第一枚勋章。它只记录你迈出的第一步。', 'medal_first', 'sessions>=1'))
    list.push(MathCatalog.medal('km_medal_streak7', '连续 7 天', '连续练习一周', '连续七天都完成至少一组练习。中间中断会重新累计。', 'medal_streak', 'streak>=7'))
    list.push(MathCatalog.medal('km_medal_hundred', '百题达人', '累计作答 100 题', '包含每日挑战、练习与闯关中的全部作答题数。', 'medal_hundred', 'answered>=100'))
    list.push(MathCatalog.medal('km_medal_ace', '计算小能手', '正确率达到 90%', '累计至少 30 题且平均正确率达到 90%。', 'medal_ace', 'accuracy>=90'))
    return list
  }

  static tips(): CatalogItem[] {
    const a = new CatalogItem()
    a.id = 'km_tip_pace'
    a.title = '慢慢算也可以'
    a.subtitle = '不赶时间'
    a.summary = '每题都可以想一想再作答。'
    a.body = '答错时会看到正确答案，然后可以再试。练习是为了熟悉计算，不是比赛。'
    a.coverKey = 'hero_paper'
    const b = new CatalogItem()
    b.id = 'km_tip_wrong'
    b.title = '错题小本'
    b.subtitle = '再算一次'
    b.summary = '错过的题目会安静地留在小本里。'
    b.body = '点「再算一次」即可复习。没有批评文案。'
    b.coverKey = 'cover_wrong'
    return [a, b]
  }

  private static mode(op: string, title: string, subtitle: string, body: string, cover: string): CatalogItem {
    const item = new CatalogItem()
    item.id = `km_mode_${op}`
    item.title = title
    item.subtitle = subtitle
    item.summary = subtitle
    item.body = body
    item.coverKey = cover
    item.operator = op
    item.questionCount = 10
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
}
