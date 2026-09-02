import { DateHelper } from './DateHelper'

export class DailyChallenge {
  title: string = ''
  prompt: string = ''
  kind: string = 'thought'
}

export class MorningCardService {
  static todayChallenge(): DailyChallenge {
    const day = new Date().getDate()
    const pool: string[][] = [
      ['捕捉一种光线', '留意窗边的阴影或反射，拍一张或写一句描述。', 'environment'],
      ['记录一种声音', '闭上眼 10 秒，写下你听到的最清晰的一种声音。', 'scene'],
      ['命名此刻心情', '用一个词形容现在，并补充为什么。', 'mood'],
      ['观察手边一物', '选桌上最近的一件物品，写它的颜色、材质与联想。', 'thought'],
      ['记录一种气味', '描述空气里的味道，它来自哪里？', 'environment'],
      ['定格一个场景', '用一句话定格你现在所在的空间。', 'scene'],
      ['写下闪念', '把刚刚掠过脑海的一句话原样记下。', 'thought']
    ]
    const row = pool[day % pool.length]
    const c = new DailyChallenge()
    c.title = row[0]
    c.prompt = row[1]
    c.kind = row[2]
    return c
  }

  static build(todayCount: number, weekCount: number): MorningCardServiceResult {
    const hour = new Date().getHours()
    const r = new MorningCardServiceResult()
    if (hour < 11) {
      r.greeting = '早安，观物者'
    } else if (hour < 18) {
      r.greeting = '午后好，观物者'
    } else {
      r.greeting = '晚上好，观物者'
    }
    if (todayCount === 0) {
      r.suggestion = '今天还没有观察记录，试试完成下方「今日挑战」。'
    } else if (weekCount < 3) {
      r.suggestion = `今日已记录 ${todayCount} 条，本周 ${weekCount} 条，再坚持几天洞察会更清晰。`
    } else {
      r.suggestion = `本周已有 ${weekCount} 条观察，保持节奏，智慧分析会更有参考价值。`
    }
    return r
  }
}

export class MorningCardServiceResult {
  greeting: string = ''
  suggestion: string = ''
}
