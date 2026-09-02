import { Theme } from '../design-system/Theme'

class PadKey {
  label: string = ''
  action: string = 'digit'
}

function makeKeys(): PadKey[] {
  const labels: string[] = ['1', '2', '3', '4', '5', '6', '7', '8', '9']
  const keys: PadKey[] = []
  for (const lab of labels) {
    const k = new PadKey()
    k.label = lab
    k.action = 'digit'
    keys.push(k)
  }
  return keys
}

@Component
export struct MathNumPad {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onDigit: (value: string) => void = (_v: string) => {}
  onDelete: () => void = () => {}
  onSubmit: () => void = () => {}
  private keys: PadKey[] = makeKeys()

  build() {
    Column({ space: Theme.space.s3 }) {
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.keys, (k: PadKey) => {
          Text(k.label)
            .fontSize(28)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('31%')
            .height(64)
            .textAlign(TextAlign.Center)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .shadow({ radius: 8, color: 'rgba(23,32,51,0.05)', offsetY: 2 })
            .margin({ bottom: Theme.space.s3 })
            .onClick(() => this.onDigit(k.label))
        }, (k: PadKey) => k.label)
      }
      .width('100%')

      Row({ space: Theme.space.s3 }) {
        Text('0')
          .fontSize(28)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .height(64)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .shadow({ radius: 8, color: 'rgba(23,32,51,0.05)', offsetY: 2 })
          .onClick(() => this.onDigit('0'))
        Text('清除')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width(88)
          .height(64)
          .textAlign(TextAlign.Center)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.onDelete())
        Text('确定')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandOnPrimary)
          .width(88)
          .height(64)
          .textAlign(TextAlign.Center)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.onSubmit())
      }
      .width('100%')
    }
    .width('100%')
  }
}
