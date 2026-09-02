import { MathEngine } from './MathEngine'
import { MathCatalog } from './MathCatalog'
import { MathLocalStore } from './MathLocalStore'
import { MathQuestion, QuizState } from '../models/MathModels'

export class MathQuizLaunch {
  static title(kind: string): string {
    if (kind === 'daily') {
      return '今日挑战'
    }
    if (kind === 'challenge') {
      return '闯关挑战'
    }
    if (kind === 'warm') {
      return '热身'
    }
    if (kind === 'story') {
      return '应用题'
    }
    if (kind === 'plan') {
      return '七日计划'
    }
    if (kind === 'weak') {
      return '加强练习'
    }
    if (kind === 'wrong') {
      return '再算一次'
    }
    if (kind === 'fav') {
      return '收藏复习'
    }
    if (kind === 'game') {
      return '趣味数学'
    }
    if (kind === 'table') {
      return '口诀练习'
    }
    if (kind === 'custom') {
      return '家长出题'
    }
    if (kind === 'pack') {
      return '我的题单'
    }
    return '练习'
  }

  static build(kind: string, mode: string, preset: MathQuestion[], challengeId: string,
    countOverride: number, limitSec: number): QuizState {
    const settings = MathLocalStore.settings()
    let count = 10
    let limit = limitSec
    if (countOverride > 0) {
      count = countOverride
    } else if (kind === 'daily') {
      count = settings.dailyCount
    } else if (kind === 'warm') {
      count = 5
    } else if (kind === 'story' || challengeId === 'km_ch_story') {
      count = 8
    } else if (challengeId === 'km_ch_speed') {
      count = 15
    }
    let quizMode = mode
    if (kind === 'daily' || kind === 'warm') {
      quizMode = MathEngine.gradeMode(settings.grade)
    }
    if (challengeId === 'km_ch_level2' || challengeId === 'km_ch_level3') {
      quizMode = 'mix_adv'
    } else if (challengeId === 'km_ch_story') {
      quizMode = 'story'
    } else if (challengeId === 'km_ch_sense') {
      quizMode = 'sense'
    } else if (challengeId === 'km_ch_timed') {
      quizMode = MathEngine.gradeMode(settings.grade)
      limit = 90
    } else if (challengeId === 'km_ch_cog') {
      quizMode = 'game'
    } else if (challengeId === 'km_ch_add') {
      quizMode = 'addsub'
    } else if (challengeId === 'km_ch_mul') {
      quizMode = 'muldiv'
    } else if (challengeId === 'km_ch_life') {
      quizMode = 'story'
    }
    if (kind === 'plan' && settings.planPreset === 'addsub') {
      quizMode = 'addsub'
    } else if (kind === 'plan' && settings.planPreset === 'story') {
      quizMode = 'story'
    } else if (kind === 'plan' && settings.planPreset === 'sense') {
      quizMode = 'sense'
    }
    const questions = preset.length > 0 ?
      preset : MathEngine.generate(quizMode, count, settings.difficulty)
    const state = new QuizState()
    state.kind = kind
    state.mode = quizMode
    state.challengeId = challengeId
    state.questions = questions
    state.index = 0
    state.correct = 0
    state.startedAt = Date.now()
    state.limitSec = limit
    return state
  }

  static planMode(): string {
    let idx = 0
    const cur = MathLocalStore.settings().planStart
    if (cur.length > 0) {
      const d = MathLocalStore.daysBetween(cur, MathLocalStore.today())
      if (d >= 0 && d <= 6) {
        idx = d
      }
    }
    return MathCatalog.planDayMode(idx)
  }
}
