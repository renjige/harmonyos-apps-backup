import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AppIcon } from '../design-system/AppIcon'
import { DetailShell } from './DetailShell'
import { HandcraftWork } from '../../models/HandcraftModels'
import { HandcraftBizService } from '../../services/HandcraftBizService'
import { CraftMedia } from '../../services/CraftMedia'
import { CraftDetailNav } from '../../services/CraftDetailNav'
import { WorkshopStore } from '../../services/WorkshopStore'
import { ChecklistItem } from '../../services/WorkshopStore'
import { CraftLocalStore } from '../../services/CraftLocalStore'

@Component
export struct GuideDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop guideId: string = ''
  onGoCreate: () => void = () => {}
  @State guide: HandcraftWork | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.loadGuide()
  }

  private async loadGuide(): Promise<void> {
    this.loading = true
    this.guide = await HandcraftBizService.findGuide(this.guideId)
    if (this.guide !== undefined) {
      void CraftLocalStore.setLastGuide(this.guide.id, this.guide.title)
    }
    this.loading = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async handleStartTimer(): Promise<void> {
    await WorkshopStore.startOrResume()
    this.showToast('已启动制作计时，可在创作 → 制作助手查看')
  }

  private async syncGuideStepsToChecklist(): Promise<void> {
    if (this.guide === undefined || this.guide.steps.length === 0) {
      return
    }
    const next: ChecklistItem[] = []
    for (let i = 0; i < this.guide.steps.length; i++) {
      const item = new ChecklistItem()
      item.id = `g_${this.guide.id}_${i}`
      item.text = this.guide.steps[i]
      item.done = false
      next.push(item)
    }
    await WorkshopStore.saveChecklist(next)
  }

  private async handleGoCreate(): Promise<void> {
    if (this.guide !== undefined) {
      void CraftLocalStore.setLastGuide(this.guide.id, this.guide.title)
      AppStorage.setOrCreate('guideFollowTitle', this.guide.title)
      AppStorage.setOrCreate('guideFollowCategory', this.guide.category)
      AppStorage.setOrCreate('guideFollowCover', this.guide.coverKey)
      await this.syncGuideStepsToChecklist()
    }
    CraftDetailNav.goCreateTab()
    this.onGoCreate()
    this.showToast('已跳转创作页，步骤已写入制作助手清单')
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载教程…' })
      } else if (this.guide === undefined) {
        AppEmpty({ title: '教程不存在', description: '请返回重试' })
      } else {
        DetailShell({
          title: this.guide.title,
          onClose: (): void => { CraftDetailNav.closeGuide() },
          body: (): void => { this.GuideBody() }
        })
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
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
  GuideBody() {
    if (this.guide === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(CraftMedia.byKey(this.guide.coverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(61,58,54,0)', 0], ['rgba(61,58,54,0.72)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(this.guide.category)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.guide.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s3 }) {
          Column() {
            AppButton({
              label: '去创作页跟做',
              variant: 'primary',
              onTap: (): void => { void this.handleGoCreate() }
            })
          }.layoutWeight(1)
          .onClick((): void => { void this.handleGoCreate() })
          Column() {
            AppButton({
              label: '启动计时',
              variant: 'secondary',
              onTap: (): void => { void this.handleStartTimer() }
            })
          }.layoutWeight(1)
          .onClick((): void => { void this.handleStartTimer() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '教程摘要', variant: 'plain' }) {
            Text(this.guide.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '详细说明', variant: 'plain' }) {
            Text(this.guide.description)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.guide.materials.length > 0) {
          Column() {
            AppCard({ title: '所需材料', variant: 'outlined' }) {
              Column({ space: 6 }) {
                ForEach(this.guide.materials, (m: string) => {
                  Row({ space: 8 }) {
                    AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: Theme.colors().brandDeep })
                    Text(m).fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  }.width('100%')
                }, (m: string) => m)
              }.width('100%')
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.guide.steps.length > 0) {
          Column() {
            AppCard({ title: '步骤指引', variant: 'outlined' }) {
              Column({ space: 10 }) {
                ForEach(this.guide.steps, (step: string, idx: number) => {
                  Row({ space: 10 }) {
                    Text(`${idx + 1}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandOnPrimary)
                      .textAlign(TextAlign.Center)
                      .width(24)
                      .height(24)
                      .backgroundColor(Theme.colors().brandDeep)
                      .borderRadius(Theme.radius.pill)
                    Text(step)
                      .fontSize(Theme.type.body)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .layoutWeight(1)
                      .lineHeight(22)
                  }.width('100%').alignItems(VerticalAlign.Top)
                }, (step: string, idx: number) => `${idx}_${step}`)
              }.width('100%')
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
      }
    }
  }
}
