import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct PhotoGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop photos: string[] = []
  @Prop maxColumns: number = 3
  onPhotoTap: (index: number) => void = (_i: number) => {}

  build() {
    if (this.photos.length === 0) {
      Column({ space: Theme.space.s3 }) {
        Image($r('app.media.ambient_empty'))
          .width('60%')
          .aspectRatio(1)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
        Text('还没有赛场照片')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .width('100%')
      .padding(Theme.space.s6)
      .alignItems(HorizontalAlign.Center)
    } else {
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.photos, (path: string, index: number) => {
          Stack() {
            Image(path)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
          }
          .width('31%')
          .aspectRatio(1)
          .margin({ right: '2%', bottom: Theme.space.s2 })
          .onClick((): void => { this.onPhotoTap(index) })
        }, (path: string, index: number) => `${index}_${path}`)
      }
      .width('100%')
    }
  }
}

@Component
export struct PhotoViewerOverlay {
  @Prop photoPath: string = ''
  onClose: () => void = () => {}

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#CC000000')
        .onClick((): void => { this.onClose() })

      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: '#FFFFFF' })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Image(this.photoPath)
          .width('100%')
          .layoutWeight(1)
          .objectFit(ImageFit.Contain)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .zIndex(80)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
