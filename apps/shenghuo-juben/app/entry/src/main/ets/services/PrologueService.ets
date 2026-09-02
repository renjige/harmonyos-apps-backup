import { DateHelper } from './DateHelper'

export class PrologueService {
  /** 规则模板生成开场白，不使用大模型 */
  static generate(title: string, scene: string, mood: string): string {
    const hour = new Date().getHours()
    let timeHint = '午后'
    if (hour < 6) {
      timeHint = '深夜'
    } else if (hour < 11) {
      timeHint = '清晨'
    } else if (hour < 14) {
      timeHint = '正午'
    } else if (hour < 18) {
      timeHint = '午后'
    } else {
      timeHint = '傍晚'
    }

    const moodLine = PrologueService.moodLine(mood)
    const sceneHint = scene.trim().length > 0 ?
      scene.trim().substring(0, 24) : (title.trim().length > 0 ? title.trim() : '平凡的一天')

    const today = DateHelper.displayDate(DateHelper.todayKey())
    return `第一幕：${timeHint}的序章\n\n${today}，${moodLine}。${sceneHint}——这是属于你生活剧本的开场。`
  }

  private static moodLine(mood: string): string {
    if (mood === '开心') {
      return '笑声在空气里轻轻荡开'
    }
    if (mood === '感动') {
      return '心底泛起一层温热的涟漪'
    }
    if (mood === '思考') {
      return '思绪像幕布后的灯光，慢慢亮起'
    }
    if (mood === '其他') {
      return '日子在细枝末节里继续向前'
    }
    return '世界安静而清晰'
  }
}
