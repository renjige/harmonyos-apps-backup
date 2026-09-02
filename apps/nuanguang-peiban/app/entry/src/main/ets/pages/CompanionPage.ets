import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppCard } from '../components/design-system/AppCard'
import { BreathModeCard } from '../components/warm/BreathModeCard'
import { NoiseTrackCard } from '../components/warm/NoiseTrackCard'
import { WarmMediaCover } from '../components/warm/WarmMediaHero'
import { BreathModeItem, NoiseTrackItem, QuoteItem } from '../models/WarmCompanionModels'
import { WarmCompanionBizService } from '../services/WarmCompanionBizService'
import { WarmCompanionNav } from '../services/WarmCompanionNav'

@Component
export struct CompanionPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @State segment: number = 0
  @State modes: BreathModeItem[] = []
  @State noises: NoiseTrackItem[] = []
  @State quotes: QuoteItem[] = []
  @State quoteIndex: number = 0
  @State activeNoiseId: string = ''
  @State loading: boolean = true
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2400)
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.modes = await WarmCompanionBizService.loadBreathModes()
    this.noises = await WarmCompanionBizService.loadNoiseTracks()
    this.quotes = await WarmCompanionBizService.loadQuotes()
    if (this.quotes.length > 0 && this.quoteIndex >= this.quotes.length) {
      this.quoteIndex = 0
    }
    this.loading = false
  }

  private currentQuote(): QuoteItem | undefined {
    if (this.quotes.length === 0) {
      return undefined
    }
    return this.quotes[this.quoteIndex]
  }

  private shiftQuote(delta: number): void {
    if (this.quotes.length === 0) {
      return
    }
    let next = this.quoteIndex + delta
    if (next < 0) {
      next = this.quotes.length - 1
    } else if (next >= this.quotes.length) {
      next = 0
    }
    this.quoteIndex = next
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s3 }) {
          Column() {
            AppIcon({ name: 'heart', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .linearGradient({
            angle: 135,
            colors: [[Theme.colors().brandPrimary, 0], [Theme.colors().brandAccent, 1]]
          })
          .borderRadius(Theme.radius.lg)
          Column({ space: 4 }) {
            Text('🕯 陪伴时光')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text('呼吸引导 · 白噪音 · 暖心语录')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

        Row({ space: Theme.space.s2 }) {
          this.SegmentChip('呼吸引导', 0)
          this.SegmentChip('白噪音', 1)
          this.SegmentChip('暖心语录', 2)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

        if (this.loading) {
          AppLoading({ label: '读取陪伴内容' })
        } else if (this.segment === 0) {
          this.BreathSegment()
        } else if (this.segment === 1) {
          this.NoiseSegment()
        } else {
          this.QuoteSegment()
        }
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
        .padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SegmentChip(label: string, index: number) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontWeight(this.segment === index ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.segment === index ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.segment === index ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick(() => { this.segment = index })
  }

  @Builder
  BreathSegment() {
    if (this.modes.length === 0) {
      AppEmpty({
        title: '暂无呼吸模式',
        description: '请检查网络后重试。模式来自平台配置。',
        actionLabel: '重新加载',
        iconName: 'heart',
        emojiMark: '🧘',
        onAction: (): void => { void this.reload() }
      })
    } else {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text('跟随光晕节奏吸 · 屏 · 呼，练完自动记时。')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          ForEach(this.modes, (m: BreathModeItem) => {
            BreathModeCard({
              item: m,
              onTap: (): void => WarmCompanionNav.openBreathMode(m.id)
            })
          }, (m: BreathModeItem) => m.id)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }

  @Builder
  NoiseSegment() {
    if (this.noises.length === 0) {
      AppEmpty({
        title: '暂无白噪音',
        description: '请检查网络后重试。',
        actionLabel: '重新加载',
        iconName: 'heart',
        emojiMark: '🌊',
        onAction: (): void => { void this.reload() }
      })
    } else {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('选择一种环境音，帮助放松与专注（示意播放，无后台音频）。')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.noises, (n: NoiseTrackItem) => {
              NoiseTrackCard({
                item: n,
                active: this.activeNoiseId === n.id,
                onTap: (): void => {
                  this.activeNoiseId = n.id
                  this.showToast(`已选择 ${n.title}`)
                }
              })
            }, (n: NoiseTrackItem) => n.id)
          }
          .width('100%')
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }

  @Builder
  QuoteSegment() {
    if (this.quotes.length === 0) {
      AppEmpty({
        title: '暂无暖心语录',
        description: '请检查网络后重试。语录来自平台配置。',
        actionLabel: '重新加载',
        iconName: 'book',
        emojiMark: '📖',
        onAction: (): void => { void this.reload() }
      })
    } else {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppCard({ title: '💛 滑动浏览', variant: 'plain' }) {
            Column({ space: Theme.space.s3 }) {
              if (this.currentQuote() !== undefined) {
                WarmMediaCover({
                  coverKey: this.currentQuote()!.coverKey.length > 0 ?
                    this.currentQuote()!.coverKey : 'cover_quote_cozy',
                  tileSize: 120,
                  cornerRadius: Theme.radius.lg
                })
                Text(this.currentQuote()!.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(this.currentQuote()!.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              Row({ space: Theme.space.s3 }) {
                Column() {
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                }
                .width(44)
                .height(44)
                .justifyContent(FlexAlign.Center)
                .rotate({ angle: 180 })
                .onClick(() => this.shiftQuote(-1))
                Text(`${this.quoteIndex + 1} / ${this.quotes.length}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                Column() {
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                }
                .width(44)
                .height(44)
                .justifyContent(FlexAlign.Center)
                .onClick(() => this.shiftQuote(1))
              }
              .width('100%')
              if (this.currentQuote() !== undefined) {
                Row() {
                  Text('阅读全文')
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .onClick((): void => {
                      if (this.currentQuote() !== undefined) {
                        WarmCompanionNav.openQuote(this.currentQuote()!.id)
                      }
                    })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
              }
            }
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }
}
