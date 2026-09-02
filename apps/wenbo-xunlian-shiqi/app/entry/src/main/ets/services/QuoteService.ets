export class QuoteService {
  private static readonly quotes: string[] = [
    '又完成一次训练，趣味值 +1！',
    '汗水不会骗人，今天的你很棒。',
    '小步快跑，成长会在不经意间发生。',
    '训练不枯燥，因为你在拾取进步。',
    '坚持不是天赋，是一次次选择开始。',
    '今天的努力，是明天更轻盈的自己。',
    '别和别人比，和昨天的自己击掌。',
    '动起来的每一分钟，都值得被记录。',
    '趣味训练，认真生活。',
    '再练一次，徽章在向你招手。',
    '训练拾趣：把自律变成小确幸。',
    '呼吸、发力、微笑——三连完成。',
    '你的热力图，正在慢慢变亮。',
    '每一次保存，都是给未来的礼物。',
    '训练大师之路，从这一条记录开始。'
  ]

  static randomQuote(): string {
    const idx = Math.floor(Math.random() * QuoteService.quotes.length)
    return QuoteService.quotes[idx]
  }
}
