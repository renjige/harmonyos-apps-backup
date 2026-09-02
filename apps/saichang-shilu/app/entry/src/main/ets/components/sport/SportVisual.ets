import { Theme } from '../design-system/Theme'

@Component
export struct SectionHeader {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop action: string = ''
  onAction: () => void = () => {}

  build() {
    Row() {
      Text(this.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Blank()
      if (this.action.length > 0) {
        Text(this.action)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onAction() })
      }
    }
    .width('100%')
  }
}

@Component
export struct ExploreTile {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop emoji: string = ''
  @Prop accent: string = '#0B6BCB'
  onTap: () => void = () => {}

  build() {
    Column({ space: 6 }) {
      Text(this.emoji)
        .fontSize(22)
      Text(this.title)
        .fontSize(Theme.type.bodyS)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
      Text(this.subtitle)
        .fontSize(Theme.type.caption)
        .fontColor('rgba(255,255,255,0.88)')
        .maxLines(2)
    }
    .width('47%')
    .height(96)
    .padding(Theme.space.s4)
    .margin({ right: '3%', bottom: 10 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .borderRadius(Theme.radius.lg)
    .linearGradient({
      angle: 135,
      colors: [[this.accent, 0], [Theme.colors().brandDeep, 1]]
    })
    .shadow({ radius: 8, color: 'rgba(15,23,42,0.12)', offsetY: 3 })
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct EditorialSwiper {
  @State index: number = 0

  build() {
    Swiper() {
      this.BannerSlide($r('app.media.hero_sport_track'), '今日赛场', '把每一场值得记住的比赛收进档案', '#0B6BCB')
      this.BannerSlide($r('app.media.banner_monthly'), '本月精彩', '复盘关键节点，沉淀观赛记忆', '#FF6B35')
    }
    .width('100%')
    .height(176)
    .borderRadius(Theme.radius.xl)
    .indicator(
      new DotIndicator()
        .selectedColor('#FFFFFF')
        .color('rgba(255,255,255,0.45)')
        .bottom(10)
    )
    .autoPlay(true)
    .interval(4800)
    .curve(Curve.EaseInOut)
  }

  @Builder
  BannerSlide(img: Resource, tag: string, line: string, accent: string) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(img)
        .width('100%')
        .height(176)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column() {
        Blank()
        Column({ space: 4 }) {
          Text(tag)
            .fontSize(Theme.type.caption)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor(accent)
            .borderRadius(Theme.radius.pill)
          Text(line)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .maxLines(2)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0)', 0], ['rgba(10,37,64,0.92)', 1]]
        })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height(176)
  }
}

@Component
export struct StarRow {
  @Prop rating: number = 0
  @Prop maxStars: number = 5

  build() {
    Row({ space: 2 }) {
      ForEach(this.starList(), (filled: boolean, idx: number) => {
        Text(filled ? '★' : '☆')
          .fontSize(12)
          .fontColor(filled ? '#F59E0B' : Theme.colors().strokeStrong)
      }, (_filled: boolean, idx: number) => `star-${idx}`)
    }
  }

  private starList(): boolean[] {
    const out: boolean[] = []
    for (let i = 1; i <= this.maxStars; i++) {
      out.push(i <= this.rating)
    }
    return out
  }
}

@Component
export struct StatusBadge {
  @Prop label: string = ''
  @Prop tone: string = 'default'

  private bg(): string {
    if (this.tone === 'want') {
      return Theme.colors().warningContainer
    }
    if (this.tone === 'focus') {
      return Theme.colors().brandPrimaryContainer
    }
    if (this.tone === 'watched') {
      return Theme.colors().successContainer
    }
    return Theme.colors().surfaceSubtle
  }

  private fg(): string {
    if (this.tone === 'want') {
      return Theme.colors().warning
    }
    if (this.tone === 'focus') {
      return Theme.colors().brandPrimary
    }
    if (this.tone === 'watched') {
      return Theme.colors().success
    }
    return Theme.colors().textSecondary
  }

  build() {
    Text(this.label)
      .fontSize(Theme.type.caption)
      .fontColor(this.fg())
      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
      .backgroundColor(this.bg())
      .borderRadius(Theme.radius.pill)
  }
}
