import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct PhotoGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop uris: string[] = []
  @Prop editable: boolean = false
  onAdd: () => void = () => {}
  onRemove: (index: number) => void = (index: number) => { if (index < 0) { return } }
  onPreview: (uri: string) => void = (uri: string) => { if (uri.length === 0) { return } }

  build() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.uris, (uri: string, index: number) => {
        Stack({ alignContent: Alignment.TopEnd }) {
          Image(uri)
            .width(96)
            .height(96)
            .objectFit(ImageFit.Cover)
            .borderRadius(12)
            .onClick(() => this.onPreview(uri))
          if (this.editable) {
            Column() {
              AppIcon({ name: 'close', iconSize: Theme.icon.sm, color: '#FFFFFF' })
            }
            .width(22)
            .height(22)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('rgba(26,31,38,0.72)')
            .borderRadius(11)
            .margin({ top: 4, right: 4 })
            .onClick(() => this.onRemove(index))
          }
        }
        .width(96)
        .height(96)
        .margin({ right: 8, bottom: 8 })
      }, (uri: string, index: number) => `${uri}_${index}`)

      if (this.editable && this.uris.length < 6) {
        Column({ space: 6 }) {
          AppIcon({ name: 'photo', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
          Text('添加照片')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width(96)
        .height(96)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(12)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .onClick(() => this.onAdd())
      }
    }
    .width('100%')
  }
}
