import { Theme } from '../design-system/Theme'
import { MediaUriUtil } from '../../utils/MediaUriUtil'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct CoverPickRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop coverImage: string = ''
  onAlbum: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Text('书籍封面（可选）')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      if (this.coverImage.length > 0) {
        Image(MediaUriUtil.imageSrc(this.coverImage))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.sm)
      }
      Row({ space: 6 }) {
        AppIcon({ name: 'photo', iconSize: 18, color: Theme.colors().brandPrimary })
        Text('从相册选择')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      }
      .width('100%')
      .height(44)
      .justifyContent(FlexAlign.Center)
      .borderRadius(Theme.radius.sm)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .onClick((): void => { this.onAlbum() })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(12)
  }
}
