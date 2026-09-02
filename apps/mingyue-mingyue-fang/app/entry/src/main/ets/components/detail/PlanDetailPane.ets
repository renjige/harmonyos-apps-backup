import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { PatchPlanRequest, PlanItem } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'
import { ReadingMedia } from '../../services/ReadingMedia'
import { ReadingDetailNav } from '../../services/ReadingDetailNav'
import { AuthService } from '../../services/AuthService'
import { ReadingProgressBar } from '../reading/ReadingProgressBar'

@Component
export struct PlanDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onOpenReport: () => void = () => {}
  onProgressUpdated: () => void = () => {}
  @State item: PlanItem | undefined = undefined
  @State loading: boolean = true
  @State updating: boolean = false
  @State viewProgress: number = 0
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

  private applyLocalProgress(next: number): void {
    this.viewProgress = next
    if (this.item !== undefined) {
      this.item.progress = next
    }
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await ReadingBizService.findPlan(this.itemId)
    if (this.item !== undefined) {
      this.viewProgress = this.item.progress
    }
    this.loading = false
  }

  private async handleUpdateProgress(): Promise<void> {
    if (!AuthService.requireAuth('create_plan')) {
      this.onRequireAuth()
      return
    }
    if (this.updating || this.item === undefined) {
      return
    }
    const prevProgress = this.viewProgress
    const nextProgress = prevProgress >= 100 ? 100 : prevProgress + 10
    this.applyLocalProgress(nextProgress)
    this.updating = true
    const req = new PatchPlanRequest()
    req.progress = nextProgress
    try {
      const updated = await ReadingBizService.patchPlan(this.item.id, req)
      if (updated !== undefined) {
        this.applyLocalProgress(updated.progress)
        this.onProgressUpdated()
        this.showToast(`计划进度已更新至 ${this.viewProgress}%`)
      } else {
        this.applyLocalProgress(prevProgress)
        const msg = ReadingBizService.lastError
        this.showToast(msg.length > 0 ? msg : '更新失败，请稍后重试')
      }
    } catch {
      this.applyLocalProgress(prevProgress)
      this.showToast('更新失败，请稍后重试')
    }
    this.updating = false
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载计划…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '计划不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '阅读计划',
          revision: this.viewProgress,
          onClose: (): void => { ReadingDetailNav.close() },
          body: (): void => { this.DetailBody() }
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
      this.PlanBody(this.item)
    }
  }

  @Builder
  PlanBody(plan: PlanItem) {
    Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(ReadingMedia.coverMedia('hero_reading_desk'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(160)
            .linearGradient({
              angle: 180,
              colors: [['rgba(45,90,74,0)', 0], ['rgba(45,90,74,0.82)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(`进度 ${this.viewProgress}%`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
            Text(plan.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          ReadingProgressBar({ percent: this.viewProgress })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '目标', variant: 'plain' }) {
            Text(plan.goal.length > 0 ? plan.goal : plan.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppButton({
            label: this.updating ? '正在更新…' : '更新计划进度 +10%',
            onTap: (): void => { void this.handleUpdateProgress() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppButton({
            label: '查看阅读报告',
            variant: 'secondary',
            onTap: (): void => {
              ReadingDetailNav.close()
              this.onOpenReport()
            }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
  }
}
