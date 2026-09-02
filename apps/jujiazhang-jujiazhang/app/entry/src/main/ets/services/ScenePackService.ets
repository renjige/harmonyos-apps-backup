import { FamilyMemo } from '../models/JujiaModels'
import { FamilyTaskItem, TaskDates } from '../models/FamilyTaskModels'
import { LifeSceneDef, SceneApplyResult } from '../models/LifeSceneModels'
import { ChecklistService } from './ChecklistService'
import { MemoService } from './MemoService'
import { TaskService } from './TaskService'
import { ActivityService } from './ActivityService'

export class ScenePackService {
  static catalog(): LifeSceneDef[] {
    const out: LifeSceneDef[] = []
    out.push(ScenePackService.defWeekendClean())
    out.push(ScenePackService.defTravelPack())
    out.push(ScenePackService.defSchoolPrep())
    out.push(ScenePackService.defFestivalGuest())
    out.push(ScenePackService.defBabyCare())
    out.push(ScenePackService.defPetCare())
    out.push(ScenePackService.defElderCare())
    out.push(ScenePackService.defHomeRepair())
    return out
  }

  static find(code: string): LifeSceneDef | null {
    for (const row of ScenePackService.catalog()) {
      if (row.code === code) {
        return row
      }
    }
    return null
  }

  static async apply(code: string): Promise<SceneApplyResult> {
    const def = ScenePackService.find(code)
    const result = new SceneApplyResult()
    if (def === null) {
      result.message = '场景不存在'
      return result
    }
    const pack = await ChecklistService.create(def.checklistTitle, def.checklistKind)
    result.checklistId = pack.id
    const memoDraft = new FamilyMemo()
    memoDraft.title = def.memoTitle
    memoDraft.body = def.memoBody
    memoDraft.tag = def.memoTag
    memoDraft.pinned = true
    const memo = await MemoService.create(memoDraft)
    result.memoId = memo.id
    let taskCount = 0
    const today = TaskDates.today()
    for (const title of def.taskTitles) {
      const draft = new FamilyTaskItem()
      draft.title = title
      draft.date = today
      draft.category = def.checklistKind
      await TaskService.create(draft)
      taskCount += 1
    }
    result.taskCount = taskCount
    await ActivityService.log('create', 'scene', code, def.title,
      `清单+备忘+${taskCount}项计划`)
    result.message = `已创建「${def.title}」：居家清单 1 份、备忘 1 条、计划 ${taskCount} 项`
    return result
  }

  private static defWeekendClean(): LifeSceneDef {
    const d = new LifeSceneDef()
    d.code = 'weekend_clean'
    d.title = '周末大扫除'
    d.subtitle = '清单 · 计划 · 备忘一次就绪'
    d.checklistKind = '清洁'
    d.checklistTitle = '周末全屋清洁'
    d.memoTitle = '大扫除分工备忘'
    d.memoBody = '客厅归爸爸、厨房归妈妈、儿童房一起整理；清洁工具在阳台柜。'
    d.memoTag = '家务'
    d.taskTitles = ['整理客厅杂物', '厨房深度清洁', '清洗床品']
    return d
  }

  private static defTravelPack(): LifeSceneDef {
    const d = new LifeSceneDef()
    d.code = 'travel_pack'
    d.title = '旅行打包'
    d.subtitle = '证件物品 · 行程计划'
    d.checklistKind = '采购'
    d.checklistTitle = '出行行李清单'
    d.memoTitle = '旅行注意事项'
    d.memoBody = '证件、充电器、常用药、儿童用品；出发前检查门窗与燃气。'
    d.memoTag = '出行'
    d.taskTitles = ['预订交通', '整理行李箱', '设置离家提醒']
    return d
  }

  private static defSchoolPrep(): LifeSceneDef {
    const d = new LifeSceneDef()
    d.code = 'school_prep'
    d.title = '开学准备'
    d.subtitle = '文具采购 · 作息调整'
    d.checklistKind = '采购'
    d.checklistTitle = '开学用品采购'
    d.memoTitle = '开学第一周安排'
    d.memoBody = '书包文具、校服姓名贴、课外书；调整睡眠时间。'
    d.memoTag = '孩子'
    d.taskTitles = ['购买文具', '调整作息时间', '准备接送路线']
    return d
  }

  private static defFestivalGuest(): LifeSceneDef {
    const d = new LifeSceneDef()
    d.code = 'festival_guest'
    d.title = '节日团圆'
    d.subtitle = '采购菜单 · 待客清单'
    d.checklistKind = '采购'
    d.checklistTitle = '团圆饭准备清单'
    d.memoTitle = '来客接待备忘'
    d.memoBody = '菜单、座位、儿童区、备用床品；提前采购生鲜。'
    d.memoTag = '家庭'
    d.taskTitles = ['拟定菜单', '采购食材', '布置客卧']
    return d
  }

  private static defBabyCare(): LifeSceneDef {
    const d = new LifeSceneDef()
    d.code = 'baby_care'
    d.title = '育儿照护'
    d.subtitle = '用品清单 · 作息计划'
    d.checklistKind = '采购'
    d.checklistTitle = '婴儿用品补货'
    d.memoTitle = '育儿分工备忘'
    d.memoBody = '喂养、换尿布、疫苗预约；记录儿科医生联系方式。'
    d.memoTag = '孩子'
    d.taskTitles = ['整理婴儿房', '预约儿保', '补充奶粉尿布']
    return d
  }

  private static defPetCare(): LifeSceneDef {
    const d = new LifeSceneDef()
    d.code = 'pet_care'
    d.title = '宠物照护'
    d.subtitle = '粮药储备 · 清洁计划'
    d.checklistKind = '采购'
    d.checklistTitle = '宠物用品清单'
    d.memoTitle = '宠物护理备忘'
    d.memoBody = '驱虫、疫苗、洗澡周期；宠物医院与寄养联系方式。'
    d.memoTag = '家庭'
    d.taskTitles = ['购买宠粮', '清洁宠物用品', '预约洗澡']
    return d
  }

  private static defElderCare(): LifeSceneDef {
    const d = new LifeSceneDef()
    d.code = 'elder_care'
    d.title = '长辈关怀'
    d.subtitle = '用药提醒 · 陪诊计划'
    d.checklistKind = '采购'
    d.checklistTitle = '长辈常备物资'
    d.memoTitle = '陪诊与用药备忘'
    d.memoBody = '慢性病用药时间、复诊日期、紧急联系人。'
    d.memoTag = '家庭'
    d.taskTitles = ['整理常用药', '预约复诊', '检查居家防滑']
    return d
  }

  private static defHomeRepair(): LifeSceneDef {
    const d = new LifeSceneDef()
    d.code = 'home_repair'
    d.title = '居家维修'
    d.subtitle = '报修清单 · 师傅联系'
    d.checklistKind = '装修'
    d.checklistTitle = '维修事项清单'
    d.memoTitle = '维修联系人'
    d.memoBody = '水电、门窗、家电维修电话；保留保修单照片位置。'
    d.memoTag = '维修'
    d.taskTitles = ['检查漏水点', '联系维修师傅', '验收维修结果']
    return d
  }
}
