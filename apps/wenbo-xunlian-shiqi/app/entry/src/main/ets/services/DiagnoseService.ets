import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'
import { TrainingAnalytics } from './TrainingAnalytics'

/**
 * 本周训练复盘问卷 → 规则模板报告（不调用大模型）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('goal', '本周最想捡回的趣味是？', [
        DiagnoseOption.of('light', '轻松出汗、不卷数据'),
        DiagnoseOption.of('break', '突破一项新类型'),
        DiagnoseOption.of('streak', '把连续天数守住'),
        DiagnoseOption.of('recover', '以拉伸恢复为主')
      ]),
      DiagnoseQuestion.of('energy', '多数训练后的体感？', [
        DiagnoseOption.of('easy', '轻松、还能再来一组'),
        DiagnoseOption.of('ok', '刚好、刚刚好'),
        DiagnoseOption.of('hard', '偏吃力、需要减量')
      ]),
      DiagnoseQuestion.of('time', '最容易坚持的时段？', [
        DiagnoseOption.of('morning', '早晨'),
        DiagnoseOption.of('noon', '午间'),
        DiagnoseOption.of('evening', '傍晚/晚上'),
        DiagnoseOption.of('flex', '随缘碎片时间')
      ]),
      DiagnoseQuestion.of('mix', '本周类型是否太单一？', [
        DiagnoseOption.of('same', '几乎只练一种'),
        DiagnoseOption.of('two', '两种轮换'),
        DiagnoseOption.of('rich', '三种及以上')
      ]),
      DiagnoseQuestion.of('fun', '哪件事最有「拾趣」感？', [
        DiagnoseOption.of('scene', '场景变化（晨光/雨后）'),
        DiagnoseOption.of('music', '配乐或节奏'),
        DiagnoseOption.of('note', '写下一句训练备注'),
        DiagnoseOption.of('badge', '看见徽章或热力图变亮')
      ]),
      DiagnoseQuestion.of('block', '最容易打断训练的是？', [
        DiagnoseOption.of('work', '加班/事务'),
        DiagnoseOption.of('weather', '天气'),
        DiagnoseOption.of('mood', '心情波动'),
        DiagnoseOption.of('plan', '没有提前定挑战')
      ]),
      DiagnoseQuestion.of('next', '下周最想先做哪一步？', [
        DiagnoseOption.of('quest', '新建一条拾趣挑战'),
        DiagnoseOption.of('type', '尝试一种新训练类型'),
        DiagnoseOption.of('note', '每次都写一句备注'),
        DiagnoseOption.of('rest', '安排一个拉伸夜')
      ]),
      DiagnoseQuestion.of('pace', '下周强度打算？', [
        DiagnoseOption.of('down', '略减量恢复'),
        DiagnoseOption.of('hold', '保持本周节奏'),
        DiagnoseOption.of('up', '温和加一点')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const goal = DiagnoseService.optionId(answers, 'goal')
    const energy = DiagnoseService.optionId(answers, 'energy')
    const mix = DiagnoseService.optionId(answers, 'mix')
    const next = DiagnoseService.optionId(answers, 'next')
    const pace = DiagnoseService.optionId(answers, 'pace')
    const summaryStats = TrainingAnalytics.summarize()

    const report = new DiagnoseReport()
    report.title = '本周训练拾趣复盘'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `已记录 ${summaryStats.totalCount} 次、连续 ${summaryStats.streakDays} 天。` +
      `问卷显示你更在意「${DiagnoseService.labelOf(answers, 'goal')}」，体感偏「${DiagnoseService.labelOf(answers, 'energy')}」。` +
      `以下为规则模板建议，不构成医疗或教练指导。`

    report.strength = energy === 'hard'
      ? '你已经能诚实标记「吃力」，这比硬撑更可持续。'
      : '能完成记录本身就是趣味闭环的第一步，数据会帮你看见自己。'
    report.weakness = mix === 'same'
      ? '类型偏单一，热力图容易只亮一块，拾趣感会变淡。'
      : '类型已有变化，注意不要把所有类型都练到「吃力」。'
    report.opportunity = next === 'quest'
      ? '用一条本周拾趣挑战把次数/分钟变成可完成的小游戏。'
      : '把「下一周先做的一步」写进挑战标题，完成时会解锁成就反馈。'
    report.threat = pace === 'up' && energy === 'hard'
      ? '体感已吃力却还想加量，下周优先恢复，避免中断连续天数。'
      : '事务打断比能力不足更常见：用日历视图提前占住训练日。'

    report.actions = [
      DiagnoseService.actionFor(next),
      mix === 'same' ? '本周至少再记一种新类型（哪怕 15 分钟）。' : '在备注里写一句「今天哪里有趣」。',
      pace === 'down' ? '安排一次拉伸夜，强度选「低」。' : '把主挑战目标控制在可完成的 3 次以内。'
    ]
    report.matchCategory = next === 'quest' ? '拾趣挑战' : '训练记录'
    report.matchHint = next === 'quest'
      ? '去「发现」Tab 加入一条挑战，完成后可标记领取。'
      : '回首页点「开始训练」，补上体感与收获再保存。'
    report.scoreLabel = energy === 'hard' ? '建议减量' : (summaryStats.streakDays >= 3 ? '节奏在线' : '慢慢拾趣')
    return report
  }

  private static actionFor(next: string): string {
    if (next === 'quest') {
      return '打开发现 Tab，加入「7天训练挑战」。'
    }
    if (next === 'type') {
      return '下次记录时换一个尚未点亮的训练类型。'
    }
    if (next === 'note') {
      return '连续 3 次训练都写一句备注，方便回看。'
    }
    return '在日历里标一个拉伸夜，强度选低。'
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
    return '未选'
  }

  private static nowLabel(): string {
    const d = new Date()
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  }
}
