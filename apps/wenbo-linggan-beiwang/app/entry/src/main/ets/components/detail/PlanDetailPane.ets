import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { InspirationItem, UpdatePlanRequest } from '../../models/InspirationModels'
import { InspirationBizService } from '../../services/InspirationBizService'
import { InspirationMedia } from '../../services/InspirationMedia'
import { InspirationDetailNav } from '../../services/InspirationDetailNav'
import { AuthService } from '../../services/AuthService'
import { ConvertStep, InspirationConvertService } from '../../services/InspirationConvertService'
import { GrowthService } from '../../services/GrowthService'

@Component
export struct PlanDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @Prop @Watch('onItemIdChange') itemId: string = ''
  @Prop @Watch('onTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onPlanUpdated: () => void = () => {}
  @State item: InspirationItem | undefined = undefined
  @State loading: boolean = true
  @State updating: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  onTokenChange(): void {
    void this.loadItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await InspirationBizService.findCreativePlan(this.itemId)
    this.loading = false
    if (this.item !== undefined && AuthService.isLoggedIn()) {
      void GrowthService.recordBrowse(this.currentUsername, 'plan', this.item.id, this.item.title)
    }
  }

  private async bumpProgress(delta: number): Promise<void> {
    if (!AuthService.requireAuth('create_plan')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined || this.updating) {
      return
    }
    this.updating = true
    const next = Math.min(100, Math.max(0, this.item.progress + delta))
    const updated = await InspirationBizService.updateCreativePlanProgress(this.item.id, next)
    this.updating = false
    if (updated !== undefined) {
      this.item = updated
      this.onPlanUpdated()
      this.showToast(`进度已更新至 ${updated.progress}%`)
    } else {
      this.showToast(InspirationBizService.lastError.length > 0
        ? InspirationBizService.lastError
        : '更新失败，请稍后重试')
    }
  }

  private async toggleStep(index: number): Promise<void> {
    if (!AuthService.requireAuth('create_plan')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined || this.updating) {
      return
    }
    this.updating = true
    const nextGoal = InspirationConvertService.toggleGoal(this.item.goal, index)
    const req = new UpdatePlanRequest()
    req.title = this.item.title
    req.goal = nextGoal
    req.summary = this.item.summary
    req.progress = InspirationConvertService.progressFromGoal(nextGoal)
    const updated = await InspirationBizService.updateCreativePlan(this.item.id, req)
    this.updating = false
    if (updated !== undefined) {
      this.item = updated
      this.onPlanUpdated()
      this.showToast('转化步骤已更新')
    } else {
      this.showToast(InspirationBizService.lastError.length > 0
        ? InspirationBizService.lastError
        : '更新失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        this.BlockedPane('加载计划…', '正在打开创意计划')
      } else if (this.item === undefined) {
        this.BlockedPane('计划不存在', '可能已被删除或网络异常，可返回列表重试')
      } else {
        DetailShell({
          title: '创意计划',
          onClose: () => InspirationDetailNav.close(),
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
  BlockedPane(title: string, description: string) {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { InspirationDetailNav.close() })
        Blank()
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
      Column() {
        AppEmpty({
          title: title,
          description: description,
          actionLabel: '关闭',
          onAction: (): void => { InspirationDetailNav.close() }
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .onClick((): void => { InspirationDetailNav.close() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(InspirationMedia.coverMedia(
            this.item.coverKey.length > 0 ? this.item.coverKey : 'plan_default'
          ))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(180)
            .linearGradient({
              angle: 180,
              colors: [['rgba(27,42,65,0)', 0], ['rgba(27,42,65,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text('创意计划')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
              .width('100%')
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Row({ space: Theme.space.s2 }) {
            Text(`${this.item.progress}%`)
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
              .width(`${this.item.progress}%`)
              .height(10)
              .backgroundColor(Theme.colors().success)
              .borderRadius(Theme.radius.pill)
          }
          .width('100%')
        }
        .width('100%')

        AppCard({ title: '目标', variant: 'plain' }) {
          Text(InspirationConvertService.bodyOf(
            this.item.goal.length > 0 ? this.item.goal : this.item.summary
          ))
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .lineHeight(24)
        }

        Column({ space: Theme.space.s2 }) {
          Text('转化步骤')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(InspirationConvertService.stepsOf(this.item.goal), (step: ConvertStep) => {
            Row({ space: Theme.space.s3 }) {
              Text(step.done ? '已完成' : '待做')
                .fontSize(Theme.type.caption)
                .fontColor(step.done ? Theme.colors().success : Theme.colors().brandPrimary)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor(step.done
                  ? Theme.colors().brandPrimaryContainer
                  : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
              Text(step.label)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onClick((): void => { void this.toggleStep(step.index) })
          }, (step: ConvertStep) => `${step.index}`)
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          Column() {
            AppButton({
              label: '-10%',
              variant: 'secondary',
              disabled: this.updating || this.item.progress <= 0,
              onTap: (): void => { void this.bumpProgress(-10) }
            })
          }
          .layoutWeight(1)
          Column() {
            AppButton({
              label: this.updating ? '更新中…' : '+10%',
              disabled: this.updating || this.item.progress >= 100,
              onTap: (): void => { void this.bumpProgress(10) }
            })
          }
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
    }
  }
}
