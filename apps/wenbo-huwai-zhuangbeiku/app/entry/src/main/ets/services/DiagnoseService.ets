import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 出装检视：问卷 → 规则模板。不调用大模型，文案不使用「AI」。 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('kind', '这次出行类型？', [
        DiagnoseOption.of('hike', '徒步走线'),
        DiagnoseOption.of('camp', '过夜露营'),
        DiagnoseOption.of('climb', '技术攀登'),
        DiagnoseOption.of('water', '涉水 / 河谷')
      ]),
      DiagnoseQuestion.of('nights', '是否过夜？', [
        DiagnoseOption.of('day', '当日往返'),
        DiagnoseOption.of('one', '1 夜'),
        DiagnoseOption.of('multi', '2 夜及以上')
      ]),
      DiagnoseQuestion.of('alt', '海拔与温差？', [
        DiagnoseOption.of('low', '低海拔，温差小'),
        DiagnoseOption.of('mid', '中海拔，早晚凉'),
        DiagnoseOption.of('high', '高海拔，温差大')
      ]),
      DiagnoseQuestion.of('load', '目标负重？', [
        DiagnoseOption.of('light', '8kg 以内'),
        DiagnoseOption.of('mid', '8–12kg'),
        DiagnoseOption.of('heavy', '12kg 以上')
      ]),
      DiagnoseQuestion.of('water', '会涉水吗？', [
        DiagnoseOption.of('no', '不涉水'),
        DiagnoseOption.of('yes', '有浅滩或舟渡')
      ]),
      DiagnoseQuestion.of('season', '季节？', [
        DiagnoseOption.of('spring', '春'),
        DiagnoseOption.of('summer', '夏'),
        DiagnoseOption.of('autumn', '秋'),
        DiagnoseOption.of('winter', '冬')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const kind = DiagnoseService.optionId(answers, 'kind')
    const nights = DiagnoseService.optionId(answers, 'nights')
    const alt = DiagnoseService.optionId(answers, 'alt')
    const load = DiagnoseService.optionId(answers, 'load')
    const water = DiagnoseService.optionId(answers, 'water')
    const season = DiagnoseService.optionId(answers, 'season')

    const miss: string[] = []
    if (kind === 'camp' || nights !== 'day') {
      miss.push('露营类（帐 / 睡袋）')
    }
    if (kind === 'hike' || kind === 'camp' || kind === 'climb') {
      miss.push('徒步类（包 / 杖 / 头灯）')
    }
    if (kind === 'climb') {
      miss.push('攀登类（安全带 / 头盔）')
    }
    if (kind === 'water' || water === 'yes') {
      miss.push('水上类（干袋 / 浮力背心）')
    }

    let kg = '8–10 kg'
    if (load === 'light') {
      kg = '6–8 kg'
    } else if (load === 'heavy' || nights === 'multi' || alt === 'high') {
      kg = '10–14 kg'
    }

    const report = new DiagnoseReport()
    report.title = '出装检视报告'
    report.generatedAt = DiagnoseService.nowLabel()
    report.matchCategory = kind.length > 0 ? kind : 'hike'
    report.matchHint = `建议总重区间 ${kg}。打开装备库录入缺件，再对照一条精选路线看就绪度。`
    report.summary =
      `按「${DiagnoseService.labelOf(answers, 'kind')}」、` +
      `「${DiagnoseService.labelOf(answers, 'nights')}」、` +
      `「${DiagnoseService.labelOf(answers, 'alt')}」规则整理。` +
      `这是类别对照，不是实时气象，也不构成户外安全承诺。`
    report.strength = nights === 'day' ? '当日往返可压低过夜件克重。' : '过夜件齐全时舒适度会明显提高。'
    report.weakness = miss.length > 0 ? `优先补齐：${miss.join('、')}。` : '推荐类别已覆盖。'
    report.opportunity = season === 'winter' || alt === 'high' ? '高海拔或冬季请核对睡袋温标与头灯电量。' : '可在图鉴里对照同类规格再录入自己的件。'
    report.threat = water === 'yes' ? '涉水勿只靠湿衣保暖，干袋与浮力件优先。' : '风大梁上先检查地钉与风绳，再考虑换帐。'
    report.actions = [
      '打开装备库，按缺口录入真实克重',
      '选一条精选路线做就绪度对照',
      '回家后给使用过的件加一次使用次数'
    ]
    report.scoreLabel = miss.length >= 3 ? '缺口较多' : (miss.length === 0 ? '类别齐全' : '尚有缺口')
    return report
  }

  private static optionId(answers: DiagnoseAnswer[], qid: string): string {
    for (let a of answers) {
      if (a.questionId === qid) {
        return a.optionId
      }
    }
    return ''
  }

  private static labelOf(answers: DiagnoseAnswer[], qid: string): string {
    for (let a of answers) {
      if (a.questionId === qid) {
        return a.optionLabel
      }
    }
    return '未选'
  }

  private static nowLabel(): string {
    const d = new Date()
    return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
  }
}
