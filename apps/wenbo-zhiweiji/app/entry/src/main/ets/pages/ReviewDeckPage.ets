import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CaptureItem } from '../models/ZhiweiModels'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct ReviewDeckPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('zwRev') @Watch('onRev') storeRev: number = 0
  @State queue: CaptureItem[] = []
  @State index: number = 0
  @State showBack: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.queue = ZhiweiStore.reviewQueue(30)
    if (this.index >= this.queue.length) {
      this.index = 0
    }
    this.showBack = false
  }

  private current(): CaptureItem | null {
    if (this.queue.length === 0 || this.index >= this.queue.length) {
      return null
    }
    return this.queue[this.index]
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async grade(days: number, mastered: boolean, label: string): Promise<void> {
    const row = this.current()
    if (row === null) {
      return
    }
    const ok = await ZhiweiStore.scheduleReview(row.id, days, mastered)
    if (ok) {
      this.showToast(`已标记「${label}」，${days} 天后再复习`)
      this.index += 1
      this.showBack = false
      if (this.index >= this.queue.length) {
        this.reload()
      }
      return
    }
    this.showToast('保存失败，请重试')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colorOf(this.themeEpoch).textPrimary })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick(() => ZhiweiNav.closeReviewDeck())
          Text('间隔复习')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.current() === null) {
          AppEmpty({
            title: '今日复习已完成',
            description: '把微知识标为「待学习」，或从每日一知收进知识库后，会进入复习队列。',
            actionLabel: '记微知识',
            onAction: (): void => {
              ZhiweiNav.closeReviewDeck()
              ZhiweiNav.openCompose('', false)
            }
          }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Text(`第 ${this.index + 1} / ${this.queue.length} 张`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                .width('100%')
              Column({ space: Theme.space.s3 }) {
                Text(this.showBack ? '正文' : '回忆标题')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                  .width('100%')
                Text(this.showBack ? this.current()!.body : this.current()!.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                  .width('100%')
                  .lineHeight(22)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick(() => { this.showBack = !this.showBack })

              if (!this.showBack) {
                AppButton({
                  label: '点我翻面看正文',
                  variant: 'secondary',
                  onTap: (): void => { this.showBack = true }
                })
              } else {
                Row({ space: 8 }) {
                  AppButton({
                    label: '记得 · 7天',
                    variant: 'primary',
                    onTap: (): void => { void this.grade(7, true, '记得') }
                  }).layoutWeight(1)
                }
                .width('100%')
                Row({ space: 8 }) {
                  AppButton({
                    label: '模糊 · 3天',
                    variant: 'secondary',
                    onTap: (): void => { void this.grade(3, false, '模糊') }
                  }).layoutWeight(1)
                  AppButton({
                    label: '忘了 · 1天',
                    variant: 'ghost',
                    onTap: (): void => { void this.grade(1, false, '忘了') }
                  }).layoutWeight(1)
                }
                .width('100%')
              }
              AppButton({
                label: '打开完整详情',
                variant: 'ghost',
                onTap: (): void => {
                  const id = this.current()!.id
                  ZhiweiNav.openCapture(id)
                }
              })
              Blank().height(Theme.space.s10)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.88)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
