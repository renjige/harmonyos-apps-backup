import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { InspirationCoverImage } from '../inspiration/InspirationCoverImage'
import { DetailShell } from './DetailShell'
import { InspirationItem, Milestone, MilestoneList, UpdatePlanRequest } from '../../models/InspirationModels'
import { InspirationBizService } from '../../services/InspirationBizService'
import { InspirationDetailNav } from '../../services/InspirationDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct PlanDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onPlanUpdated: () => void = () => {}
  @State item: InspirationItem | undefined = undefined
  @State displayProgress: number = 0
  @State loading: boolean = true
  @State updating: boolean = false
  @State toastText: string = ''
  @State milestones: Milestone[] = []
  @State milestoneEpoch: number = 0
  @State milestoneSaving: boolean = false
  @State linkedInspirations: InspirationItem[] = []
  @State confirmDelete: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

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

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await InspirationBizService.findCreativePlan(this.itemId)
    this.displayProgress = this.item !== undefined ? this.item.progress : 0
    if (this.item !== undefined) {
      this.milestones = MilestoneList.parse(this.item.milestonesJson)
      this.milestoneEpoch += 1
      this.linkedInspirations = await InspirationBizService.inspirationsLinkedToPlan(
        this.currentUsername,
        this.item.id
      )
    } else {
      this.milestones = []
      this.linkedInspirations = []
    }
    this.loading = false
  }

  private async saveMilestones(): Promise<void> {
    if (this.milestoneSaving || this.item === undefined) {
      return
    }
    if (!AuthService.requireAuth('create_plan')) {
      this.onRequireAuth()
      return
    }
    this.milestoneSaving = true
    const localSnapshot = MilestoneList.encode(this.milestones)
    const nextProgress = MilestoneList.progressPercent(this.milestones)
    try {
      const req = new UpdatePlanRequest()
      req.title = this.item.title
      req.goal = this.item.goal
      req.summary = this.item.summary
      req.progress = nextProgress
      req.milestonesJson = localSnapshot
      const updated = await InspirationBizService.updateCreativePlan(this.item.id, req)
      if (updated !== undefined) {
        this.item = updated
        this.displayProgress = nextProgress
        this.onPlanUpdated()
      } else {
        const msg = InspirationBizService.lastError
        this.showToast(msg.length > 0 ? msg : '里程碑保存失败')
      }
    } catch {
      this.showToast('里程碑保存失败')
    }
    this.milestoneSaving = false
  }

  private toggleMilestoneById(id: string): void {
    if (this.milestoneSaving) {
      return
    }
    const next: Milestone[] = []
    for (let i = 0; i < this.milestones.length; i++) {
      const copy = new Milestone()
      copy.id = this.milestones[i].id
      copy.title = this.milestones[i].title
      copy.done = this.milestones[i].id === id ? !this.milestones[i].done : this.milestones[i].done
      next.push(copy)
    }
    this.milestones = next
    this.milestoneEpoch += 1
    this.displayProgress = MilestoneList.progressPercent(next)
    void this.saveMilestones()
  }

  private isMilestoneDone(id: string): boolean {
    for (const m of this.milestones) {
      if (m.id === id) {
        return m.done
      }
    }
    return false
  }

  private async applyProgress(next: number): Promise<void> {
    if (this.updating) {
      return
    }
    if (!AuthService.requireAuth('create_plan')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    const prev = this.displayProgress
    this.updating = true
    this.displayProgress = next
    try {
      const updated = await InspirationBizService.updatePlanProgress(this.item.id, next)
      if (updated !== undefined) {
        this.item = updated
        this.displayProgress = updated.progress
        this.onPlanUpdated()
        this.showToast(`进度已更新至 ${this.displayProgress}%`)
      } else {
        this.displayProgress = prev
        const msg = InspirationBizService.lastError
        this.showToast(msg.length > 0 ? msg : '更新失败，请稍后重试')
      }
    } catch {
      this.displayProgress = prev
      this.showToast('更新失败，请稍后重试')
    }
    this.updating = false
  }

  private async deletePlan(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    this.updating = true
    const ok = await InspirationBizService.deleteCreativePlan(this.item.id)
    this.updating = false
    if (ok) {
      this.onPlanUpdated()
      InspirationDetailNav.close()
    } else {
      this.showToast('删除失败，请稍后重试')
    }
    this.confirmDelete = false
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.loading) {
        AppLoading({ label: '加载计划…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '计划不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '创意计划',
          onClose: () => InspirationDetailNav.close(),
          body: () => { this.DetailBody() }
        })
      }

      if (this.confirmDelete) {
        this.DeleteConfirmOverlay()
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
          InspirationCoverImage({
            coverKey: this.item.coverKey.length > 0 ? this.item.coverKey : 'plan_default',
            imageWidth: '100%',
            imageHeight: 160,
            useAspectRatio: false,
            cornerRadius: Theme.radius.xl,
            imageFit: ImageFit.Cover
          })
          Column()
            .width('100%')
            .height(160)
            .linearGradient({
              angle: 180,
              colors: [['rgba(27,42,65,0)', 0], ['rgba(27,42,65,0.75)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnInverse)
            .padding(Theme.space.s5)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s3 }) {
          Row({ space: Theme.space.s2 }) {
            Text(`${this.displayProgress}%`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandAccent)
            Text('完成度')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
          .width('100%')
          Stack({ alignContent: Alignment.Start }) {
            Row()
              .width('100%')
              .height(10)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
            Row()
              .width(this.displayProgress <= 0 ? '0%' : `${this.displayProgress}%`)
              .height(10)
              .backgroundColor(Theme.colors().success)
              .borderRadius(Theme.radius.pill)
          }
          .width('100%')
          Slider({
            value: this.displayProgress,
            min: 0,
            max: 100,
            step: 5,
            style: SliderStyle.OutSet
          })
            .width('100%')
            .blockColor(Theme.colors().brandPrimary)
            .trackColor(Theme.colors().surfaceSubtle)
            .selectedColor(Theme.colors().success)
            .onChange((value: number, mode: SliderChangeMode): void => {
              this.displayProgress = Math.round(value)
              if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
                void this.applyProgress(this.displayProgress)
              }
            })
          Text('拖动滑块或点按快捷按钮更新进度')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
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

        if (this.milestones.length > 0) {
          Column({ space: Theme.space.s3 }) {
            Text('里程碑')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.milestones, (m: Milestone) => {
              Column() {
                Row({ space: Theme.space.s3 }) {
                  Column() {
                    AppIcon({
                      name: this.isMilestoneDone(m.id) ? 'check' : 'empty',
                      iconSize: Theme.icon.md,
                      color: this.isMilestoneDone(m.id) ? Theme.colors().success : Theme.colors().textTertiary
                    })
                  }
                  .width(32)
                  .height(32)
                  .justifyContent(FlexAlign.Center)
                  Text(m.title)
                    .fontSize(Theme.type.callout)
                    .fontColor(this.isMilestoneDone(m.id) ? Theme.colors().textTertiary : Theme.colors().textPrimary)
                    .decoration({
                      type: this.isMilestoneDone(m.id) ? TextDecorationType.LineThrough : TextDecorationType.None
                    })
                    .layoutWeight(1)
                }
                .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .opacity(this.milestoneSaving ? 0.92 : 1)
              .onClick((): void => { this.toggleMilestoneById(m.id) })
            }, (m: Milestone) => `${m.id}_${this.isMilestoneDone(m.id) ? '1' : '0'}_${this.milestoneEpoch}`)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.linkedInspirations.length > 0) {
          Column({ space: Theme.space.s3 }) {
            Text('关联灵感')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.linkedInspirations, (insp: InspirationItem) => {
              Row({ space: Theme.space.s3 }) {
                Text(insp.title)
                  .fontSize(Theme.type.callout)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                  .maxLines(2)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { InspirationDetailNav.openInspiration(insp.id) })
            }, (insp: InspirationItem) => insp.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Row({ space: Theme.space.s3 }) {
          Column() {
            AppButton({
              label: '-10%',
              variant: 'secondary',
              disabled: this.updating || this.displayProgress <= 0,
              onTap: (): void => { void this.applyProgress(Math.max(0, this.displayProgress - 10)) }
            })
          }
          .layoutWeight(1)
          .onClick((): void => { void this.applyProgress(Math.max(0, this.displayProgress - 10)) })
          Column() {
            AppButton({
              label: this.updating ? '更新中…' : '+10%',
              disabled: this.updating || this.displayProgress >= 100,
              onTap: (): void => { void this.applyProgress(Math.min(100, this.displayProgress + 10)) }
            })
          }
          .layoutWeight(1)
          .onClick((): void => { void this.applyProgress(Math.min(100, this.displayProgress + 10)) })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppButton({
            label: '删除计划',
            variant: 'secondary',
            disabled: this.updating,
            onTap: (): void => { this.confirmDelete = true }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }

  @Builder
  DeleteConfirmOverlay() {
    Column({ space: Theme.space.s4 }) {
      Text('确定删除这项计划？')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
      Text('删除后无法恢复。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
        }
        .layoutWeight(1)
        Column() {
          AppButton({
            label: this.updating ? '删除中…' : '确认删除',
            disabled: this.updating,
            onTap: (): void => { void this.deletePlan() }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('88%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .zIndex(45)
  }
}
