import { Theme } from '../components/design-system/Theme'
import { AppGradientButton } from '../components/design-system/AppButton'
import { AppMetricTile } from '../components/design-system/AppStatCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { TrackListCard } from '../components/track/TrackListCard'
import { TrackRecord, ManualTrackDraft } from '../models/TrackModels'
import { TrackStore } from '../services/TrackStore'
import { ManualTrackService } from '../services/ManualTrackService'
import { TrackAnalytics } from '../services/TrackAnalytics'
import { TrackDetailNav } from '../services/TrackDetailNav'

@Component
export struct FootprintHomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '个人轨迹'
  @Prop tagline: string = ''
  @State recentItems: TrackRecord[] = []
  @State totalCount: number = 0
  @State totalKm: number = 0
  @State totalHours: number = 0
  @State showAddForm: boolean = false
  @State draft: ManualTrackDraft = ManualTrackService.emptyDraft()
  @State formError: string = ''
  @State toastText: string = ''
  onOpenMessages: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.recentItems = TrackStore.recent(4)
    const summary = TrackAnalytics.summarize()
    this.totalCount = summary.totalTracks
    this.totalKm = summary.totalDistanceKm
    this.totalHours = summary.totalDurationHours
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => {
      this.toastText = ''
    }, 2800)
  }

  private openAddForm(): void {
    this.draft = ManualTrackService.emptyDraft()
    this.formError = ''
    this.showAddForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeAddForm(): void {
    this.showAddForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async submitForm(): Promise<void> {
    const res = ManualTrackService.create(this.draft)
    if (!res.ok) {
      this.formError = res.message
      return
    }
    await TrackStore.save(res.record)
    this.closeAddForm()
    this.reload()
    this.showToast('足迹已保存 ✨')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: 0 }) {
          this.HeroSection()
          Column({ space: Theme.space.s5 }) {
            this.StatsFloatingCard()
            AppGradientButton({
              label: '＋ 记录新足迹',
              onTap: (): void => {
                this.openAddForm()
              }
            })

            if (this.recentItems.length === 0) {
              this.EmptyStateBlock()
            } else {
              this.RecentTimelineBlock()
            }

            this.MessagesBanner()
          }
          .padding(Theme.space.pageX)
          .margin({ top: -36 })
          .padding({ bottom: Theme.space.s10 + 24 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .edgeEffect(EdgeEffect.Spring)

      if (this.showAddForm) {
        this.AddFormSheet()
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 18, right: 18, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 52 })
          .zIndex(30)
          .shadow({
            radius: 12,
            color: 'rgba(0,0,0,0.18)',
            offsetY: 4
          })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear(() => {
      this.reload()
    })
  }

  @Builder
  HeroSection() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_map_trail'))
        .width('100%')
        .height(280)
        .objectFit(ImageFit.Cover)
      Column({ space: 0 })
        .width('100%')
        .height(280)
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(26,35,50,0.15)', 0.0],
            ['rgba(26,35,50,0.55)', 0.55],
            ['rgba(26,35,50,0.92)', 1.0]
          ]
        })
      Column({ space: 8 }) {
        Text('旅行杂志')
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor('rgba(255,252,249,0.75)')
          .letterSpacing(2)
        Text(this.appName)
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textOnInverse)
        Text(this.tagline.length > 0 ? this.tagline : '手动记录每一段路，无需定位')
          .fontSize(Theme.type.subhead)
          .fontColor('rgba(255,252,249,0.88)')
          .maxLines(2)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 52 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .clip(true)
    .borderRadius({ bottomLeft: Theme.radius.xl, bottomRight: Theme.radius.xl })
  }

  @Builder
  StatsFloatingCard() {
    Row() {
      AppMetricTile({ label: '足迹', value: `${this.totalCount}`, showDivider: true })
      AppMetricTile({ label: '里程 km', value: `${this.totalKm.toFixed(1)}`, showDivider: true })
      AppMetricTile({ label: '时长 h', value: `${this.totalHours.toFixed(1)}`, showDivider: false })
    }
    .width('100%')
    .padding({ top: Theme.space.s5, bottom: Theme.space.s5, left: Theme.space.s3, right: Theme.space.s3 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({
      radius: 24,
      color: Theme.isDark() ? 'rgba(0,0,0,0.35)' : 'rgba(26,35,50,0.10)',
      offsetY: 8
    })
  }

  @Builder
  EmptyStateBlock() {
    Column({ space: Theme.space.s4 }) {
      Image($r('app.media.ambient_empty'))
        .width('100%')
        .height(160)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column({ space: 8 }) {
        Text('还没有足迹')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text('写下第一段回忆，开启你的个人轨迹杂志。')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
  }

  @Builder
  RecentTimelineBlock() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('最近足迹')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text(`${this.recentItems.length} 条`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
      .width('100%')

      ForEach(this.recentItems, (item: TrackRecord, idx: number) => {
        TrackListCard({
          item: item,
          cardIndex: idx,
          onTap: (): void => {
            TrackDetailNav.open(item.id)
          }
        })
      }, (item: TrackRecord) => item.id)
    }
  }

  @Builder
  MessagesBanner() {
    Row({ space: Theme.space.s4 }) {
      Row() {
        AppIcon({ name: 'message', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)

      Column({ space: 4 }) {
        Text('机构通知')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text('版本更新 · 隐私说明 · 使用提示')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => {
      this.onOpenMessages()
    })
  }

  @Builder
  AddFormSheet() {
    Column() {
      Column()
        .width(40)
        .height(4)
        .backgroundColor(Theme.colors().strokeStrong)
        .borderRadius(Theme.radius.pill)
        .margin({ top: 10, bottom: 8 })

      Row({ space: Theme.space.s3 }) {
        Column({ space: 4 }) {
          Text('记录足迹')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('填写标题即可保存，其余选填')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text('取消')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding(8)
          .onClick(() => {
            this.closeAddForm()
          })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          this.FormField('标题 *', this.draft.title, '如：周末公园散步', true)
          this.FormField('地点', this.draft.placeName, '如：西湖 · 北山街', false)

          AppDatePickerField({
            label: '日期',
            value: this.draft.recordDate,
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string): void => {
              this.draft.recordDate = v
            }
          })

          Row({ space: Theme.space.s3 }) {
            Column({ space: 4 }) {
              this.FieldLabel('里程 km')
              this.StyledInput(this.draft.distanceKm, '3.5', (v: string): void => {
                this.draft.distanceKm = v
              })
            }
            .layoutWeight(1)
            Column({ space: 4 }) {
              this.FieldLabel('时长 分钟')
              this.StyledInput(this.draft.durationMin, '45', (v: string): void => {
                this.draft.durationMin = v
              })
            }
            .layoutWeight(1)
          }
          .width('100%')

          this.FieldLabel('备注')
          TextArea({ text: this.draft.note, placeholder: '写下当时的心情或见闻…' })
            .height(108)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
            .padding(Theme.space.s3)
            .onChange((v: string) => {
              this.draft.note = v
            })

          if (this.formError.length > 0) {
            Text(this.formError)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
              .width('100%')
          }

          AppGradientButton({
            label: '保存足迹',
            onTap: (): void => {
              void this.submitForm()
            }
          })
        }
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius({ topLeft: Theme.radius.sheet, topRight: Theme.radius.sheet })
    .zIndex(20)
  }

  @Builder
  FieldLabel(text: string) {
    Text(text)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      .width('100%')
  }

  @Builder
  StyledInput(value: string, placeholder: string, onChange: (v: string) => void) {
    TextInput({ text: value, placeholder: placeholder })
      .backgroundColor(Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.md)
      .padding({ left: 12, right: 12 })
      .onChange(onChange)
  }

  @Builder
  FormField(label: string, value: string, placeholder: string, required: boolean) {
    Column({ space: 4 }) {
      Row({ space: 4 }) {
        Text(label)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        if (required) {
          Text('*')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
      }
      .width('100%')
      TextInput({ text: value, placeholder: placeholder })
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.md)
        .padding({ left: 12, right: 12 })
        .onChange((v: string) => {
          if (label.indexOf('标题') >= 0) {
            this.draft.title = v
          } else if (label.indexOf('地点') >= 0) {
            this.draft.placeName = v
          }
        })
    }
    .width('100%')
  }
}
