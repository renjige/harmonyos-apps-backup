import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AlbumItem } from '../models/KagModels'
import { KagBizService } from '../services/KagBizService'
import { KagMedia } from '../services/KagMedia'
import { KagNav } from '../services/KagNav'
import { AuthService } from '../services/AuthService'

@Component
export struct AlbumListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('kagTick') @Watch('onTick') tick: number = 0
  @StorageLink('kagChildId') childId: string = ''
  @State albums: AlbumItem[] = []
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.albums = await KagBizService.loadAlbums(this.childId)
  }

  private tryCreate(): void {
    if (!AuthService.requireAuth('create_album')) {
      this.onRequireAuth()
      return
    }
    KagNav.openBare('albumForm')
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Text('我的画册')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          AppButton({
            label: '新建画册',
            variant: 'secondary',
            onTap: () => this.tryCreate()
          })
        }
        .width('100%')

        Image(KagMedia.cover('banner_share'))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)

        if (this.albums.length === 0) {
          AppEmpty({
            title: '还没有画册',
            description: '按水彩、家人、涂鸦等主题把作品收成一本。',
            actionLabel: '新建画册',
            onAction: () => this.tryCreate()
          })
        } else {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.albums, (a: AlbumItem) => {
              this.AlbumCard(a)
            }, (a: AlbumItem) => a.id)
          }
          .width('100%')
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  AlbumCard(a: AlbumItem) {
    Column({ space: 8 }) {
      Image(KagMedia.cover(a.coverKey))
        .width('100%')
        .height(120)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)
      Text(a.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .maxLines(1)
      Text(a.summary.length > 0 ? a.summary : '打开画册')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .maxLines(2)
    }
    .width('48%')
    .padding({ bottom: Theme.space.s3 })
    .onClick(() => KagNav.open('album', a.id))
  }
}
