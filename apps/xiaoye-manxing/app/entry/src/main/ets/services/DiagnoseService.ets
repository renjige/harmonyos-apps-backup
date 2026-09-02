import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 适合今天：问卷 → 规则匹配一条轻路线（无大模型） */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('when', '你更想在哪一段出门？', [
        DiagnoseOption.of('morning', '清晨，人少一点'),
        DiagnoseOption.of('noon', '午后，树荫刚好'),
        DiagnoseOption.of('dusk', '傍晚，把风等来')
      ]),
      DiagnoseQuestion.of('energy', '今天的力气像？', [
        DiagnoseOption.of('low', '只想慢慢走'),
        DiagnoseOption.of('mid', '可以走一段'),
        DiagnoseOption.of('high', '愿意早起或爬一点')
      ]),
      DiagnoseQuestion.of('scene', '更想看见？', [
        DiagnoseOption.of('nature', '水、树、风'),
        DiagnoseOption.of('city', '巷子、绿道、旧墙')
      ]),
      DiagnoseQuestion.of('span', '你能给出多久？', [
        DiagnoseOption.of('short', '一个多小时'),
        DiagnoseOption.of('half', '半日刚刚好'),
        DiagnoseOption.of('long', '一天或一个周末')
      ]),
      DiagnoseQuestion.of('company', '和谁一起？', [
        DiagnoseOption.of('alone', '自己就很好'),
        DiagnoseOption.of('family', '家人或朋友')
      ]),
      DiagnoseQuestion.of('mood', '此刻想要的感觉？', [
        DiagnoseOption.of('wind', '去吹一阵夏风'),
        DiagnoseOption.of('shade', '先坐进树荫'),
        DiagnoseOption.of('water', '听水或看天色')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const when = DiagnoseService.optionId(answers, 'when')
    const energy = DiagnoseService.optionId(answers, 'energy')
    const scene = DiagnoseService.optionId(answers, 'scene')
    const span = DiagnoseService.optionId(answers, 'span')
    const mood = DiagnoseService.optionId(answers, 'mood')
    const routeId = DiagnoseService.matchRoute(when, energy, scene, span, mood)
    const name = DiagnoseService.routeName(routeId)
    const report = new DiagnoseReport()
    report.generatedAt = DiagnoseService.nowLabel()
    report.title = '适合今天'
    report.summary = `今天不必赶路。按你选的节奏，更适合走「${name}」。`
    report.strength = '你愿意把时间空出来，这已经比很多行程更完整。'
    report.weakness = energy === 'low' ? '今天不要挑战坡度。把终点放在第一张椅子。' : '别把半日走成打卡清单。'
    report.opportunity = `打开「${name}」看节点与准备清单，把水、防晒放进出行清单。`
    report.threat = '夏天的光比想象中更烈。树荫和饮水比距离重要。'
    report.actions = [
      `打开路线「${name}」看节点时间线`,
      '在出行清单里勾选防晒与饮水',
      '走完后写一篇很短的手记'
    ]
    report.matchCategory = routeId
    report.matchHint = `去看「${name}」。不需要导航，按节点慢慢走就好。`
    report.scoreLabel = '适合慢慢出门'
    return report
  }

  static matchRoute(when: string, energy: string, scene: string, span: string, mood: string): string {
    if (span === 'long') {
      return scene === 'city' ? 'swr05' : 'swr12'
    }
    if (energy === 'high' && when === 'morning') {
      return 'swr07'
    }
    if (mood === 'water' && when === 'dusk') {
      return scene === 'city' ? 'swr09' : 'swr02'
    }
    if (mood === 'shade' || span === 'short') {
      return scene === 'city' ? 'swr08' : 'swr10'
    }
    if (scene === 'city') {
      return when === 'dusk' ? 'swr03' : 'swr11'
    }
    if (when === 'dusk') {
      return 'swr06'
    }
    if (when === 'noon') {
      return 'swr04'
    }
    return 'swr01'
  }

  static routeName(id: string): string {
    if (id === 'swr01') { return '夏日溪谷小径' }
    if (id === 'swr02') { return '湖畔晚风' }
    if (id === 'swr03') { return '城市绿道漫行' }
    if (id === 'swr04') { return '林间午后' }
    if (id === 'swr05') { return '古镇慢游' }
    if (id === 'swr06') { return '海边落日' }
    if (id === 'swr07') { return '山野清晨' }
    if (id === 'swr08') { return '公园树影' }
    if (id === 'swr09') { return '河岸散步' }
    if (id === 'swr10') { return '夏日花园' }
    if (id === 'swr11') { return '旧城街巷' }
    if (id === 'swr12') { return '近郊周末' }
    return '今日漫行'
  }

  private static optionId(answers: DiagnoseAnswer[], qid: string): string {
    for (const a of answers) {
      if (a.questionId === qid) {
        return a.optionId
      }
    }
    return ''
  }

  private static nowLabel(): string {
    const d = new Date()
    const mo = d.getMonth() + 1
    const day = d.getDate()
    const moStr = mo < 10 ? `0${mo}` : `${mo}`
    const dayStr = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${moStr}-${dayStr}`
  }
}
