import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { ReadingListCard } from '../components/reading/ReadingListCard'
import { CheckinItem, CreateCheckinRequest } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'
import { ReadingMedia } from '../services/ReadingMedia'
import { AuthService } from '../services/AuthService'

@Component
export struct CheckinPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  @State items: CheckinItem[] = []
  @State streakDays: number = 0
  @State checkedToday: boolean = false
  @State submitting: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private todayIso(): string {
    return new Date().toISOString().slice(0, 10)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    const feed = await ReadingBizService.loadCheckinFeed()
    this.streakDays = feed.streakDays
    this.checkedToday = feed.checkedToday
    this.items = ReadingBizService.mapCheckins(feed.list)
  }

  private async punch(minutes: number): Promise<void> {
    if (!AuthService.requireAuth('create_book')) {
      this.onRequireAuth()
      return
    }
    if (this.submitting) {
      return
    }
    this.submitting = true
    const req = new CreateCheckinRequest()
    req.title = `${this.todayIso()} 阅读打卡`
    req.readingMinutes = minutes
    req.recordDate = this.todayIso()
    const wasChecked = this.checkedToday
    const created = await ReadingBizService.createCheckin(req)
    this.submitting = false
    if (created !== undefined) {
      this.onChanged()
      await this.reload()
      this.showToast(wasChecked ? `时长已累计 +${minutes} 分钟` : `已打卡 ${minutes} 分钟`)
      return
    }
    this.showToast('打卡失败，请稍后重试')
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text('每日阅读打卡')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Image(ReadingMedia.coverMedia('checkin_morning'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Row({ space: Theme.space.s3 }) {
              AppStatCard({
                label: '连续天数',
                value: `${this.streakDays}`,
                trend: '天',
                positive: true
              }).layoutWeight(1)
              AppStatCard({
                label: '累计打卡',
                value: `${this.items.length}`,
                trend: '次',
                positive: true
              }).layoutWeight(1)
            }
            .width('100%')
            Text(this.checkedToday ? '今天已经打过卡，还可以再记一笔时长。' : '选一个时长完成今日打卡，连续记录会显示在首页。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: this.submitting ? '打卡中…' : '打卡 15 分钟',
              disabled: this.submitting,
              onTap: (): void => { void this.punch(15) }
            })
            AppButton({
              label: '打卡 25 分钟',
              variant: 'secondary',
              disabled: this.submitting,
              onTap: (): void => { void this.punch(25) }
            })
            AppButton({
              label: '打卡 45 分钟',
              variant: 'secondary',
              disabled: this.submitting,
              onTap: (): void => { void this.punch(45) }
            })
            Text('打卡记录')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.items.length === 0) {
              AppEmpty({
                title: '还没有打卡',
                description: '完成第一次打卡后，这里会留下连续阅读足迹',
                actionLabel: '打卡 25 分钟',
                onAction: (): void => { void this.punch(25) }
              })
            } else {
              ForEach(this.items, (item: CheckinItem) => {
                ReadingListCard({
                  title: item.title,
                  summary: `阅读 ${item.readingMinutes} 分钟`,
                  coverKey: 'checkin_morning',
                  meta: item.recordDate,
                  compact: true,
                  onTap: (): void => { ReadingDetailNav.openCheckin(item.id) }
                })
              }, (item: CheckinItem) => item.id)
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

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
}
