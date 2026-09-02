import { PlanItem, PlanTask } from '../models/LifeGrowthModels'
import { GoalItem, HabitItem, LifeDates, TodoItem } from '../models/LifeHubModels'
import { LifeGrowthStore } from './LifeGrowthStore'
import { LifeHubStore } from './LifeHubStore'

const AUDITOR = 'auditor@wenbo.local'
const FLAG = 'auditor_demo_seeded_v103'

/** 仅为审核演示账号预置本地计划/打卡数据（非普通新用户） */
export class AuditorBootstrapService {
  static async ensureDemoLifeData(username: string): Promise<void> {
    if (username !== AUDITOR) {
      return
    }
    const done = AppStorage.get<boolean>(FLAG)
    if (done === true) {
      return
    }
    const plans = await LifeGrowthStore.loadPlans()
    if (plans.length > 0) {
      AppStorage.setOrCreate(FLAG, true)
      return
    }
    const plan = LifeGrowthStore.newWeekPlan('审核体验 · 本周生活整理')
    const tasks: PlanTask[] = []
    tasks.push(PlanTask.of(LifeHubStore.newId('pt'), '整理书桌与文件', true))
    tasks.push(PlanTask.of(LifeHubStore.newId('pt'), '每天写一页记录', false))
    tasks.push(PlanTask.of(LifeHubStore.newId('pt'), '完成 3 次习惯打卡', false))
    plan.tasks = tasks
    plan.status = 'active'
    await LifeGrowthStore.upsertPlan(plan)

    const todo1 = new TodoItem()
    todo1.id = LifeHubStore.newId('todo')
    todo1.title = '体验计划 Tab 勾选待办'
    todo1.category = 'life'
    todo1.done = true
    todo1.date = LifeDates.todayIso()
    await LifeHubStore.upsertTodo(todo1)

    const todo2 = new TodoItem()
    todo2.id = LifeHubStore.newId('todo')
    todo2.title = '在灵感页选场景写一页'
    todo2.category = 'life'
    todo2.done = false
    todo2.date = LifeDates.todayIso()
    await LifeHubStore.upsertTodo(todo2)

    const habit1 = new HabitItem()
    habit1.id = LifeHubStore.newId('habit')
    habit1.title = '晨间喝水'
    habit1.checkins = [LifeDates.todayIso()]
    await LifeHubStore.upsertHabit(habit1)

    const habit2 = new HabitItem()
    habit2.id = LifeHubStore.newId('habit')
    habit2.title = '睡前阅读 15 分钟'
    habit2.checkins = []
    await LifeHubStore.upsertHabit(habit2)

    const goal = new GoalItem()
    goal.id = LifeHubStore.newId('goal')
    goal.title = '本月完成 12 页生活记录'
    goal.progress = 30
    goal.status = 'active'
    await LifeHubStore.upsertGoal(goal)

    LifeHubStore.notifyChanged()
    AppStorage.setOrCreate(FLAG, true)
  }
}
