import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { ColorPalette } from '../../models/PaletteModels'

@Component
export struct PaletteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop palette: ColorPalette = new ColorPalette()
  onClose: () => void = () => {}
  onDelete: () => void = () => {}
  @State toastText: string = ''

  private copyHex(hex: string): void {
    const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, hex)
    pasteboard.getSystemPasteboard().setData(pasteData)
    this.toastText = `已复制 ${hex}`
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  build() {
    Stack() {
      DetailShell({
        title: this.palette.name,
        onClose: (): void => { this.onClose() },
        body: (): void => { this.BodyContent() }
      })

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BodyContent() {
    Column({ space: Theme.space.s4 }) {
      if (this.palette.note.length > 0) {
        Text(this.palette.note)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .lineHeight(22)
          .width('100%')
      }

      ForEach(this.palette.colors, (hex: string) => {
        Row({ space: Theme.space.s3 }) {
          Column()
            .width(56)
            .height(56)
            .backgroundColor(hex)
            .borderRadius(Theme.radius.sm)
            .border({ width: 1, color: Theme.colors().strokeHairline })

          Column({ space: 4 }) {
            Text(hex.toUpperCase())
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('点击复制色值')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          AppIcon({ name: 'check', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onClick((): void => { this.copyHex(hex) })
      }, (hex: string) => hex)

      if (this.palette.tags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.palette.tags, (tag: string) => {
            Text(tag)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .margin({ right: 8, bottom: 8 })
          }, (tag: string) => tag)
        }
      }

      AppButton({
        label: '删除此色板',
        variant: 'secondary',
        onTap: (): void => { this.onDelete() }
      })
    }
    .width('100%')
  }
}
