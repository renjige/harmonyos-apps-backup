import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { ReviewQueueItem } from '../models/UserKnowledgeModels'
import { ReviewStore } from '../services/ReviewStore'
import { InfoRepository } from '../services/InfoRepository'
import { KnowledgeStore } from '../services/KnowledgeStore'
import { CheckInStore } from '../services/CheckInStore'
import { AchievementService } from '../services/AchievementService'
import { DailyTaskStore } from '../services/DailyTaskStore'
import { WanXiangDetailNav } from '../services/WanXiangDetailNav'
import { WanXiangNav } from '../services/WanXiangNav'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop bottomInset: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onDataChanged: () => void = () => {}
  @State queue: ReviewQueueItem[] = []
  @State current: ReviewQueueItem | undefined = undefined
  @State currentTitle: string = ''
  @State currentBody: string = ''
  @State streakDays: number = 0
  @State doneCount: number = 0
  @State loading: boolean = true
  @State toastText: string = ''
  @StorageLink('wanxiangStoreReady') @Watch('onStoreReady') storeReady: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onStoreReady(): void {
    if (this.storeReady) {
      void this.reload()
    }
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    await ReviewStore.ensureInitialQueue()
    this.queue = await ReviewStore.getQueue()
    this.streakDays = await CheckInStore.getStreakDays()
    this.doneCount = await ReviewStore.getDoneCount()
    if (this.queue.length > 0) {
      this.current = this.queue[0]
      await this.loadCurrentContent()
    } else {
      this.current = undefined
      this.currentTitle = ''
      this.currentBody = ''
    }
    this.loading = false
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => {
      this.toastText = ''
    }, 2400)
  }

  private async loadCurrentContent(): Promise<void> {
    if (this.current === undefined) {
      return
    }
    if (this.current.refType === 'info') {
      const item = InfoRepository.findById(this.current.refId)
      if (item !== undefined) {
        this.currentTitle = item.title
        this.currentBody = item.summary
      }
    } else {
      const k = await KnowledgeStore.findById(this.current.refId)
      if (k !== undefined) {
        this.currentTitle = k.title
        this.currentBody = k.body
      }
    }
  }

  private async remember(): Promise<void> {
    if (this.current === undefined) {
      return
    }
    await ReviewStore.rememberCurrent(this.current)
    await CheckInStore.checkInToday()
    await DailyTaskStore.markReview()
    const unlocked = await AchievementService.checkAll()
    if (unlocked.length > 0) {
      const def = AchievementService.defById(unlocked[unlocked.length - 1])
      if (def !== undefined) {
        this.showToast(`解锁成就：${def.title}`)
      }
    } else {
      this.showToast('已记住，进入下一条')
    }
    this.onDataChanged()
    await this.reload()
  }

  private async defer(): Promise<void> {
    if (this.current === undefined) {
      return
    }
    await ReviewStore.deferCurrent(this.current)
    this.showToast('已移至队列末尾')
    await this.reload()
  }

  private openCurrentDetail(): void {
    if (this.current === undefined) {
      return
    }
    if (this.current.refType === 'info') {
      WanXiangDetailNav.open(this.current.refId)
    } else {
      WanXiangNav.openKnowledge(this.current.refId)
    }
  }

  build() {
    Stack() {
      Column() {
        Column({ space: 4 }) {
          Text('复习')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text('温故知新，巩固你的阅读与知识')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        Row({ space: Theme.space.s2 }) {
          this.statPill(`连续 ${this.streakDays} 天`)
          this.statPill(`待复习 ${this.queue.length}`)
          this.statPill(`已完成 ${this.doneCount}`)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        if (this.queue.length === 0 || this.current === undefined) {
          AppEmpty({
            title: '复习队列已空',
            description: '收藏或稍后再读的内容会出现在这里',
            actionLabel: '去知识库',
            onAction: (): void => WanXiangNav.switchTab(1)
          }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              AppCard({ title: '今日复习' }) {
                Column({ space: Theme.space.s3 }) {
                  Text(this.currentTitle)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(this.currentBody)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .lineHeight(24)
                    .width('100%')
                  Text('查看完整内容 →')
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().brandPrimary)
                    .onClick((): void => this.openCurrentDetail())
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }

              Row({ space: Theme.space.s2 }) {
                Column() {
                  AppButton({
                    label: '记住了',
                    variant: 'primary',
                    onTap: (): void => { void this.remember() }
                  })
                }
                .layoutWeight(1)
                .onClick((): void => { void this.remember() })

                Column() {
                  AppButton({
                    label: '稍后再看',
                    variant: 'secondary',
                    onTap: (): void => { void this.defer() }
                  })
                }
                .layoutWeight(1)
                .onClick((): void => { void this.defer() })
              }
              .width('100%')
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: this.bottomInset + Theme.space.s8
            })
          }
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
          .padding({ left: 18, right: 18, top: 10, bottom: 10 })
          .backgroundColor('rgba(0,0,0,0.78)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  statPill(text: string) {
    Text(text)
      .fontSize(Theme.type.caption)
      .fontColor(Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
  }
}
