import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { GrowthMedia } from '../../services/GrowthMedia'
import { DetailShell } from './DetailShell'
import {
  CreateBoardRequest,
  GoalStepItem,
  GrowthRecordItem,
  UpdatePlanRequest
} from '../../models/GrowthModels'
import { GrowthBizService } from '../../services/GrowthBizService'
import { GrowthDetailNav } from '../../services/GrowthDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct PlanDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onPlanUpdated: () => void = () => {}
  @State item: GrowthRecordItem | undefined = undefined
  @State steps: GoalStepItem[] = []
  @State stepDraft: string = ''
  @State loading: boolean = true
  @State updating: boolean = false
  @State showCeremony: boolean = false
  @State ceremonyNote: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private closeAndRefresh(): void {
    GrowthDetailNav.close()
    this.onPlanUpdated()
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await GrowthBizService.findCreativePlan(this.itemId)
    if (this.item !== undefined) {
      this.steps = GoalStepItem.parse(this.item.cardsJson)
      this.showCeremony = this.item.progress >= 100
    }
    this.loading = false
  }

  private async persist(progress: number, json: string): Promise<boolean> {
    if (!AuthService.requireAuth('create_goal')) {
      this.onRequireAuth()
      return false
    }
    if (this.item === undefined) {
      return false
    }
    this.updating = true
    const req = new UpdatePlanRequest()
    req.title = this.item.title
    req.goal = this.item.goal
    req.summary = this.item.summary.length > 0 ? this.item.summary : this.item.goal
    req.progress = progress
    req.cardsJson = json
    const updated = await GrowthBizService.updateCreativePlan(this.item.id, req)
    this.updating = false
    if (updated === undefined) {
      this.showToast(GrowthBizService.lastError.length > 0 ? GrowthBizService.lastError : '更新失败')
      return false
    }
    updated.cardsJson = json
    this.item = updated
    this.onPlanUpdated()
    if (progress >= 100) {
      this.showCeremony = true
      this.showToast('目标已完成，写下完成心得即可归档时间轴')
    } else {
      this.showCeremony = false
      this.showToast(`进度已更新至 ${progress}%`)
    }
    return true
  }

  private async bumpProgress(delta: number): Promise<void> {
    if (this.item === undefined || this.updating) {
      return
    }
    const next = Math.min(100, Math.max(0, this.item.progress + delta))
    await this.persist(next, GoalStepItem.encode(this.steps))
  }

  private async toggleStep(id: string): Promise<void> {
    if (this.updating) {
      return
    }
    const next: GoalStepItem[] = []
    for (const s of this.steps) {
      const copy = new GoalStepItem()
      copy.id = s.id
      copy.title = s.title
      copy.done = s.id === id ? !s.done : s.done
      next.push(copy)
    }
    this.steps = next
    await this.persist(GoalStepItem.progressOf(next), GoalStepItem.encode(next))
  }

  private async addStep(): Promise<void> {
    const title = this.stepDraft.trim()
    if (title.length === 0) {
      this.showToast('请填写步骤名称')
      return
    }
    const next: GoalStepItem[] = []
    for (const s of this.steps) {
      next.push(s)
    }
    const item = new GoalStepItem()
    item.id = `s${next.length}`
    item.title = title
    next.push(item)
    this.steps = next
    this.stepDraft = ''
    await this.persist(GoalStepItem.progressOf(next), GoalStepItem.encode(next))
  }

  private async addSuggested(): Promise<void> {
    const next: GoalStepItem[] = []
    const t1 = new GoalStepItem()
    t1.id = 's0'
    t1.title = '迈出可验证的第一步'
    next.push(t1)
    const t2 = new GoalStepItem()
    t2.id = 's1'
    t2.title = '完成一次中期检查'
    next.push(t2)
    const t3 = new GoalStepItem()
    t3.id = 's2'
    t3.title = '对照完成标准收尾'
    next.push(t3)
    this.steps = next
    await this.persist(0, GoalStepItem.encode(next))
  }

  private async archiveMilestone(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    if (!AuthService.requireAuth('create_goal')) {
      this.onRequireAuth()
      return
    }
    const req = new CreateBoardRequest()
    req.title = `完成 · ${this.item.title}`
    req.description = this.ceremonyNote.trim().length > 0 ?
      this.ceremonyNote.trim() : '目标达到 100%，已从进行中移入完成。'
    req.body = req.description
    req.coverKey = 'board_default'
    const created = await GrowthBizService.createMoodBoard(req)
    if (created !== undefined) {
      this.showToast('已写入时间轴')
      this.onPlanUpdated()
      setTimeout(() => { this.closeAndRefresh() }, 700)
    } else {
      this.showToast('写入时间轴失败，进度已保存')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载计划…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '计划不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '成长目标',
          onClose: (): void => { this.closeAndRefresh() },
          body: () => { this.DetailBody() }
        })
      }
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(GrowthMedia.coverMedia(this.item.coverKey.length > 0 ? this.item.coverKey : 'plan_default'))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column()
            .width('100%')
            .height(168)
            .linearGradient({
              angle: 180,
              colors: [['rgba(15,23,42,0.08)', 0], ['rgba(15,23,42,0.72)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          Text(this.item.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textOnInverse)
            .padding(Theme.space.s5)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s3 }) {
          Text(`${this.item.progress}% 完成度`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandAccent)
            .width('100%')
          Stack({ alignContent: Alignment.Start }) {
            Row().width('100%').height(10)
              .backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.pill)
            Row().width(`${this.item.progress}%`).height(10)
              .backgroundColor(Theme.colors().success).borderRadius(Theme.radius.pill)
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '目标', variant: 'plain' }) {
            Text(this.item.goal.length > 0 ? this.item.goal : this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s3 }) {
          Text('拆解步骤（勾选会自动更新完成度）')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.steps.length === 0) {
            AppButton({
              label: '一键生成三步拆解',
              variant: 'secondary',
              onTap: (): void => { void this.addSuggested() }
            })
          }
          ForEach(this.steps, (s: GoalStepItem) => {
            Row({ space: Theme.space.s3 }) {
              Text(s.done ? '已完成' : '待完成')
                .fontSize(Theme.type.caption)
                .fontColor(s.done ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor(s.done ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
              Text(s.title)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
                .decoration({ type: s.done ? TextDecorationType.LineThrough : TextDecorationType.None })
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => { void this.toggleStep(s.id) })
          }, (s: GoalStepItem) => s.id)
          TextInput({ text: this.stepDraft, placeholder: '新增一步，例如：今晚完成大纲' })
            .width('100%')
            .height(44)
            .onChange((v: string) => { this.stepDraft = v })
          AppButton({
            label: '添加步骤',
            variant: 'secondary',
            onTap: (): void => { void this.addStep() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '-10%',
            variant: 'secondary',
            onTap: (): void => { void this.bumpProgress(-10) }
          }).layoutWeight(1)
          AppButton({
            label: this.updating ? '更新中…' : '+10%',
            onTap: (): void => { void this.bumpProgress(10) }
          }).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.showCeremony) {
          Column({ space: Theme.space.s3 }) {
            Text('完成仪式')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text('目标已达 100%。写下完成心得，归档到时间轴后，首页「进行中」会立即减少、「已完成」会增加。')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.ceremonyNote, placeholder: '这次最关键的突破是什么？' })
              .width('100%')
              .height(88)
              .onChange((v: string) => { this.ceremonyNote = v })
            AppButton({
              label: '写入时间轴并返回',
              onTap: (): void => { void this.archiveMilestone() }
            })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.xl)
        }
      }
    }
  }
}
