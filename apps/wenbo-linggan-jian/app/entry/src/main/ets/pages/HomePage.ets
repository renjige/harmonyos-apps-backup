import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { InspirationListCard } from '../components/slip/InspirationListCard'
import { NoteItem, OrganizeHint } from '../models/SlipModels'
import { SlipStore } from '../services/SlipStore'
import { SlipBizService } from '../services/SlipBizService'
import { SlipDateUtil } from '../services/SlipDateUtil'
import { SlipNav } from '../services/SlipNav'
import { SlipMedia } from '../services/SlipMedia'
import { OrganizeService } from '../services/OrganizeService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '灵感笺'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onOpenLibrary: () => void = () => {}
  @State quoteLine: string = '把一闪而过的想法，变成值得收藏的灵感。'
  @State recent: NoteItem[] = []
  @State todayCount: number = 0
  @State hint: OrganizeHint = new OrganizeHint()
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.recent = SlipStore.todayItems()
    if (this.recent.length === 0) {
      this.recent = SlipStore.recent(3)
    }
    this.todayCount = SlipStore.todayItems().length
    this.hint = OrganizeService.hintForToday()
    const daily = await SlipBizService.loadDaily()
    if (daily.quote !== null) {
      const q = daily.quote.body.length > 0 ? daily.quote.body : daily.quote.summary
      if (q.length > 0) {
        this.quoteLine = q
      }
    }
  }

  private greeting(): string {
    return '你好，今天也记下一点灵感吧'
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Row() {
            Text(this.appName)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Column() {
              AppIcon({ name: 'search', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => {
              SlipNav.openSearch()
              this.onOpenLibrary()
            })
          }
          .width('100%')

          Column({ space: 8 }) {
            Text(this.greeting())
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(SlipDateUtil.homeDate(new Date()))
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')

          Stack({ alignContent: Alignment.BottomStart }) {
            Image(SlipMedia.cover('hero_paper_window'))
              .width('100%')
              .height(168)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(80)
              .borderRadius({ bottomLeft: Theme.radius.xl, bottomRight: Theme.radius.xl })
              .linearGradient({
                angle: 180,
                colors: [['rgba(24,35,58,0)', 0], ['rgba(24,35,58,0.55)', 1]]
              })
            Text(this.quoteLine)
              .fontSize(Theme.type.footnote)
              .fontColor('#F7F3EA')
              .padding({ left: 16, right: 16, bottom: 14 })
              .maxLines(2)
          }
          .width('100%')
          .clip(true)

          Column({ space: 10 }) {
            AppButton({
              label: '＋ 记录灵感',
              onTap: (): void => { SlipNav.openWrite('') }
            })
            Text(this.todayCount > 0 ? `今日已有 ${this.todayCount} 条灵感` : '今天还没有灵感')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)

          Row() {
            Text('今日灵感')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Text('全部')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick((): void => { this.onOpenLibrary() })
          }
          .width('100%')

          if (this.recent.length === 0) {
            AppEmpty({
              title: '今天还没有灵感',
              description: '记录一个小想法，让今天留下痕迹。',
              actionLabel: '记录灵感',
              onAction: (): void => { SlipNav.openWrite('') }
            })
          } else {
            ForEach(this.recent, (n: NoteItem) => {
              InspirationListCard({
                item: n,
                compact: true,
                onTap: (): void => { SlipNav.openDetail(n.id) }
              })
            }, (n: NoteItem) => n.id)
          }

          Column({ space: 10 }) {
            Text('智慧整理')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.hint.message)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            if (this.hint.actionLabel.length > 0) {
              AppButton({
                label: this.hint.actionLabel,
                variant: 'secondary',
                onTap: (): void => { void this.applyHint() }
              })
            }
          }
          .width('100%')
          .padding(Theme.space.s4)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
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
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  private async applyHint(): Promise<void> {
    const ok = await OrganizeService.applyTopTag()
    this.hint = OrganizeService.hintForToday()
    this.toastText = ok ? '已按标签轻轻归类未分类的今日灵感' : '没有需要整理的条目'
    setTimeout(() => { this.toastText = '' }, 2200)
  }
}
