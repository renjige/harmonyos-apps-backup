import { Theme } from './Theme'
import { AppIcon } from './AppIcon'

@Component
export struct PuzzleListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop typeLabel: string = ''
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop difficulty: string = ''
  @Prop cover: Resource = $r('app.media.cat_riddle')
  onTap: () => void = () => {}
  onStart: () => void = () => {}

  build() {
    Row({ space: Theme.space.s4 }) {
      Image(this.cover)
        .width(88)
        .height(88)
        .borderRadius(18)
        .objectFit(ImageFit.Cover)
        .onClick((): void => { this.onTap() })
      Column({ space: 6 }) {
        Text(this.typeLabel)
          .fontSize(12)
          .fontColor(Theme.colors().brandPrimary)
          .fontWeight(FontWeight.Medium)
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .onClick((): void => { this.onTap() })
        Text(this.summary)
          .fontSize(13)
          .fontColor(Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .onClick((): void => { this.onTap() })
        Row({ space: 10 }) {
          Text(this.difficulty)
            .fontSize(12)
            .fontColor(Theme.colors().textSecondary)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
          Blank()
          Text('开始')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.onStart() })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(24)
    .shadow({ radius: 12, color: 'rgba(30,42,58,0.05)', offsetY: 2, offsetX: 0 })
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

  private fg(): string {
    if (this.tone === 'correct') {
      return Theme.colors().success
    }
    if (this.tone === 'wrong') {
      return Theme.colors().danger
    }
    if (this.tone === 'selected') {
      return Theme.colors().brandPrimary
    }
    return Theme.colors().textPrimary
  }

  build() {
    Row({ space: 12 }) {
      Text(this.label)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.fg())
        .width(28)
      Text(this.text)
        .fontSize(16)
        .fontColor(this.fg())
        .layoutWeight(1)
      if (this.tone === 'correct') {
        AppIcon({ name: 'check', iconSize: 18, color: Theme.colors().success })
      }
    }
    .width('100%')
    .constraintSize({ minHeight: 56 })
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor(this.bg())
    .borderRadius(20)
    .border({
      width: this.tone === 'selected' ? 2 : 1,
      color: this.tone === 'selected' ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
    })
    .onClick((): void => { this.onPick() })
  }
}
