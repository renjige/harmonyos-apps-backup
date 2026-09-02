import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 山野准备自检：问卷 → 规则模板报告（无大模型） */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('fit', '你最近的体能更接近哪一档？', [
        DiagnoseOption.of('easy', '能轻松走 2 小时平路'),
        DiagnoseOption.of('mid', '能连续爬 400 米石阶'),
        DiagnoseOption.of('hard', '有高原或长线经验')
      ]),
      DiagnoseQuestion.of('hours', '这次打算走多久？', [
        DiagnoseOption.of('short', '两小时左右'),
        DiagnoseOption.of('half', '半天'),
        DiagnoseOption.of('day', '一整天')
      ]),
      DiagnoseQuestion.of('alt', '你对海拔敏感吗？', [
        DiagnoseOption.of('low', '平原或低山即可'),
        DiagnoseOption.of('mid', '2000 米左右能适应'),
        DiagnoseOption.of('high', '可以尝试 3000 米以上')
      ]),
      DiagnoseQuestion.of('season', '更在意哪一种窗口？', [
        DiagnoseOption.of('clear', '能见度与云海'),
        DiagnoseOption.of('storm', '避开对流与雷雨'),
        DiagnoseOption.of('night', '想看星空')
      ]),
      DiagnoseQuestion.of('interest', '路上最想读懂什么？', [
        DiagnoseOption.of('plant', '植物'),
        DiagnoseOption.of('rock', '地质'),
        DiagnoseOption.of('sky', '星空与地形云')
      ]),
      DiagnoseQuestion.of('gear', '出发前装备准备到哪一步？', [
        DiagnoseOption.of('thin', '运动鞋 + 一瓶水'),
        DiagnoseOption.of('ok', '徒步鞋、分层衣、两升水'),
        DiagnoseOption.of('full', '头灯、硬壳、应急毯都有')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const fit = DiagnoseService.optionId(answers, 'fit')
    const hours = DiagnoseService.optionId(answers, 'hours')
    const alt = DiagnoseService.optionId(answers, 'alt')
    const season = DiagnoseService.optionId(answers, 'season')
    const interest = DiagnoseService.optionId(answers, 'interest')
    const gear = DiagnoseService.optionId(answers, 'gear')
    const routeId = DiagnoseService.matchRoute(fit, hours, alt, interest)
    const name = DiagnoseService.routeName(routeId)
    const report = new DiagnoseReport()
    report.generatedAt = DiagnoseService.nowLabel()
    report.title = '山野准备自检'
    report.summary = `按体能、时长与兴趣，先看「${name}」。这是规则匹配，不是实时路况或带队承诺。`
    report.strength = fit === 'hard' ? '你有长线经验，可以把看点读细，而不是只赶终点。' : '你愿意按难度选线，这比硬闯高级线更稳。'
    report.weakness = gear === 'thin' ? '鞋与饮水偏少，石阶和草甸风会很快放大不适。' : '容易把「看起来不远」当成「爬升不大」。'
    report.opportunity = `打开「${name}」看沿途看点、季节窗口和装备提示，再对照百科。`
    report.threat = season === 'storm' ? '午后对流是折返信号，不要赌再走二十分钟。' : '能见度变差时按原路下降，不抄近路。'
    report.actions = [
      `查看路线「${name}」的看点与装备提示`,
      gear === 'thin' ? '至少换成防滑鞋并带够 1.5L 水再出发' : '按详情里的季节窗口选出发时间',
      interest === 'sky' ? '红光头灯 + 防风层，认星不是导航替代' : '把相关百科条目先读一遍再上路'
    ]
    report.matchCategory = routeId
    report.matchHint = `去看「${name}」。路线为探索参考，不替代景区管制与气象预警。`
    report.scoreLabel = fit === 'easy' ? '建议从初级线开始' : '可以走匹配难度的一条'
    return report
  }

  static matchRoute(fit: string, hours: string, alt: string, interest: string): string {
    if (alt === 'high' && fit === 'hard') {
      return 'tr-siguniang-shuangqiao'
    }
    if (interest === 'rock' && fit !== 'easy') {
      return hours === 'day' ? 'tr-taihang-yixiantian' : 'tr-danxia-cliff'
    }
    if (interest === 'sky') {
      return 'tr-wugong-meadow'
    }
    if (interest === 'plant' && hours === 'short') {
      return 'tr-moganshan-bike'
    }
    if (fit === 'easy' || hours === 'short') {
      return 'tr-zhangjiajie-jinbian'
    }
    if (alt === 'mid') {
      return 'tr-xiling-stone'
    }
    return 'tr-huangshan-yungu'
  }

  static routeName(id: string): string {
    if (id === 'tr-siguniang-shuangqiao') {
      return '四姑娘山双桥沟'
    }
    if (id === 'tr-taihang-yixiantian') {
      return '太行大峡谷一线天'
    }
    if (id === 'tr-danxia-cliff') {
      return '丹霞山赤壁栈道'
    }
    if (id === 'tr-wugong-meadow') {
      return '武功山草甸环线'
    }
    if (id === 'tr-moganshan-bike') {
      return '莫干山竹海骑行'
    }
    if (id === 'tr-zhangjiajie-jinbian') {
      return '张家界金鞭溪'
    }
    if (id === 'tr-xiling-stone') {
      return '西岭雪山石海巡线'
    }
    return '黄山云谷步道'
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
