import { Theme } from '../design-system/Theme'

class PadKey {
  label: string = ''
  action: string = 'digit'
}

function pushKey(keys: PadKey[], label: string, action: string): void {
  const k = new PadKey()
  k.label = label
  k.action = action
  keys.push(k)
}

function makeKeys(): PadKey[] {
  const keys: PadKey[] = []
  pushKey(keys, '1', 'digit')
  pushKey(keys, '2', 'digit')
  pushKey(keys, '3', 'digit')
  pushKey(keys, '4', 'digit')
  pushKey(keys, '5', 'digit')
  pushKey(keys, '6', 'digit')
  pushKey(keys, '7', 'digit')
  pushKey(keys, '8', 'digit')
  pushKey(keys, '9', 'digit')
  pushKey(keys, '清除', 'del')
  pushKey(keys, '0', 'digit')
  pushKey(keys, '确定', 'ok')
  return keys
}

@Component
export struct MathNumPad {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop motion: boolean = true
  @State pressedKey: string = ''
  onDigit: (value: string) => void = (_v: string) => {}
  onDelete: () => void = () => {}
  onSubmit: () => void = () => {}
  private keys: PadKey[] = makeKeys()

  private flash(label: string, action: () => void): void {
    if (this.motion) {
      this.pressedKey = label
      setTimeout(() => { this.pressedKey = '' }, 120)
    }
    action()
  }

  private tap(k: PadKey): void {
    if (k.action === 'del') {
      this.onDelete()
      return
    }
    if (k.action === 'ok') {
      this.flash('ok', () => this.onSubmit())
      return
    }
    this.flash(k.label, () => this.onDigit(k.label))
  }

  private keyColor(k: PadKey): ResourceColor {
    if (k.action === 'ok') {
      return Theme.colors().brandPrimary
    }
    if (k.action === 'del') {
      return Theme.colors().surfaceSubtle
    }
    if (this.pressedKey === k.label) {
      return Theme.colors().brandPrimaryContainer
    }
    return Theme.colors().surfaceCard
  }

  private textColor(k: PadKey): ResourceColor {
    if (k.action === 'ok') {
      return Theme.colors().brandOnPrimary
    }
    if (k.action === 'del') {
      return Theme.colors().textSecondary
    }
    return Theme.colors().textPrimary
  }

  build() {
    Grid() {
      ForEach(this.keys, (k: PadKey) => {
        GridItem() {
          Text(k.label)
            .fontSize(k.action === 'digit' ? 24 : Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.textColor(k))
            .width('100%')
            .height(48)
            .textAlign(TextAlign.Center)
            .backgroundColor(this.keyColor(k))
            .borderRadius(Theme.radius.lg)
            .scale({
              x: this.pressedKey === k.label && this.motion ? 0.94 : 1,
              y: this.pressedKey === k.label && this.motion ? 0.94 : 1
            })
            .onClick(() => this.tap(k))
        }
      }, (k: PadKey) => `${k.action}-${k.label}`)
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(Theme.space.s2)
    .columnsGap(Theme.space.s2)
    .width('100%')
    .height(216)
  }
}
