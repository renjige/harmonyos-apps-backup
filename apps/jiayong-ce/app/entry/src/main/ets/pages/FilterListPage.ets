import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { LocalPhotoImage } from '../components/album/LocalPhotoImage'
import { BucketItem, FamilyPhoto } from '../models/AlbumModels'
import { AlbumStore } from '../services/AlbumStore'
import { AlbumNav } from '../services/AlbumNav'

@Component
export struct FilterListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('albumFilterKind') @Watch('onKindChange') kind: string = 'all'
  @StorageLink('albumFilterValue') @Watch('onValueChange') value: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onBack: () => void = () => {}

  @State title: string = '智慧分册'
  @State buckets: BucketItem[] = []
  @State photos: FamilyPhoto[] = []
  @State showBuckets: boolean = false

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  onKindChange(): void {
    this.reload()
  }

  onValueChange(): void {
    this.reload()
  }

  private reload(): void {
    this.showBuckets = this.value.length === 0 &&
      (this.kind === 'people' || this.kind === 'time' || this.kind === 'place')
    if (this.kind === 'people') {
      this.title = '按人物整理'
      this.buckets = AlbumStore.memberBuckets()
      this.photos = this.value.length > 0 ? AlbumStore.byMember(this.value) : []
    } else if (this.kind === 'time') {
      this.title = '按时间整理'
      this.buckets = AlbumStore.monthBuckets()
      this.photos = this.value.length > 0 ? AlbumStore.byMonth(this.value) : []
    } else if (this.kind === 'place') {
      this.title = '按地点整理'
      this.buckets = AlbumStore.locationBuckets()
      this.photos = this.value.length > 0 ? AlbumStore.byLocation(this.value) : []
    } else if (this.kind === 'favorite') {
      this.title = '珍藏'
      this.showBuckets = false
      this.photos = AlbumStore.favorites()
    } else if (this.kind === 'album') {
      this.title = '主题册'
      this.showBuckets = false
      this.photos = AlbumStore.byAlbum(this.value)
    } else {
      this.title = '全部照片'
      this.showBuckets = false
      this.photos = AlbumStore.sortedPhotos()
    }
  }

  private openBucket(b: BucketItem): void {
    AppStorage.setOrCreate('albumFilterValue', b.key)
    this.value = b.key
    this.reload()
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.onBack() })
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .margin({ left: Theme.space.s2 })
      }
      .width('100%')
      .height(48)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Scroll() {
        Column() {
          if (this.showBuckets) {
            ForEach(this.buckets, (b: BucketItem) => {
              Row() {
                AppIcon({ name: 'photo', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                Text(b.label)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .layoutWeight(1)
                  .margin({ left: Theme.space.s3 })
                Text(`${b.count} 张`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .height(52)
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .margin({ bottom: Theme.space.s2 })
              .onClick((): void => { this.openBucket(b) })
            }, (b: BucketItem) => b.key)
          }

          if (!this.showBuckets && this.photos.length === 0) {
            AppEmpty({
              title: '这一册还是空的',
              description: '上传时填写人物、地点或加入珍藏后，会自动归入对应分册',
              actionLabel: '去上传',
              onAction: (): void => {
                this.onBack()
                AlbumNav.openUpload()
              }
            })
          }

          if (!this.showBuckets && this.photos.length > 0) {
            GridRow({ columns: 3, gutter: 4 }) {
              ForEach(this.photos, (p: FamilyPhoto) => {
                GridCol() {
                  LocalPhotoImage({ uri: p.uri, squareFill: true, radius: Theme.radius.sm })
                    .onClick((): void => { AlbumNav.openDetail(p.id) })
                }
              }, (p: FamilyPhoto) => p.id)
            }
            .width('100%')
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
