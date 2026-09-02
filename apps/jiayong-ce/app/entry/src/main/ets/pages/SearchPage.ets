import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { LocalPhotoImage } from '../components/album/LocalPhotoImage'
import { FamilyPhoto } from '../models/AlbumModels'
import { AlbumStore } from '../services/AlbumStore'
import { AlbumNav } from '../services/AlbumNav'

@Component
export struct SearchPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onBack: () => void = () => {}

  @State query: string = ''
  @State photos: FamilyPhoto[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private reload(): void {
    this.photos = AlbumStore.search(this.query)
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.onBack() })
        Text('搜索家庭照片')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .margin({ left: Theme.space.s2 })
      }
      .width('100%')
      .height(48)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      TextInput({ text: this.query, placeholder: '描述、地点、上传人' })
        .onChange((v: string) => {
          this.query = v
          this.reload()
        })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })

      if (this.photos.length === 0) {
        AppEmpty({ title: '没有匹配的照片', description: '试试地点或描述里的关键词' })
      } else {
        Scroll() {
          Column() {
            ForEach(this.photos, (p: FamilyPhoto) => {
              Row() {
                LocalPhotoImage({ uri: p.uri, tileW: 64, tileH: 64, radius: Theme.radius.md })
                Column() {
                  Text(p.caption.length > 0 ? p.caption : '家庭瞬间')
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(`${p.location} · ${p.uploadedBy}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: Theme.space.s3 })
                .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .margin({ bottom: Theme.space.s2 })
              .onClick((): void => { AlbumNav.openDetail(p.id) })
            }, (p: FamilyPhoto) => p.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
