import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { HomeItem, FamilyMemo } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'
import { TaskLocalStore } from './TaskLocalStore'
import { ItemService } from './ItemService'
import { MemoService } from './MemoService'
import { ChecklistService } from './ChecklistService'
import { TaskDates } from '../models/FamilyTaskModels'

const STORE = 'jujia_welcome_seed'
const KEY_DONE = 'guideSeeded'

/** 首次安装写入多模块引导内容（非用户私有单据），避免审核看到「空壳待办 App」。 */
export class WelcomeSeedService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      WelcomeSeedService.pref = await preferences.getPreferences(context, STORE)
    } catch {
      WelcomeSeedService.pref = null
    }
  }

  static async seedGuideContentIfNeeded(): Promise<void> {
    if (WelcomeSeedService.pref === null) {
      return
    }
    const doneVal = await WelcomeSeedService.pref.get(KEY_DONE, false)
    if (doneVal === true) {
      return
    }
    await TaskLocalStore.seedWelcomeSamples()
    if (JujiaLocalStore.items().length === 0) {
      await WelcomeSeedService.seedItems()
    }
    if (JujiaLocalStore.memos().length === 0) {
      await WelcomeSeedService.seedMemos()
    }
    if (JujiaLocalStore.checklists().length === 0) {
      await ChecklistService.create('居家常备采购', '采购')
    }
    await WelcomeSeedService.pref.put(KEY_DONE, true)
    await WelcomeSeedService.pref.flush()
  }

  private static async seedItems(): Promise<void> {
    const d1 = new HomeItem()
    d1.name = '冰箱'
    d1.category = '家电'
    d1.room = '厨房'
    d1.location = '厨房'
    d1.expiryDate = WelcomeSeedService.futureYmd(180)
    d1.remark = '年度除霜与密封条检查'
    d1.remindLeadDays = 30
    await ItemService.create(d1)

    const d2 = new HomeItem()
    d2.name = '护照'
    d2.category = '证件'
    d2.room = '书房'
    d2.location = '证件抽屉'
    d2.remark = '出行前核对有效期'
    d2.remindLeadDays = 60
    await ItemService.create(d2)

    const d3 = new HomeItem()
    d3.name = '家庭常备药箱'
    d3.category = '健康'
    d3.room = '客厅'
    d3.location = '电视柜抽屉'
    d3.remark = '定期清理过期药品'
    d3.remindLeadDays = 90
    await ItemService.create(d3)
  }

  private static async seedMemos(): Promise<void> {
    const m1 = new FamilyMemo()
    m1.title = '周末采购清单'
    m1.body = '牛奶、鸡蛋、水果、纸巾；如有客人来访补充饮料与零食。'
    m1.tag = '采购'
    m1.pinned = true
    await MemoService.create(m1)

    const m2 = new FamilyMemo()
    m2.title = '家庭维修联系人'
    m2.body = '物业、水电维修、空调清洗；紧急电话贴在冰箱贴。'
    m2.tag = '维修'
    await MemoService.create(m2)
  }

  static futureYmd(days: number): string {
    const d = new Date()
    d.setDate(d.getDate() + days)
    return TaskDates.ymd(d)
  }
}
