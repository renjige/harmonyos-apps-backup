import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 配饮问卷：规则匹配一款消暑饮（无大模型） */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('feel', '此刻体感更像？', [
        DiagnoseOption.of('hot', '燥热，皮肤发烫'),
        DiagnoseOption.of('humid', '闷湿，空气发黏'),
        DiagnoseOption.of('thirst', '口干，只想灌水'),
        DiagnoseOption.of('oily', '刚吃完，嘴里发腻')
      ]),
      DiagnoseQuestion.of('taste', '更想喝到的味道？', [
        DiagnoseOption.of('sour', '酸爽'),
        DiagnoseOption.of('sweet', '清甜'),
        DiagnoseOption.of('light', '淡雅'),
        DiagnoseOption.of('milk', '奶香')
      ]),
      DiagnoseQuestion.of('time', '你能给出多久？', [
        DiagnoseOption.of('fast', '五分钟内'),
        DiagnoseOption.of('mid', '十五分钟左右'),
        DiagnoseOption.of('slow', '不限，可以慢慢煮')
      ]),
      DiagnoseQuestion.of('tool', '手头有什么？', [
        DiagnoseOption.of('cup', '只要杯子和冰块'),
        DiagnoseOption.of('fridge', '有冰箱'),
        DiagnoseOption.of('blender', '有搅拌机')
      ]),
      DiagnoseQuestion.of('avoid', '需要避开的？', [
        DiagnoseOption.of('dairy', '乳制品'),
        DiagnoseOption.of('caf', '咖啡因'),
        DiagnoseOption.of('acid', '过酸'),
        DiagnoseOption.of('none', '没有忌口')
      ]),
      DiagnoseQuestion.of('effect', '更想带走的感觉？', [
        DiagnoseOption.of('heat', '清热'),
        DiagnoseOption.of('grease', '解腻'),
        DiagnoseOption.of('water', '补水'),
        DiagnoseOption.of('calm', '安神')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const feel = DiagnoseService.optionId(answers, 'feel')
    const taste = DiagnoseService.optionId(answers, 'taste')
    const time = DiagnoseService.optionId(answers, 'time')
    const tool = DiagnoseService.optionId(answers, 'tool')
    const avoid = DiagnoseService.optionId(answers, 'avoid')
    const effect = DiagnoseService.optionId(answers, 'effect')
    const drinkId = DiagnoseService.matchDrink(feel, taste, time, tool, avoid, effect)
    const name = DiagnoseService.drinkName(drinkId)
    const report = new DiagnoseReport()
    report.generatedAt = DiagnoseService.nowLabel()
    report.title = '智慧配饮'
    report.summary =
      `按你选的体感、口味与手头工具，更适合先做「${name}」。结论来自规则匹配，不是医疗建议，请按自己的肠胃与忌口调整冰量和甜度。`
    report.strength = feel === 'hot'
      ? '你对高温很敏感——优先高水分、满冰、少奶的杯子。'
      : '你愿意把消暑拆成一杯可执行的配方，而不是硬扛空调房。'
    report.weakness = tool === 'cup'
      ? '没有搅拌机时，冰沙和厚奶昔先放下，果茶与冰饮足够凉快。'
      : '材料再齐，也别一次做太甜：暑天第一口应解渴，不是甜点。'
    report.opportunity = `打开「${name}」看食材、步骤、冰量与功效，收藏后下次体感相近可直接做。`
    report.threat = '过酸、乳制品或咖啡因若在忌口里，请以详情页标注为准。功效说明不替代就医。'
    report.actions = [
      `打开饮品「${name}」阅读步骤`,
      '按体感加减冰块，不要一次加满糖',
      '做完后可在详情里记下试做'
    ]
    report.matchCategory = drinkId
    report.matchHint = `去看「${name}」。先读详情，再决定要不要动手。`
    report.scoreLabel = '适合此刻的那一杯'
    return report
  }

  static matchDrink(
    feel: string,
    taste: string,
    time: string,
    tool: string,
    avoid: string,
    effect: string
  ): string {
    if (avoid === 'dairy' && tool === 'blender' && feel === 'thirst') {
      return 'sd_mango_slush'
    }
    if (avoid === 'dairy' && effect === 'water') {
      return 'sd_wm_slush'
    }
    if (avoid === 'caf' && feel === 'oily') {
      return 'sd_chenpi'
    }
    if (avoid === 'acid' && taste === 'light') {
      return 'sd_chrysanthemum'
    }
    if (tool === 'blender' && feel === 'hot') {
      return 'sd_mint_slush'
    }
    if (time === 'fast' && feel === 'humid') {
      return 'sd_lime_soda'
    }
    if (taste === 'milk' && avoid !== 'dairy' && effect === 'calm') {
      return 'sd_taro'
    }
    if (taste === 'milk' && avoid !== 'dairy') {
      return 'sd_banana_shake'
    }
    if (effect === 'water' || feel === 'thirst') {
      return 'sd_watermelon_mint'
    }
    if (effect === 'grease' || feel === 'oily') {
      return 'sd_mint_slush'
    }
    if (taste === 'sour') {
      return 'sd_suanmei'
    }
    if (taste === 'sweet') {
      return 'sd_peach_oolong'
    }
    if (feel === 'hot') {
      return 'sd_lvdou'
    }
    return 'sd_lemon_honey'
  }

  static drinkName(id: string): string {
    if (id === 'sd_suanmei') {
      return '冰镇酸梅汤'
    }
    if (id === 'sd_lime_soda') {
      return '青柠苏打'
    }
    if (id === 'sd_wm_slush') {
      return '西瓜冰沙'
    }
    if (id === 'sd_mango_slush') {
      return '芒果冰沙'
    }
    if (id === 'sd_mint_slush') {
      return '柠檬薄荷冰沙'
    }
    if (id === 'sd_chenpi') {
      return '陈皮山楂茶'
    }
    if (id === 'sd_chrysanthemum') {
      return '菊花枸杞茶'
    }
    if (id === 'sd_taro') {
      return '芋泥奶昔'
    }
    if (id === 'sd_banana_shake') {
      return '香蕉牛奶冰'
    }
    if (id === 'sd_watermelon_mint') {
      return '西瓜薄荷茶'
    }
    if (id === 'sd_peach_oolong') {
      return '蜜桃乌龙'
    }
    if (id === 'sd_lvdou') {
      return '冰镇绿豆汤'
    }
    return '柠檬蜂蜜茶'
  }

  static optionId(answers: DiagnoseAnswer[], questionId: string): string {
    for (const a of answers) {
      if (a.questionId === questionId) {
        return a.optionId
      }
    }
    return ''
  }

  static nowLabel(): string {
    const n = new Date()
    const m = n.getMonth() + 1
    const d = n.getDate()
    const hh = n.getHours()
    const mm = n.getMinutes()
    const m2 = m < 10 ? `0${m}` : `${m}`
    const d2 = d < 10 ? `0${d}` : `${d}`
    const h2 = hh < 10 ? `0${hh}` : `${hh}`
    const min2 = mm < 10 ? `0${mm}` : `${mm}`
    return `${n.getFullYear()}-${m2}-${d2} ${h2}:${min2}`
  }
}
