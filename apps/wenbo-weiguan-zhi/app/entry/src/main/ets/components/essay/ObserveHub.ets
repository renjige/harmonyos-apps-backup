import { Theme } from '../design-system/Theme'
import { PracticeStrip } from './PracticeStrip'

@Component
export struct ObserveHub {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop fontScale: number = 1
  @Prop weekCount: number = 0
  @Prop weekWords: number = 0
  onRecap: () => void = () => {}
  onCapsule: () => void = () => {}
  onOpenCard: () => void = () => {}
  onOpenFree: () => void = () => {}
  onContrast: () => void = () => {}
  onWriteHint: (hint: string) => void = (hint: string) => {
    if (hint.length === 0) {
      return
    }
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Column({ space: 6 }) {
        Text('本周观察回顾')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandAccent)
          .width('100%')
        Text(`${this.weekCount} 篇 · ${this.weekWords} 字`)
          .fontSize(Theme.type.title3 * this.fontScale)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text('回看这 7 天写过的微观瞬间 →')
          .fontSize(Theme.type.caption * this.fontScale)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)
      .onClick((): void => { this.onRecap() })

      PracticeStrip({
        fontScale: this.fontScale,
        onWrite: (hint: string): void => { this.onWriteHint(hint) }
      })

      Row({ space: Theme.space.s2 }) {
        Text('观察卡')
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .padding({ top: 10, bottom: 10 })
          .backgroundColor('#1A2A3A')
          .borderRadius(Theme.radius.sm)
          .onClick((): void => { this.onOpenCard() })
        Text('时光胶囊')
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .padding({ top: 10, bottom: 10 })
          .backgroundColor('#1A2A3A')
          .borderRadius(Theme.radius.sm)
          .onClick((): void => { this.onCapsule() })
        Text('自由观察')
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.sm)
          .onClick((): void => { this.onOpenFree() })
      }
      .width('100%')

      Text('对照观察')
        .fontSize(Theme.type.bodyS)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .backgroundColor('#1A2A3A')
        .border({ width: 1, color: '#C9A96E' })
        .borderRadius(Theme.radius.sm)
        .onClick((): void => { this.onContrast() })
    }
    .width('100%')
    .padding({
      left: Theme.space.pageX,
      right: Theme.space.pageX,
      top: Theme.space.s3
    })
  }
}
