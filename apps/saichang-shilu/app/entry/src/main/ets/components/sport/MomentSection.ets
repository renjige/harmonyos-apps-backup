import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { KeyMoment } from '../../models/SportExtra'

@Component
export struct MomentSection {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop moments: KeyMoment[] = []
  onChanged: (list: KeyMoment[]) => void = (_l: KeyMoment[]) => {}
  @State minuteText: string = ''
  @State kind: string = 'score'
  @State text: string = ''
  private kinds: string[] = KeyMoment.kindIds()

  private addMoment(): void {
    const min = parseInt(this.minuteText, 10)
    if (this.minuteText.length === 0 || !(min >= 0)) {
      return
    }
    if (this.text.trim().length === 0) {
      return
    }
    const m = new KeyMoment()
    m.minute = min
    m.kind = this.kind
    m.text = this.text.trim()
    const next: KeyMoment[] = []
    for (const it of this.moments) {
      next.push(it)
    }
    next.push(m)
    this.minuteText = ''
    this.text = ''
    this.onChanged(next)
  }

  private removeAt(index: number): void {
    const next: KeyMoment[] = []
    let i = 0
    for (const it of this.moments) {
      if (i !== index) {
        next.push(it)
      }
      i++
    }
    this.onChanged(next)
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('赛点时刻')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text('把进球、失误、暂停标到分钟，下场对照用，不是看完即走的流水账。')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

      if (this.moments.length === 0) {
        Text('还没有赛点。补一条，本场才有可复盘的锚点。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      } else {
        ForEach(this.moments, (m: KeyMoment, index: number) => {
          Row() {
            Text(`${m.minute}' ${KeyMoment.kindLabel(m.kind)}`)
              .fontSize(Theme.type.bodyS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width(96)
            Text(m.text)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('删除')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().danger)
              .onClick((): void => { this.removeAt(index) })
          }
          .width('100%')
        }, (m: KeyMoment, index: number) => `${index}-${m.minute}-${m.text}`)
      }

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.kinds, (id: string) => {
          Text(KeyMoment.kindLabel(id))
            .fontSize(Theme.type.caption)
            .fontColor(this.kind === id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(this.kind === id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 6, bottom: 6 })
            .onClick((): void => { this.kind = id })
        }, (id: string) => id)
      }
      .width('100%')

      Row({ space: Theme.space.s2 }) {
        TextInput({ text: this.minuteText, placeholder: '分钟' })
          .type(InputType.Number)
          .width(72)
          .onChange((v: string) => { this.minuteText = v })
        TextInput({ text: this.text, placeholder: '例如：右侧底角命中' })
          .layoutWeight(1)
          .onChange((v: string) => { this.text = v })
      }
      .width('100%')

      AppButton({
        label: '添加赛点',
        variant: 'secondary',
        onTap: (): void => { this.addMoment() }
      })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}
