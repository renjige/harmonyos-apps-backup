import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 出行偏好问卷 → 规则匹配一座目的地（无大模型） */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('land', '这次更想遇见哪一类风景？', [
        DiagnoseOption.of('nature', '自然风光：山、湖、云'),
        DiagnoseOption.of('history', '人文历史：城墙、石窟、博物馆'),
        DiagnoseOption.of('food', '休闲美食：巷口与茶馆'),
        DiagnoseOption.of('city', '城市漫步：湖滨或海边坡路')
      ]),
      DiagnoseQuestion.of('span', '你能给出几天？', [
        DiagnoseOption.of('two', '一两天刚刚好'),
        DiagnoseOption.of('three', '三天左右'),
        DiagnoseOption.of('flex', '看心情，不赶')
      ]),
      DiagnoseQuestion.of('energy', '这次出行的力气像？', [
        DiagnoseOption.of('low', '只想慢慢走、坐下来'),
        DiagnoseOption.of('mid', '可以走一段步道'),
        DiagnoseOption.of('high', '愿意早起或爬一点')
      ]),
      DiagnoseQuestion.of('season', '你更在意哪段时节？', [
        DiagnoseOption.of('spring', '春秋，风软、人少一些'),
        DiagnoseOption.of('summer', '夏天也要出门'),
        DiagnoseOption.of('any', '不太挑季节')
      ]),
      DiagnoseQuestion.of('company', '和谁一起？', [
        DiagnoseOption.of('alone', '自己就很好'),
        DiagnoseOption.of('family', '家人或朋友')
      ]),
      DiagnoseQuestion.of('mood', '最想带走的感觉？', [
        DiagnoseOption.of('water', '水与风'),
        DiagnoseOption.of('stone', '石头与时间'),
        DiagnoseOption.of('table', '一桌菜、一碗茶')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const land = DiagnoseService.optionId(answers, 'land')
    const span = DiagnoseService.optionId(answers, 'span')
    const energy = DiagnoseService.optionId(answers, 'energy')
    const season = DiagnoseService.optionId(answers, 'season')
    const company = DiagnoseService.optionId(answers, 'company')
    const mood = DiagnoseService.optionId(answers, 'mood')
    const destId = DiagnoseService.matchDest(land, span, energy, season, company, mood)
    const name = DiagnoseService.destName(destId)
    const report = new DiagnoseReport()
    report.generatedAt = DiagnoseService.nowLabel()
    report.title = '出行偏好报告'
    report.summary =
      `按你选的风景类型与力气，更适合先看「${name}」。结论来自规则匹配，不是实时票务或天气预报。出发前请再核对开放时间与交通公告。`
    report.strength = energy === 'high'
      ? '你愿意把一天拆成可走的路，适合选有台阶或环线的目的地。'
      : '你愿意把旅行做成停下来的时间，这比赶清单更像「到过」。'
    report.weakness = span === 'two'
      ? '天数不多，请只选一到两处停点，不要把十景走完。'
      : '别把每天排满上午下午晚上以外的加项，留出发呆。'
    report.opportunity = `打开「${name}」看最佳季节、推荐天数与当地贴士。登录后可收藏，并用智能规划生成分日行程。`
    report.threat = season === 'summer'
      ? '夏季紫外线与人流都更强。防晒、饮水和错峰清晨更重要。'
      : '雨雾天不要轻易取消——轮廓有时比晴天更像水墨，但石板会滑。'
    report.actions = [
      `打开目的地「${name}」阅读介绍与贴士`,
      '用智能规划按天数生成上午、下午、晚上',
      '回来后可在社区写下这一段路'
    ]
    report.matchCategory = destId
    report.matchHint = `去看「${name}」。先读详情，再决定要不要出发。`
    report.scoreLabel = '适合先看这座'
    return report
  }

  static matchDest(
    land: string,
    span: string,
    energy: string,
    season: string,
    company: string,
    mood: string
  ): string {
    if (land === 'food' || mood === 'table') {
      return 'qy_d03'
    }
    if (land === 'history' || mood === 'stone') {
      if (energy === 'high' || span === 'three') {
        return 'qy_d04'
      }
      return 'qy_d06'
    }
    if (land === 'city') {
      if (mood === 'water' || season === 'summer') {
        return 'qy_d08'
      }
      return 'qy_d01'
    }
    if (energy === 'high') {
      return span === 'two' ? 'qy_d05' : 'qy_d02'
    }
    if (company === 'family' || span === 'flex') {
      return 'qy_d07'
    }
    if (mood === 'water') {
      return 'qy_d01'
    }
    return 'qy_d02'
  }

  static destName(id: string): string {
    if (id === 'qy_d01') { return '杭州西湖' }
    if (id === 'qy_d02') { return '张家界' }
    if (id === 'qy_d03') { return '成都宽窄巷' }
    if (id === 'qy_d04') { return '敦煌莫高窟' }
    if (id === 'qy_d05') { return '黄山' }
    if (id === 'qy_d06') { return '西安古城' }
    if (id === 'qy_d07') { return '大理苍洱' }
    if (id === 'qy_d08') { return '青岛海边' }
    return '本季目的地'
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
