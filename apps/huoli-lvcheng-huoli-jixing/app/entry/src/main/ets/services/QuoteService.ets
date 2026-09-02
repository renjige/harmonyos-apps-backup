export class QuoteService {
  private static readonly quotes: string[] = [
    '每一天都是新的旅程，记录此刻的活力。',
    '小小的坚持，汇聚成可见的成长轨迹。',
    '关注自己的感受，比追逐数据更重要。',
    '活力不是完美，而是真实地面对今天。',
    '你已经比昨天更了解自己了。',
    '休息也是活力的一部分，请温柔对待自己。',
    '三秒记录，一生回顾——此刻值得被记住。',
    '连续打卡的背后，是对生活的温柔承诺。',
    '运动、心情、精力——三维看见完整的你。',
    '回顾不是为了评判，而是为了更好地前行。',
    '今天的活力值，由你主观定义。',
    '保持记录的习惯，就是送给自己最好的礼物。',
    '每一个「一般」的日子，都在悄悄积累能量。',
    '当你回看日历，会发现自己走了很远。',
    '活力纪行，与你同行每一个平凡的日子。'
  ]

  static dailyQuote(): string {
    const d = new Date()
    const seed = d.getFullYear() * 10000 + (d.getMonth() + 1) * 100 + d.getDate()
    const idx = seed % QuoteService.quotes.length
    return QuoteService.quotes[idx]
  }
}
