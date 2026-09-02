import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 智慧清单：问卷 → 规则匹配装备模板（cpt01 新手 / cpt02 轻量化 / cpt03 家庭）。
 * 纯规则引擎，不调用大模型，文案不使用「AI」。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('days', '这次打算过几夜？', [
        DiagnoseOption.of('d1', '当晚往返 / 1 夜'),
        DiagnoseOption.of('d2', '2–3 夜'),
        DiagnoseOption.of('d4', '4 夜及以上')
      ]),
      DiagnoseQuestion.of('season', '出发季节？', [
        DiagnoseOption.of('spring', '春（多露、昼夜温差）'),
        DiagnoseOption.of('summer', '夏（蚊虫、暴雨对流）'),
        DiagnoseOption.of('autumn', '秋（干爽、早晚凉）'),
        DiagnoseOption.of('winter', '冬（保暖与冷凝）')
      ]),
      DiagnoseQuestion.of('people', '同行人数？', [
        DiagnoseOption.of('solo', '独自'),
        DiagnoseOption.of('duo', '两人'),
        DiagnoseOption.of('family', '三人及以上')
      ]),
      DiagnoseQuestion.of('camp', '营地类型？', [
        DiagnoseOption.of('park', '公园营地（水电淋浴）'),
        DiagnoseOption.of('rv', '房车营地'),
        DiagnoseOption.of('wild', '野营 / 无设施')
      ]),
      DiagnoseQuestion.of('kids', '有儿童同行吗？', [
        DiagnoseOption.of('no', '没有'),
        DiagnoseOption.of('yes', '有儿童')
      ]),
      DiagnoseQuestion.of('alt', '海拔与地形？', [
        DiagnoseOption.of('low', '平原 / 低海拔'),
        DiagnoseOption.of('high', '高原 / 高海拔营地')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const days = DiagnoseService.optionId(answers, 'days')
    const season = DiagnoseService.optionId(answers, 'season')
    const people = DiagnoseService.optionId(answers, 'people')
    const camp = DiagnoseService.optionId(answers, 'camp')
    const kids = DiagnoseService.optionId(answers, 'kids')
    const alt = DiagnoseService.optionId(answers, 'alt')

    let tpl = 'cpt01'
    let tplName = '新手套装'
    if (kids === 'yes' || people === 'family') {
      tpl = 'cpt03'
      tplName = '家庭套装'
    } else if (days === 'd1' && people === 'solo' && camp !== 'park') {
      tpl = 'cpt02'
      tplName = '轻量化套装'
    } else if (days === 'd4' && season === 'winter') {
      tpl = 'cpt03'
      tplName = '家庭套装'
    }

    const report = new DiagnoseReport()
    report.title = '智慧打包清单'
    report.generatedAt = DiagnoseService.nowLabel()
    report.matchCategory = tpl
    report.matchHint = `规则已匹配「${tplName}」。打开模板后可按克重勾选，再按行程人数改件数。`
    report.summary =
      `根据「${DiagnoseService.labelOf(answers, 'days')}」、` +
      `「${DiagnoseService.labelOf(answers, 'season')}」、` +
      `「${DiagnoseService.labelOf(answers, 'people')}」、` +
      `「${DiagnoseService.labelOf(answers, 'camp')}」生成。` +
      `这是预设规则，不是实时气象，也不构成户外安全承诺。`
    report.strength = DiagnoseService.strengthText(days, people, camp)
    report.weakness = DiagnoseService.weaknessText(season, camp, kids)
    report.opportunity = DiagnoseService.opportunityText(season, alt)
    report.threat = DiagnoseService.threatText(season, camp, alt)
    report.actions = DiagnoseService.actions(tplName, camp, season, alt, kids)
    report.scoreLabel = DiagnoseService.scoreLabel(days, camp, season)
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
    return '未填'
  }

  private static nowLabel(): string {
    const d = new Date()
    const y = d.getFullYear()
    const mo = d.getMonth() + 1
    const day = d.getDate()
    const moStr = mo < 10 ? `0${mo}` : `${mo}`
    const dayStr = day < 10 ? `0${day}` : `${day}`
    return `${y}-${moStr}-${dayStr}`
  }

  private static strengthText(days: string, people: string, camp: string): string {
    let s = '行程边界清楚：天数、人数和营地类型已经能撑起一份可勾选的清单。'
    if (camp === 'park') {
      s = `${s} 公园营地通常有水电淋浴，炊具与照明可以按营地设施减重。`
    } else if (camp === 'rv') {
      s = `${s} 房车营地可把睡垫与大型帐篷降优先级，留下水电适配件。`
    }
    if (people === 'duo') {
      s = `${s} 两人可分摊炉头与帐篷重量。`
    }
    if (days === 'd1') {
      s = `${s} 短过夜最怕漏带头灯与防潮垫，清单会把这两项置顶。`
    }
    return s
  }

  private static weaknessText(season: string, camp: string, kids: string): string {
    let w = '容易漏带的是消耗品：燃料、水、备用电池，而不是大件帐篷。'
    if (season === 'summer') {
      w = '夏季漏带高发：防雨罩、驱蚊、额外饮水。暴雨对流时营地可能积水。'
    } else if (season === 'winter') {
      w = '冬季漏带高发：睡袋温标不够、备用保暖层、冷凝处理布。'
    } else if (season === 'spring') {
      w = '春季昼夜温差大，容易只带夏袋而忽略抓绒中层。'
    }
    if (camp === 'wild') {
      w = `${w} 无设施野营必须自备净水和粪便处理方案。`
    }
    if (kids === 'yes') {
      w = `${w} 有儿童时照明与防风绳要加倍，避免只按成人件数准备。`
    }
    return w
  }

  private static opportunityText(season: string, alt: string): string {
    let o = '套用模板后，把克数按人数乘上去，再删掉营地已提供的设施项。'
    if (season === 'autumn') {
      o = '秋季适合轻量化：干爽天气可减一套备用外衣，把重量留给更好的睡垫。'
    } else if (season === 'summer') {
      o = '夏季可把重型羽绒换成薄被，把克数让给遮阳与水量。'
    }
    if (alt === 'high') {
      o = `${o} 高海拔优先保证保暖和煮沸时间，不要用城市炉头功率去估高原。`
    }
    return o
  }

  private static threatText(season: string, camp: string, alt: string): string {
    let t = '天气卡片是规则预览，不是气象台实况。出发当天请自行核对目的地预报。'
    if (season === 'summer') {
      t = '夏季对流雷暴是主要风险：金属帐篷杆、空旷山脊、河边营地都要提前改点。'
    } else if (season === 'winter') {
      t = '冬季最大风险是湿冷：棉衣打湿后几乎没有保温能力。'
    }
    if (camp === 'wild') {
      t = `${t} 野营没有管理方，迷路与水源污染需自行负责。`
    }
    if (alt === 'high') {
      t = `${t} 高海拔可能出现头痛与睡眠差，行程不要按平原体能排。`
    }
    return t
  }

  private static actions(tplName: string, camp: string, season: string, alt: string, kids: string): string[] {
    const list: string[] = []
    list.push(`打开「${tplName}」，按克重勾选帐篷、睡眠、炊具、照明。`)
    list.push('规划行程时填入目的地城市，对照首页天气规则加装雨具或保暖层。')
    if (camp === 'wild') {
      list.push('野营清单加上滤水器 / 净水片与垃圾袋，不要假设有厕所。')
    } else {
      list.push('公园或房车营地可减去净水大件，保留营地插头与公区拖鞋。')
    }
    if (season === 'winter') {
      list.push('核对睡袋温标是否低于目的地夜间低温，并加备用帽子。')
    }
    if (alt === 'high') {
      list.push('高原行程预留煮水时间，炉头与燃料按 1.3 倍估算。')
    }
    if (kids === 'yes') {
      list.push('儿童头灯、防风绳与加厚防潮垫单独成行，不要并进成人帐篷项。')
    }
    list.push('打包当晚称一次整包，超重先减备用衣而不是减头灯。')
    return list
  }

  private static scoreLabel(days: string, camp: string, season: string): string {
    if (camp === 'wild' && (season === 'winter' || season === 'summer')) {
      return '建议按完整套装准备'
    }
    if (days === 'd1' && camp === 'park') {
      return '可以走轻量化'
    }
    return '按模板微调即可'
  }
}
