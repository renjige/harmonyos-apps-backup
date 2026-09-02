import { Theme } from '../design-system/Theme'
import { OverlayBar } from './OverlayBar'
import { MoveDetailPane } from '../detail/MoveDetailPane'
import { ComboEditorPane } from '../detail/ComboEditorPane'
import { PlanDetailPane } from '../detail/PlanDetailPane'
import { LogFormPane } from '../detail/LogFormPane'
import { LogDetailPane } from '../detail/LogDetailPane'
import { ChallengePane } from '../detail/ChallengePane'
import { ThemeBookPane } from '../detail/ThemeBookPane'
import { ReviewPane } from '../detail/ReviewPane'
import { AchievePane } from '../detail/AchievePane'
import { NoteFormPane } from '../detail/NoteFormPane'
import { ChecklistPane } from '../detail/ChecklistPane'
import { FavoritesPane } from '../detail/FavoritesPane'
import { KnowledgeListPane } from '../detail/KnowledgeListPane'
import { KnowledgeDetailPane } from '../detail/KnowledgeDetailPane'
import { NoteDetailPane } from '../detail/NoteDetailPane'
import { ProgramDetailPane } from '../detail/ProgramDetailPane'
import { ThemeBookEditorPane } from '../detail/ThemeBookEditorPane'
import { FolderEditorPane } from '../detail/FolderEditorPane'
import { DailyThemePane } from '../detail/DailyThemePane'
import { TrainingGuidePane } from '../detail/TrainingGuidePane'
import { PresetListPane } from '../detail/PresetListPane'
import { PresetDetailPane } from '../detail/PresetDetailPane'
import { WorkoutSessionPane } from '../detail/WorkoutSessionPane'
import { FitnessQuizPane } from '../detail/FitnessQuizPane'
import { WeeklyReportPane } from '../detail/WeeklyReportPane'
import { MoveComparePane } from '../detail/MoveComparePane'
import { TuceNav } from '../../services/TuceNav'

@Component
export struct OverlayHost {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tuceRoute') route: string = ''
  @StorageLink('tuceRouteId') routeId: string = ''

  private titleOf(): string {
    if (this.route === 'move') {
      return '动作详情'
    }
    if (this.route === 'combo') {
      return '编排训练方案'
    }
    if (this.route === 'plan') {
      return '训练方案'
    }
    if (this.route === 'logform') {
      return '运动日志'
    }
    if (this.route === 'log') {
      return '日志详情'
    }
    if (this.route === 'challenge') {
      return '运动挑战馆'
    }
    if (this.route === 'theme') {
      return '运动主题册'
    }
    if (this.route === 'review') {
      return '运动回顾'
    }
    if (this.route === 'achieve') {
      return '成就墙'
    }
    if (this.route === 'noteform') {
      return '运动笔记'
    }
    if (this.route === 'checklist') {
      return '训练清单'
    }
    if (this.route === 'favorites') {
      return '我的收藏'
    }
    if (this.route === 'klist') {
      return '知识卡库'
    }
    if (this.route === 'kcard') {
      return '知识卡详情'
    }
    if (this.route === 'note') {
      return '笔记详情'
    }
    if (this.route === 'program') {
      return '周期计划'
    }
    if (this.route === 'themeedit') {
      return '编辑主题册'
    }
    if (this.route === 'folderedit') {
      return '编辑收藏夹'
    }
    if (this.route === 'dailytheme') {
      return '今日主题'
    }
    if (this.route === 'guide') {
      return '训练百科'
    }
    if (this.route === 'presets') {
      return '精选课库'
    }
    if (this.route === 'preset') {
      return '课程详情'
    }
    if (this.route === 'session') {
      return '跟练模式'
    }
    if (this.route === 'quiz') {
      return '体能自测'
    }
    if (this.route === 'weeklyreport') {
      return '训练周报'
    }
    if (this.route === 'movecompare') {
      return '动作对比'
    }
    return '详情'
  }

  build() {
    Column() {
      OverlayBar({ title: this.titleOf(), onClose: (): void => { TuceNav.close() } })
      Column() {
        if (this.route === 'move') {
          MoveDetailPane({ moveId: this.routeId })
        } else if (this.route === 'combo') {
          ComboEditorPane({ seedId: this.routeId })
        } else if (this.route === 'plan') {
          PlanDetailPane({ planId: this.routeId })
        } else if (this.route === 'logform') {
          LogFormPane({ logDate: this.routeId })
        } else if (this.route === 'log') {
          LogDetailPane({ logId: this.routeId })
        } else if (this.route === 'challenge') {
          ChallengePane()
        } else if (this.route === 'theme') {
          ThemeBookPane({ bookId: this.routeId })
        } else if (this.route === 'review') {
          ReviewPane()
        } else if (this.route === 'achieve') {
          AchievePane()
        } else if (this.route === 'noteform') {
          NoteFormPane({ noteId: this.routeId })
        } else if (this.route === 'checklist') {
          ChecklistPane()
        } else if (this.route === 'favorites') {
          FavoritesPane()
        } else if (this.route === 'klist') {
          KnowledgeListPane()
        } else if (this.route === 'kcard') {
          KnowledgeDetailPane({ cardId: this.routeId })
        } else if (this.route === 'note') {
          NoteDetailPane({ noteId: this.routeId })
        } else if (this.route === 'program') {
          ProgramDetailPane({ programId: this.routeId })
        } else if (this.route === 'themeedit') {
          ThemeBookEditorPane({ bookId: this.routeId })
        } else if (this.route === 'folderedit') {
          FolderEditorPane({ folderId: this.routeId })
        } else if (this.route === 'dailytheme') {
          DailyThemePane()
        } else if (this.route === 'guide') {
          TrainingGuidePane()
        } else if (this.route === 'presets') {
          PresetListPane({ filterIds: this.routeId })
        } else if (this.route === 'preset') {
          PresetDetailPane({ presetId: this.routeId })
        } else if (this.route === 'session') {
          WorkoutSessionPane({ presetId: this.routeId })
        } else if (this.route === 'quiz') {
          FitnessQuizPane()
        } else if (this.route === 'weeklyreport') {
          WeeklyReportPane()
        } else if (this.route === 'movecompare') {
          MoveComparePane()
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
