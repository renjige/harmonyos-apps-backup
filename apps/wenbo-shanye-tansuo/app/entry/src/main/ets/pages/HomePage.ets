import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { TrailMatchCard } from '../components/mx/TrailMatchCard'
import { TipItem, TrailItem } from '../models/MxModels'
import { MxBizService } from '../services/MxBizService'
import { MxDetailNav } from '../services/MxDetailNav'
import { MxMedia } from '../services/MxMedia'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '山野探索'
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @StorageLink('prefDifficulty') prefDifficulty: string = '中级'
  @StorageLink('prefInterest') prefInterest: string = '地质'
  @StorageLink('prefDuration') prefDuration: string = 'half'
  @State trails: TrailItem[] = []
  @State matched: TrailItem[] = []
  @State todayTip: TipItem = new TipItem()
  @State hasToday: boolean = false
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.trails = await MxBizService.loadTrails('', '')
    const tips = await MxBizService.loadTips()
    const tip = MxBizService.todayTip(tips)
    this.hasToday = tip !== undefined
    if (tip !== undefined) {
      this.todayTip = tip
    }
    this.matched = MxBizService.matchTrails(
      this.trails,
      this.prefDifficulty,
      this.prefInterest,
      this.prefDuration
    )
    this.loading = false
  }

  private openFirstMatch(): void {
    if (this.matched.length > 0) {
      MxDetailNav.openTrail(this.matched[0].id)
    }
  }

  private durationLabel(): string {
    if (this.prefDuration === 'short') {
      return '短线'
    }
    if (this.prefDuration === 'long') {
      return '长线'
    }
    return '半日'
  }

  build() {
    Column() {
      if (this.loading) {
        AppLoading({ label: '对准山脊' })
      } else if (this.trails.length === 0 && !this.hasToday) {
        AppEmpty({
          title: '暂时读不到路线',
          description: '栏目来自平台，请检查网络后重试。',
          actionLabel: '重新加载',
          onAction: (): void => { void this.reload() }
        })
      } else {
        Scroll() {
          Column() {
            this.Hero()
            Column({ space: Theme.space.s5 }) {
              if (this.hasToday) {
                this.Inspiration()
              }
              this.MatchRow()
              this.EntryBlock()
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.s4,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Hero() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(MxMedia.resource('hero_ridge_compass'))
        .width('100%')
        .height(280)
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height(168)
        .linearGradient({
          angle: 180,
          colors: [['rgba(26,29,31,0)', 0], ['rgba(26,29,31,0.88)', 1]]
        })
      Column({ space: Theme.space.s3 }) {
        Text('把方向对准山脊')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width('100%')
        Text(this.appName)
          .fontSize(Theme.type.footnote)
          .fontColor('#F5F3F0')
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          Text('搜路线、看点或百科')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 12, bottom: 12 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onClick(() => MxDetailNav.openSearch())
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 18 })
      .width('100%')
    }
    .width('100%')
    .height(280)
  }

  @Builder
  Inspiration() {
    Column({ space: Theme.space.s2 }) {
      Text('今日灵感')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Column({ space: Theme.space.s2 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(MxMedia.resource(this.todayTip.coverKey))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.lg, topRight: Theme.radius.lg })
          Column()
            .width('100%')
            .height(72)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,29,31,0)', 0], ['rgba(26,29,31,0.78)', 1]]
            })
          Text(this.todayTip.categoryLabel())
            .fontSize(Theme.type.caption)
            .fontColor('#FFFFFF')
            .padding({ left: 14, bottom: 12 })
        }
        .width('100%')
        .height(168)
        Text(this.todayTip.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.todayTip.summary)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .width('100%')
      .padding({ bottom: Theme.space.s3, left: Theme.space.s3, right: Theme.space.s3 })
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onClick(() => MxDetailNav.openTip(this.todayTip.id))
    }
    .width('100%')
  }

  @Builder
  MatchRow() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text('智慧匹配')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('打开匹配路线')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => this.openFirstMatch())
      }
      .width('100%')
      Text(`${this.prefDifficulty} · ${this.prefInterest} · ${this.durationLabel()}`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Scroll() {
        Row({ space: Theme.space.s3 }) {
          ForEach(this.matched, (t: TrailItem) => {
            TrailMatchCard({
              item: t,
              onTap: (): void => MxDetailNav.openTrail(t.id)
            })
          }, (t: TrailItem) => t.id)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height(176)
    }
    .width('100%')
  }

  @Builder
  EntryBlock() {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s3 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(MxMedia.resource('trail_ridge_dawn'))
            .width('100%')
            .height(148)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          Column()
            .width('100%')
            .height(80)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,29,31,0)', 0], ['rgba(26,29,31,0.82)', 1]]
            })
            .borderRadius({ bottomLeft: Theme.radius.lg, bottomRight: Theme.radius.lg })
          Column({ space: 2 }) {
            Text('路线图鉴')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
            Text('按难度翻开')
              .fontSize(Theme.type.caption)
              .fontColor('#F5F3F0')
          }
          .padding({ left: 12, bottom: 12 })
        }
        .layoutWeight(3)
        .height(148)
        .onClick(() => MxDetailNav.switchTabTrails())

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(MxMedia.resource('wiki_pine_needle'))
            .width('100%')
            .height(148)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          Column()
            .width('100%')
            .height(80)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,29,31,0)', 0], ['rgba(26,29,31,0.82)', 1]]
            })
            .borderRadius({ bottomLeft: Theme.radius.lg, bottomRight: Theme.radius.lg })
          Column({ space: 2 }) {
            Text('百科馆')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
            Text('植物到星空')
              .fontSize(Theme.type.caption)
              .fontColor('#F5F3F0')
          }
          .padding({ left: 12, bottom: 12 })
        }
        .layoutWeight(2)
        .height(148)
        .onClick(() => MxDetailNav.switchTabWiki())
      }
      .width('100%')

      Row({ space: Theme.space.s3 }) {
        AppIcon({ name: 'check', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
        Column({ space: 2 }) {
          Text('山野准备自检')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandOnPrimary)
          Text('问卷匹配一条可走的线')
            .fontSize(Theme.type.caption)
            .fontColor('#F5F3F0')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().brandOnPrimary })
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.colors().brandDeep)
      .borderRadius(Theme.radius.lg)
      .onClick(() => MxDetailNav.openDiagnose())
    }
    .width('100%')
  }
}
