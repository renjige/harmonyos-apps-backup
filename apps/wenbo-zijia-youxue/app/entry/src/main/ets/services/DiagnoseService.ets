import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 研学匹配问卷 → 规则模板路线（非生成式 AI，文案用「智慧」）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('age', '孩子更接近哪个年龄段？', [
        DiagnoseOption.of('young', '3–6 岁'),
        DiagnoseOption.of('mid', '7–12 岁'),
        DiagnoseOption.of('teen', '13–15 岁')
      ]),
      DiagnoseQuestion.of('days', '这次大概能开几天？', [
        DiagnoseOption.of('short', '1–2 天周末'),
        DiagnoseOption.of('mid', '3 天左右'),
        DiagnoseOption.of('long', '4 天及以上')
      ]),
      DiagnoseQuestion.of('theme', '更想学哪一类？', [
        DiagnoseOption.of('nature', '自然探索'),
        DiagnoseOption.of('history', '历史文化'),
        DiagnoseOption.of('science', '科学启蒙'),
        DiagnoseOption.of('art', '艺术体验')
      ]),
      DiagnoseQuestion.of('pace', '体力与节奏？', [
        DiagnoseOption.of('easy', '少走路、好停车'),
        DiagnoseOption.of('walk', '能走古城或馆校'),
        DiagnoseOption.of('wild', '能接受山路或高原缓行')
      ]),
      DiagnoseQuestion.of('season', '更在意哪类气候准备？', [
        DiagnoseOption.of('south', '江南湿热 / 海岛风'),
        DiagnoseOption.of('plain', '平原城市温差'),
        DiagnoseOption.of('high', '高原或高海拔温差')
      ]),
      DiagnoseQuestion.of('goal', '旅途结束最想带走什么？', [
        DiagnoseOption.of('observe', '一次认真的观察'),
        DiagnoseOption.of('make', '一次动手体验'),
        DiagnoseOption.of('story', '一段能讲给家人听的故事')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const age = DiagnoseService.optionId(answers, 'age')
    const days = DiagnoseService.optionId(answers, 'days')
    const theme = DiagnoseService.optionId(answers, 'theme')
    const pace = DiagnoseService.optionId(answers, 'pace')
    const season = DiagnoseService.optionId(answers, 'season')
    const goal = DiagnoseService.optionId(answers, 'goal')

    const routeId = DiagnoseService.matchRouteId(age, days, theme, pace, season)
    const title = DiagnoseService.routeTitle(routeId)

    const report = new DiagnoseReport()
    report.title = '研学路线匹配'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `按你选择的年龄「${DiagnoseService.labelOf(answers, 'age')}」、` +
      `天数「${DiagnoseService.labelOf(answers, 'days')}」、` +
      `主题「${DiagnoseService.labelOf(answers, 'theme')}」做规则匹配。` +
      `这不是实时导航，也不是付费订票，只是一条可打开的智慧路线建议。`
    report.strength = DiagnoseService.fitText(theme, age, pace)
    report.weakness = DiagnoseService.careText(routeId, age, season)
    report.opportunity = DiagnoseService.learnText(theme, goal)
    report.threat = DiagnoseService.prepText(season, days, pace)
    report.actions = DiagnoseService.actions(routeId)
    report.matchCategory = routeId
    report.matchHint = title
    report.scoreLabel = DiagnoseService.scoreLabel(age, days, pace)
    return report
  }

  private static matchRouteId(age: string, days: string, theme: string, pace: string, season: string): string {
    if (theme === 'art') {
      if (age === 'young') {
        return 'srr07'
      }
      return 'srr04'
    }
    if (theme === 'science') {
      if (pace === 'wild' || days === 'long') {
        return 'srr08'
      }
      return 'srr03'
    }
    if (theme === 'history') {
      if (pace === 'easy') {
        return 'srr02'
      }
      return 'srr06'
    }
    if (season === 'high' || days === 'long' || pace === 'wild') {
      if (age === 'young') {
        return 'srr01'
      }
      return 'srr05'
    }
    if (days === 'mid') {
      return 'srr01'
    }
    return 'srr02'
  }

  private static routeTitle(id: string): string {
    if (id === 'srr01') {
      return '莫干山林间三日课堂'
    }
    if (id === 'srr02') {
      return '屯溪古城巷弄研学'
    }
    if (id === 'srr03') {
      return '科技馆与滴水湖海岸'
    }
    if (id === 'srr04') {
      return '景德镇陶土周末'
    }
    if (id === 'srr05') {
      return '青海湖环湖观鸟缓行'
    }
    if (id === 'srr06') {
      return '西安城墙与博物课堂'
    }
    if (id === 'srr07') {
      return '鼓浪屿旋律与骑楼'
    }
    if (id === 'srr08') {
      return '长白山天池地质慢行'
    }
    return '莫干山林间三日课堂'
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

  private static fitText(theme: string, age: string, pace: string): string {
    let s = '这条路线节奏偏家庭自驾，讲解点可以在车上完成。'
    if (theme === 'nature') {
      s = '自然观察点多，适合把提问停在一片叶子或一只鸟上。'
    } else if (theme === 'history') {
      s = '建筑与街巷尺度清楚，适合用脚步量「一座城有多大」。'
    } else if (theme === 'science') {
      s = '馆校或地质现象可对照，适合爱问「为什么会动」的孩子。'
    } else if (theme === 'art') {
      s = '手作或立面、声音可被看见听见，适合慢走与停留。'
    }
    if (age === 'young') {
      s = `${s} 低龄建议每次只完成 1–2 个观察任务。`
    }
    if (pace === 'easy') {
      s = `${s} 停车与步行压力相对可控。`
    }
    return s
  }

  private static careText(routeId: string, age: string, season: string): string {
    let w = '自驾仍需家长把控路况与休息，应用不提供实时导航。'
    if (routeId === 'srr05' || routeId === 'srr08') {
      w = '海拔或山路天气窗口短，孩子若头痛、胸闷应立即 downhill，不坚持打卡。'
    }
    if (age === 'young') {
      w = `${w} 低龄注意力短，不要排满馆校。`
    }
    if (season === 'high') {
      w = `${w} 备防晒、唇膏与保暖层。`
    }
    return w
  }

  private static learnText(theme: string, goal: string): string {
    let o = '打开路线详情后，按途经点进入百科，用分龄知识卡片讲给孩子听。'
    if (theme === 'art') {
      o = '把「土变成碗」或「房子为什么这样造」问完即可，不追求成品漂亮。'
    } else if (theme === 'science') {
      o = '每个展厅或观景点只留一个问题，回民宿再写进手账。'
    }
    if (goal === 'make') {
      o = `${o} 规划页可把动手体验写成每日清单。`
    } else if (goal === 'story') {
      o = `${o} 记录页写三句见闻，比拍一百张照片更有用。`
    }
    return o
  }

  private static prepText(season: string, days: string, pace: string): string {
    let t = '气候备忘只是季节说明，出行前请再看当地官方气象。'
    if (season === 'south') {
      t = `${t} 雨天石板湿滑，备防滑鞋。`
    } else if (season === 'high') {
      t = `${t} 紫外线与温差是主要风险，不安排夜间赶路。`
    }
    if (days === 'short') {
      t = `${t} 周末路线不要再加景点。`
    }
    if (pace === 'wild') {
      t = `${t} 山路请预留下午返程。`
    }
    return t
  }

  private static actions(routeId: string): string[] {
    const list: string[] = []
    list.push('打开匹配路线，看途经点与适龄说明。')
    list.push('在百科里切换 3–6 / 7–12 / 13–15 岁知识卡片。')
    list.push('登录后点「开始规划」，写每日景点、餐饮、住宿清单。')
    if (routeId === 'srr05' || routeId === 'srr08') {
      list.push('单独准备缓行与返程方案，不把「看一眼」写成必须完成。')
    } else {
      list.push('旅途中写一篇手账或完成一次景点打卡。')
    }
    return list
  }

  private static scoreLabel(age: string, days: string, pace: string): string {
    if (age === 'young' && pace === 'wild') {
      return '建议改走低强度线'
    }
    if (days === 'long') {
      return '适合慢慢开'
    }
    return '节奏匹配较好'
  }
}
