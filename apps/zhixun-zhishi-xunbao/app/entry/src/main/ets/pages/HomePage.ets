import { Theme } from '../components/design-system/Theme'
import { AppError } from '../components/design-system/AppError'
import { CoverHero, MapGridCard, StatChip } from '../components/quest/QuestCards'
import { QuestMap } from '../models/QuestModels'
import { QuestBizService } from '../services/QuestBizService'
import { QuestNav } from '../services/QuestNav'
import { ProgressStore } from '../services/ProgressStore'
import { QuestMedia } from '../services/QuestMedia'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State recommended: QuestMap[] = []
  @State hot: QuestMap[] = []
  @State loading: boolean = true
  @State failed: boolean = false
  @State errorHint: string = ''
  @State dateLabel: string = ''
  @State checked: boolean = false
  @State toast: string = ''
  @StorageLink('questTick') tick: number = 0
  @StorageLink('wisdomValue') wisdomValue: number = 0
  @StorageLink('treasureCount') treasureCount: number = 0
  @StorageLink('streakDays') streakDays: number = 0

  aboutToAppear(): void {
    this.dateLabel = ProgressStore.dateLabel()
    this.checked = ProgressStore.hasCheckedInToday()
    void this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    try {
      this.recommended = await QuestBizService.loadRecommended()
      this.hot = await QuestBizService.loadHot()
      this.failed = this.recommended.length === 0 && this.hot.length === 0
      this.errorHint = QuestBizService.lastHint
    } catch {
      this.failed = true
      this.errorHint = QuestBizService.lastHint
    }
    this.loading = false
  }

  private async doCheckIn(): Promise<void> {
    const ok = await ProgressStore.checkIn()
    this.checked = ProgressStore.hasCheckedInToday()
    this.toast = ok ? '今日智慧已领取 +8' : '今天已经签到过了'
    setTimeout(() => { this.toast = '' }, 2200)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          CoverHero({
            coverKey: 'hero_discover',
            title: '知识寻宝',
            subtitle: `${this.dateLabel} · 智慧值 ${this.wisdomValue}`,
            heroHeight: 210
          })

          Row({ space: 8 }) {
            StatChip({ label: '智慧值', value: `${this.wisdomValue}` })
            StatChip({ label: '宝藏', value: `${this.treasureCount}` })
            StatChip({ label: '连续签到', value: `${this.streakDays}天` })
          }
          .width('100%')

          Row() {
            Column({ space: 4 }) {
              Text(this.checked ? '今日已领取智慧' : '每日签到')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(this.checked ? '明天再来，连续天数会累积' : '领取 8 点智慧值，连续签到点亮徽章')
                .fontSize(12)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            Text(this.checked ? '已签到' : '领取')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.checked ? Theme.colors().textSecondary : Theme.colors().brandOnPrimary)
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
              .backgroundColor(this.checked ? Theme.colors().surfaceSubtle : Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
              .constraintSize({ minHeight: 44 })
              .onClick(() => { void this.doCheckIn() })
          }
          .width('100%')
          .padding(14)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Swiper() {
            Image(QuestMedia.cover('banner_01'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
              .onClick(() => {
                let id = ''
                for (const m of this.recommended) {
                  id = m.id
                  break
                }
                if (id.length > 0) {
                  QuestNav.openMap(id)
                }
              })
            Image(QuestMedia.cover('banner_02'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
              .onClick(() => AppStorage.setOrCreate('mainTab', 1))
          }
          .height(140)
          .autoPlay(true)
          .interval(4200)
          .indicator(true)

          Row() {
            Text('今日推荐')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Text('全部地图')
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick(() => AppStorage.setOrCreate('mainTab', 1))
          }
          .width('100%')

          if (this.failed && !this.loading) {
            AppError({
              title: '推荐地图暂时无法加载',
              message: this.errorHint.length > 0 ? this.errorHint : '请检查网络后重试',
              retryLabel: '重试',
              onRetry: () => { void this.reload() }
            })
          } else {
            Grid() {
              ForEach(this.hot, (m: QuestMap) => {
                GridItem() {
                  MapGridCard({
                    title: m.title,
                    coverKey: m.coverKey,
                    meta: `${m.categoryLabel} · ${QuestBizService.difficultyStars(m)}`,
                    done: ProgressStore.isCompleted(m.id),
                    onTap: () => QuestNav.openMap(m.id)
                  })
                }
              }, (m: QuestMap) => m.id)
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(10)
            .rowsGap(10)
            .width('100%')
          }

          Text('消息中心')
            .fontSize(13)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
            .onClick(() => QuestNav.openMessages())
        }
        .padding({ left: 16, right: 16, top: 12, bottom: Theme.space.s10 })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('100%')

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(45,27,105,0.92)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 24 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
