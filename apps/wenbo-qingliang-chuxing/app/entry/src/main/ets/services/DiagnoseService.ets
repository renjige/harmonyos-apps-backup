import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 出行舒适自检：问卷 → 规则模板报告（无大模型） */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('when', '你准备什么时候出门？', [
        DiagnoseOption.of('now', '现在就要走'),
        DiagnoseOption.of('noon', '中午前后'),
        DiagnoseOption.of('dusk', '傍晚再出发')
      ]),
      DiagnoseQuestion.of('mode', '更想用哪种方式？', [
        DiagnoseOption.of('walk', '步行'),
        DiagnoseOption.of('bike', '骑行'),
        DiagnoseOption.of('transit', '公共交通')
      ]),
      DiagnoseQuestion.of('heat', '你对热有多敏感？', [
        DiagnoseOption.of('high', '很容易中暑、怕晒'),
        DiagnoseOption.of('mid', '一般，能走一段'),
        DiagnoseOption.of('low', '还好，主要赶时间')
      ]),
      DiagnoseQuestion.of('cover', '更在意哪一种清凉？', [
        DiagnoseOption.of('shade', '连续树荫'),
        DiagnoseOption.of('indoor', '室内连廊 / 地铁'),
        DiagnoseOption.of('wind', '河风或绿道')
      ]),
      DiagnoseQuestion.of('span', '这段路大概多久？', [
        DiagnoseOption.of('short', '15 分钟内'),
        DiagnoseOption.of('mid', '20–40 分钟'),
        DiagnoseOption.of('long', '将近一小时')
      ]),
      DiagnoseQuestion.of('gear', '你带了什么？', [
        DiagnoseOption.of('none', '几乎空手'),
        DiagnoseOption.of('hat', '有帽或伞'),
        DiagnoseOption.of('water', '有水和防晒')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const when = DiagnoseService.optionId(answers, 'when')
    const mode = DiagnoseService.optionId(answers, 'mode')
    const heat = DiagnoseService.optionId(answers, 'heat')
    const cover = DiagnoseService.optionId(answers, 'cover')
    const span = DiagnoseService.optionId(answers, 'span')
    const gear = DiagnoseService.optionId(answers, 'gear')
    const routeId = DiagnoseService.matchRoute(when, mode, heat, cover, span)
    const name = DiagnoseService.routeName(routeId)
    const report = new DiagnoseReport()
    report.generatedAt = DiagnoseService.nowLabel()
    report.title = '出行舒适自检'
    report.summary = `按你现在的热敏感与出行方式，更适合走「${name}」。这是规则匹配，不是实时路况。`
    report.strength = heat === 'high' ? '你愿意为舒适让路，这会明显降低体感负担。' : '你还能接受短途暴晒，但仍建议走树荫侧。'
    report.weakness = when === 'noon' ? '正午地面辐射最强，最短路往往最晒。' : '若赶时间，容易忽略室内连廊多走的几十米。'
    report.opportunity = `打开「${name}」看树荫率、室内占比和沿途休息点。`
    report.threat = gear === 'none' ? '空手出门时，休息点补水比再赶 200 米更重要。' : '紫外线不会因为骑行风速而降低。'
    report.actions = [
      `查看路线「${name}」的节点与休息点`,
      cover === 'indoor' ? '优先选室内占比高的路线' : '把树荫率当作和时长同等重要的指标',
      when === 'now' && heat === 'high' ? '若事项可移动，推迟到傍晚再出门' : '出发前看一眼首页清凉指数'
    ]
    report.matchCategory = routeId
    report.matchHint = `去看「${name}」。天气为出行参考，不替代气象台预警。`
    report.scoreLabel = heat === 'high' ? '建议走最凉快的一条' : '可以出门，选清凉路线'
    return report
  }

  static matchRoute(when: string, mode: string, heat: string, cover: string, span: string): string {
    if (mode === 'transit' || cover === 'indoor' || (when === 'noon' && heat === 'high')) {
      return 'rt-hz-indoor'
    }
    if (mode === 'bike' || cover === 'wind') {
      return span === 'long' ? 'rt-hz-bike' : 'rt-cd-green'
    }
    if (cover === 'shade' && span === 'long') {
      return 'rt-hz-xixi'
    }
    if (mode === 'walk' && heat === 'high') {
      return 'rt-hz-indoor'
    }
    return 'rt-hz-shade'
  }

  static routeName(id: string): string {
    if (id === 'rt-hz-indoor') {
      return '武林地下连廊'
    }
    if (id === 'rt-hz-bike') {
      return '运河绿道骑行'
    }
    if (id === 'rt-cd-green') {
      return '锦江绿道骑行'
    }
    if (id === 'rt-hz-xixi') {
      return '西溪遮荫步道'
    }
    return '湖滨林荫通勤'
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
    return `${d.getMonth() + 1}月${d.getDate()}日`
  }
}
