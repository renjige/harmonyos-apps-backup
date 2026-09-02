import { Theme } from '../design-system/Theme'
import { PolishResult } from '../../models/LanguageCraftModels'

@Component
export struct PolishQuadSheet {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop items: PolishResult[] = []
  @Prop originalText: string = ''
  onClose: () => void = () => {}
  onPick: (row: PolishResult) => void = (row: PolishResult): void => {
    if (row.styleKey.length === 0) {
      return
    }
  }

  build() {
    Column() {
      Row() {
        Text('四风格对照')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.of(this.darkModeOn).textPrimary)
          .layoutWeight(1)
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.of(this.darkModeOn).brandPrimary)
          .onClick((): void => { this.onClose() })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s3
      })

      if (this.originalText.length > 0) {
        Text(`原文 ${this.originalText.length} 字 · 下方为四种风格成稿，字数与结构均不同`)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.of(this.darkModeOn).textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
      }

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.items, (row: PolishResult) => {
            Column({ space: 6 }) {
              Row() {
                Text(row.styleLabel)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                Blank()
                Text(`幅度${row.rewriteLevel} · ${row.polishedLen}字`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
              }
              .width('100%')
              Text(row.polished)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.of(this.darkModeOn).textPrimary)
                .lineHeight(22)
                .width('100%')
              Text('采用此稿')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.onPick(row) })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
          }, (row: PolishResult) => row.styleKey)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.of(this.darkModeOn).surfacePage)
  }
}
