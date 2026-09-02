import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 学诗匹配：问卷 + 规则模板，不调用云端大模型。 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('dynasty', '更想读哪个时代？', [
        DiagnoseOption.of('tang', '盛唐气象'),
        DiagnoseOption.of('song', '宋词婉约'),
        DiagnoseOption.of('mix', '跨代浏览'),
        DiagnoseOption.of('pre', '先秦汉魏')
      ]),
      DiagnoseQuestion.of('theme', '最想点亮的主题？', [
        DiagnoseOption.of('nature', '山水田园'),
        DiagnoseOption.of('farewell', '送别怀人'),
        DiagnoseOption.of('moon', '月夜边塞'),
        DiagnoseOption.of('life', '咏史抒怀')
      ]),
      DiagnoseQuestion.of('level', '目前读诗感觉？', [
        DiagnoseOption.of('new', '刚入门，怕记错'),
        DiagnoseOption.of('mid', '能背几首名篇'),
        DiagnoseOption.of('high', '想挑战冷门与典故')
      ]),
      DiagnoseQuestion.of('time', '每次大概能花多久？', [
        DiagnoseOption.of('short', '五到十分钟'),
        DiagnoseOption.of('mid', '一刻钟左右'),
        DiagnoseOption.of('long', '愿意慢慢赏析')
      ]),
      DiagnoseQuestion.of('goal', '更希望得到什么？', [
        DiagnoseOption.of('play', '闯关乐趣'),
        DiagnoseOption.of('map', '诗地故事'),
        DiagnoseOption.of('read', '注释译文赏析')
      ]),
      DiagnoseQuestion.of('mood', '今天的阅读心情？', [
        DiagnoseOption.of('calm', '安静细读'),
        DiagnoseOption.of('hunt', '想开宝箱'),
        DiagnoseOption.of('collect', '想收藏几首')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const level = DiagnoseService.optionId(answers, 'level')
    const goal = DiagnoseService.optionId(answers, 'goal')
    const dynasty = DiagnoseService.optionId(answers, 'dynasty')
    const theme = DiagnoseService.optionId(answers, 'theme')
    const time = DiagnoseService.optionId(answers, 'time')
    const mood = DiagnoseService.optionId(answers, 'mood')

    const report = new DiagnoseReport()
    report.title = '学诗匹配结果'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `根据问卷：时代偏好「${DiagnoseService.labelOf(answers, 'dynasty')}」、` +
      `主题「${DiagnoseService.labelOf(answers, 'theme')}」、` +
      `程度「${DiagnoseService.labelOf(answers, 'level')}」。` +
      `以下为规则匹配，不是成绩测评。`

    if (level === 'new' || time === 'short') {
      report.matchCategory = '初窥门径'
      report.matchHint = 'ph_lv_01'
      report.scoreLabel = '适合从第一关启程'
    } else if (level === 'high') {
      report.matchCategory = '诗林高手'
      report.matchHint = 'ph_lv_09'
      report.scoreLabel = '可挑战更高关卡'
    } else {
      report.matchCategory = '小有成就'
      report.matchHint = 'ph_lv_05'
      report.scoreLabel = '适合稳步闯关'
    }

    report.strength = DiagnoseService.fitText(dynasty, theme, mood)
    report.weakness = DiagnoseService.noteText(level, time)
    report.opportunity = DiagnoseService.pathText(goal)
    report.threat = DiagnoseService.paceText(time, mood)
    report.actions = DiagnoseService.actions(goal, report.matchHint)
    return report
  }

  private static optionId(answers: DiagnoseAnswer[], qid: string): string {
    for (const a of answers) {
      if (a.questionId === qid) {
        return a.optionId
      }
    }
    return ''
  }

  private static labelOf(answers: DiagnoseAnswer[], qid: string): string {
    for (const a of answers) {
      if (a.questionId === qid) {
        return a.optionLabel
      }
    }
    return '未填'
  }

  private static nowLabel(): string {
    const d = new Date()
    const mo = d.getMonth() + 1
    const day = d.getDate()
    const moStr = mo < 10 ? `0${mo}` : `${mo}`
    const dayStr = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${moStr}-${dayStr}`
  }

  private static fitText(dynasty: string, theme: string, mood: string): string {
    let s = '你更适合带着趣味去读，而不是死记目录。'
    if (dynasty === 'tang') {
      s = '盛唐名篇适合用闯关记住名句，再去诗库看赏析。'
    } else if (dynasty === 'song') {
      s = '宋词宜慢读，建议通关后在详情里对照译文。'
    }
    if (theme === 'nature') {
      s = `${s} 山水田园可在地图上点亮亭台江河。`
    }
    if (mood === 'hunt') {
      s = `${s} 今日适合先开宝箱再深读。`
    }
    return s
  }

  private static noteText(level: string, time: string): string {
    if (level === 'new') {
      return '先完成选择与填空，不必一次读完全部注释。'
    }
    if (time === 'short') {
      return '时间短时只打一关，赏析可留到下次打开诗库。'
    }
    return '遇到典故不要跳过赏析，收藏后可在「我的」回看。'
  }

  private static pathText(goal: string): string {
    if (goal === 'map') {
      return '通关后打开地图，点鎏金标记阅读诗地故事。'
    }
    if (goal === 'read') {
      return '诗库按朝代与主题筛选，进入详情阅读注释、译文与赏析。'
    }
    return '从推荐关卡开始，答对即可获得诗币与宝箱。'
  }

  private static paceText(time: string, mood: string): string {
    if (time === 'long' && mood === 'calm') {
      return '可放慢节奏：一关之后读完赏析再下一关。'
    }
    return '连续通关可解锁隐藏篇章，但不必一天打完四境。'
  }

  private static actions(goal: string, levelId: string): string[] {
    const list: string[] = []
    list.push('点击下方按钮，直接进入推荐关卡。')
    if (goal === 'map') {
      list.push('通关后到地图页查看是否点亮新诗地。')
    } else if (goal === 'read') {
      list.push('在诗库收藏两首，并写一句笔记。')
    } else {
      list.push('连续答对四题可领取本关诗币。')
    }
    list.push('隐藏关卡需先完成一代宗师前三关。')
    if (levelId.length === 0) {
      list.push('若关卡未加载，请返回寻宝页重试。')
    }
    return list
  }
}
