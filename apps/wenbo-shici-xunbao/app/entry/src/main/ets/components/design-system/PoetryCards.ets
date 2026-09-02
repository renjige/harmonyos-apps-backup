import { Theme } from './Theme'
import { AppIcon } from './AppIcon'

@Component
export struct PoemListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
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
          .fontColor(Theme.colors().brandAccent)
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
          AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().brandAccent })
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
    .shadow({ radius: 12, color: 'rgba(26,26,46,0.06)', offsetY: 2, offsetX: 0 })
    .onClick(() => this.onOpen())
  }
}

@Component
export struct HuntOptionRow {
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
      return Theme.colors().brandAccent
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
        .fontColor(Theme.colors().brandAccent)
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
