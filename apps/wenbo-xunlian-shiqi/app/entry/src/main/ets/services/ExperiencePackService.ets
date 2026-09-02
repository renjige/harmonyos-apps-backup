import { KnowledgeCard, StageGoal } from '../models/TrainingModels'
import { FunQuestStore } from './FunQuestStore'
import { FunQuestService } from './FunQuestService'
import { MoveCatalog } from './MoveCatalog'
import { PracticeHubStore } from './PracticeHubStore'
import { PracticeService } from './PracticeService'
import { ProfileStore } from './ProfileStore'
import { FollowAlongService } from './FollowAlongService'
import { DataRefresh } from './DataRefresh'

/** 用户主动加载的「体验包」——帮助快速浏览全模块，不含训练记录，均可删除 */
export class ExperiencePackService {
  static isLoaded(): boolean {
    return ProfileStore.get().experiencePackLoaded === 1
  }

  static async load(): Promise<boolean> {
    if (ExperiencePackService.isLoaded()) {
      return false
    }
    const quest = FunQuestService.fromHall('d7')
    quest.title = '【体验】7 天运动挑战'
    quest.note = '示例挑战：跟练或记一次运动即可计入天数，可删除后自建。'
    await FunQuestStore.saveItem(quest)

    await MoveCatalog.importZone('热身')
    await MoveCatalog.importZone('拉伸')

    const checks = PracticeService.applyCheckTemplate(PracticeHubStore.getChecks())
    await PracticeHubStore.saveChecks(checks)

    const card = new KnowledgeCard()
    card.id = PracticeService.newCardId()
    card.title = '【体验】训练后拉伸要点'
    card.tag = '心得'
    card.body = '示例笔记：训练后做 5 分钟拉伸，肩背会更轻松。可在「训练笔记」里编辑或删除。'
    card.createdAt = new Date().toISOString()
    await PracticeHubStore.saveCard(card)

    const goal = new StageGoal()
    goal.id = PracticeService.newGoalId()
    goal.title = '【体验】本月跟练 12 次'
    goal.targetCount = 12
    goal.currentCount = 0
    goal.unit = '次'
    goal.syncKind = 'sessions'
    goal.createdAt = new Date().toISOString()
    await PracticeHubStore.saveGoal(goal)

    const moves = PracticeHubStore.listMoves()
    if (moves.length > 0) {
      await FollowAlongService.addToQueue(moves[0].id)
    }
    if (moves.length > 1) {
      await FollowAlongService.addToQueue(moves[1].id)
    }

    const profile = ProfileStore.get()
    profile.experiencePackLoaded = 1
    await ProfileStore.save(profile)
    DataRefresh.bump()
    return true
  }
}
