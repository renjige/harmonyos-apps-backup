import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { PoetryMedia } from '../../services/PoetryMedia'

@Component
export struct CoverHero {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop coverKey: string = 'hero_ink'
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop heroHeight: number = 220

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(PoetryMedia.cover(this.coverKey))
        .width('100%')
        .height(this.heroHeight)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
      Column()
        .width('100%')
        .height(110)
        .linearGradient({
          angle: 180,
          colors: [['rgba(28,40,51,0)', 0], ['rgba(28,40,51,0.82)', 1]]
        })
        .borderRadius({ bottomLeft: Theme.radius.lg, bottomRight: Theme.radius.lg })
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F8F4ED')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(13)
            .fontColor('#F0E8DC')
        }
      }
      .padding({ left: 16, right: 16, bottom: 16 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(this.heroHeight)
  }
}

@Component
export struct PoemListCard {
  @Prop dynasty: string = ''
  @Prop title: string = ''
  @Prop author: string = ''
  @Prop summary: string = ''
  @Prop cover: Resource = $r('app.media.cover_scroll')
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s4 }) {
      Image(this.cover)
        .width(88)
        .height(88)
        .borderRadius(18)
        .objectFit(ImageFit.Cover)
      Column({ space: 6 }) {
        Text(this.dynasty.length > 0 ? `${this.dynasty} · ${this.author}` : this.author)
          .fontSize(12)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .fontWeight(FontWeight.Medium)
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.summary)
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row() {
          Blank()
          AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().brandPrimary })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(24)
    .shadow({ radius: 12, color: 'rgba(28,40,51,0.06)', offsetY: 2, offsetX: 0 })
    .onClick(() => this.onOpen())
  }
}

@Component
export struct QuizOptionRow {
  @Prop label: string = ''
  @Prop text: string = ''
  @Prop tone: string = 'idle'
  onPick: () => void = () => {}

  private bg(): string {
    if (this.tone === 'correct') {
      return Theme.colors().successContainer
    }
    if (this.tone === 'wrong') {
      return Theme.colors().dangerContainer
    }
    if (this.tone === 'selected') {
      return Theme.colors().brandPrimaryContainer
    }
    return Theme.colors().surfaceCard
  }

  private strokeColor(): string {
    if (this.tone === 'selected' || this.tone === 'correct') {
      return Theme.colors().brandPrimary
    }
    if (this.tone === 'wrong') {
      return Theme.colors().danger
    }
    return Theme.colors().strokeStrong
  }

  build() {
    Row({ space: 12 }) {
      Text(this.label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .width(22)
      Text(this.text)
        .fontSize(16)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
        .maxLines(3)
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.bg())
    .borderRadius(16)
    .border({ width: 1.5, color: this.strokeColor() })
    .onClick(() => this.onPick())
  }
}

@Component
export struct FilterChip {
  @Prop label: string = ''
  @Prop active: boolean = false
  onPick: () => void = () => {}

  build() {
    Text(this.label)
      .fontSize(13)
      .fontColor(this.active ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.active ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .border({
        width: 1,
        color: this.active ? Theme.colors().brandPrimary : Theme.colors().strokeStrong
      })
      .onClick(() => this.onPick())
  }
}

@Component
export struct EntryCard {
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop coverKey: string = 'cover_scroll'
  @Prop badge: string = ''
  onTap: () => void = () => {}

  build() {
    Row({ space: 12 }) {
      Image(PoetryMedia.cover(this.coverKey))
        .width(72)
        .height(72)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(this.title)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          if (this.badge.length > 0) {
            Text(this.badge)
              .fontSize(11)
              .fontColor(Theme.colors().brandOnPrimary)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
          }
        }
        .width('100%')
        Text(this.summary)
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
