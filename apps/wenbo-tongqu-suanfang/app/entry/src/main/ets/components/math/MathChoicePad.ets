import { Theme } from '../design-system/Theme'

@Component
export struct MathChoicePad {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop qType: string = 'choice'
  @Prop @Watch('onKeyChange') quizKey: string = ''
  @Prop choiceA: string = ''
  @Prop choiceB: string = ''
  @Prop choiceC: string = ''
  @State labA: string = ''
  @State labB: string = ''
  @State labC: string = ''
  onPick: (value: number) => void = (_v: number) => {}

  aboutToAppear(): void {
    this.copyLabs()
  }

  onKeyChange(): void {
    this.copyLabs()
  }

  private copyLabs(): void {
    this.labA = this.choiceA
    this.labB = this.choiceB
    this.labC = this.choiceC
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      this.option(this.labA, 0)
      this.option(this.labB, 1)
      if (this.labC.length > 0) {
        this.option(this.labC, 2)
      }
    }
    .width('100%')
  }

  @Builder
  option(label: string, value: number) {
    if (label.length > 0) {
      Text(label)
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .height(48)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .shadow({ radius: 8, color: 'rgba(23,32,51,0.05)', offsetY: 2 })
        .onClick(() => this.onPick(value))
    }
  }
}
