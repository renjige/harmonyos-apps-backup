import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 出行自测：问卷 → 规则匹配一座避暑目的地（无大模型） */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('land', '你更想去哪种凉快的地方？', [
        DiagnoseOption.of('mountain', '山水，山上的风'),
        DiagnoseOption.of('sea', '海滨，浪边的风'),
        DiagnoseOption.of('plateau', '高原，昼夜温差'),
        DiagnoseOption.of('forest', '森林，树荫把阳光切开')
      ]),
      DiagnoseQuestion.of('heat', '这个夏天你最受不了？', [
        DiagnoseOption.of('very', '白天超过三十度就难受'),
        DiagnoseOption.of('mid', '闷热比高温更烦'),
        DiagnoseOption.of('ok', '能走，但想找荫')
      ]),
      DiagnoseQuestion.of('energy', '这次出行的力气像？', [
        DiagnoseOption.of('low', '只想慢慢走、坐下来'),
        DiagnoseOption.of('mid', '可以走一段步道'),
        DiagnoseOption.of('high', '愿意早起或爬一点')
      ]),
      DiagnoseQuestion.of('span', '你能给出多久？', [
        DiagnoseOption.of('weekend', '一个周末'),
        DiagnoseOption.of('few', '三四天刚刚好')
      ]),
      DiagnoseQuestion.of('company', '和谁一起？', [
        DiagnoseOption.of('alone', '自己就很好'),
        DiagnoseOption.of('family', '家人或朋友')
      ]),
      DiagnoseQuestion.of('mood', '最想带走的感觉？', [
        DiagnoseOption.of('cloud', '云和雾'),
        DiagnoseOption.of('wind', '持续的风'),
        DiagnoseOption.of('tree', '树荫与水声')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const land = DiagnoseService.optionId(answers, 'land')
    const heat = DiagnoseService.optionId(answers, 'heat')
    const energy = DiagnoseService.optionId(answers, 'energy')
    const span = DiagnoseService.optionId(answers, 'span')
    const company = DiagnoseService.optionId(answers, 'company')
    const mood = DiagnoseService.optionId(answers, 'mood')
    const destId = DiagnoseService.matchDest(land, heat, energy, span, company, mood)
    const name = DiagnoseService.destName(destId)
    const report = new DiagnoseReport()
    report.generatedAt = DiagnoseService.nowLabel()
    report.title = '出行自测'
    report.summary =
      `按你选的地貌与力气，更适合先看「${name}」。结论来自规则匹配，不是实时气温预报。出门请再核对当地气象与交通公告。`
    report.strength = heat === 'very'
      ? '你对高温很敏感，这很好——选海拔或海风，比选网红街更有效。'
      : '你愿意把夏天拆成一段可走的路，而不是硬扛空调房。'
    report.weakness = energy === 'low'
      ? '不要安排陡坡和正午暴晒。把第一站放在树荫或室内馆。'
      : '别把避暑做成打卡清单。凉快来自停下来的时间。'
    report.opportunity = `打开「${name}」看气温区间、海拔、交通与当地吃的。收藏后，旅途结束可以写下游记。`
    report.threat = '盛夏紫外线比体感更强。高原注意昼夜温差，海岛注意风大晒伤，山区夜里记得薄外套。'
    report.actions = [
      `打开目的地「${name}」阅读气温与交通`,
      '把防晒、饮水和薄外套放进包里',
      '回来后在「游记」写下这一天'
    ]
    report.matchCategory = destId
    report.matchHint = `去看「${name}」。先读详情，再决定要不要出发。`
    report.scoreLabel = '适合去凉快的地方'
    return report
  }

  static matchDest(
    land: string,
    heat: string,
    energy: string,
    span: string,
    company: string,
    mood: string
  ): string {
    if (land === 'sea') {
      if (heat === 'very' || mood === 'wind') {
        return 'ced07'
      }
      if (company === 'family') {
        return 'ced09'
      }
      if (span === 'few') {
        return 'ced10'
      }
      return 'ced06'
    }
    if (land === 'plateau') {
      if (heat === 'very') {
        return 'ced13'
      }
      if (energy === 'high') {
        return 'ced12'
      }
      return 'ced11'
    }
    if (land === 'forest') {
      if (energy === 'high') {
        return 'ced17'
      }
      if (mood === 'tree' || span === 'weekend') {
        return 'ced16'
      }
      return 'ced19'
    }
    if (energy === 'high' && heat === 'very') {
      return 'ced01'
    }
    if (span === 'weekend' || company === 'family') {
      return 'ced02'
    }
    if (mood === 'cloud') {
      return 'ced01'
    }
    return 'ced04'
  }

  static destName(id: string): string {
    if (id === 'ced01') { return '庐山云海' }
    if (id === 'ced02') { return '莫干山竹海' }
    if (id === 'ced04') { return '天目山清凉' }
    if (id === 'ced06') { return '青岛崂山海风' }
    if (id === 'ced07') { return '大连棒棰岛' }
    if (id === 'ced09') { return '北戴河林荫' }
    if (id === 'ced10') { return '舟山东极岛' }
    if (id === 'ced11') { return '丽江玉龙雪风' }
    if (id === 'ced12') { return '香格里拉松风' }
    if (id === 'ced13') { return '西宁湟水晚风' }
    if (id === 'ced16') { return '神农架林海' }
    if (id === 'ced17') { return '长白山岳桦' }
    if (id === 'ced19') { return '塞罕坝林场' }
    return '今日避暑地'
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
