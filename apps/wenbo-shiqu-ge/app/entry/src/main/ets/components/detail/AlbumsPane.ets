import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { ExploreAlbum, ExploreStore } from '../../services/ExploreStore'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'
import { PavilionStore } from '../../services/PavilionStore'

@Component
export struct AlbumsPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop articleId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State albums: ExploreAlbum[] = []
  @State name: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.albums = ExploreStore.albumList()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 1800)
  }

  private async create(): Promise<void> {
    await ExploreStore.createAlbum(this.name)
    this.name = ''
    this.reload()
    this.showToast('收藏夹已创建')
  }

  private async add(id: string): Promise<void> {
    if (this.articleId.length === 0 || this.articleId === 'all') {
      this.showToast('请从趣知详情加入收藏夹')
      return
    }
    if (!PavilionStore.isFavorite(this.articleId)) {
      await PavilionStore.toggleFavorite(this.articleId)
    }
    await ExploreStore.addToAlbum(id, this.articleId)
    this.showToast('已放入收藏夹')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '个人收藏夹',
        onClose: (): void => { PavilionDetailNav.close() }
      }) {
        Column({ space: Theme.space.s3 }) {
          Text('收藏夹名称')
            .fontSize(13)
            .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
            .width('100%')
          TextInput({ text: this.name, placeholder: '例如：稍后读、自然观察' })
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
            .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
            .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
            .padding({ left: 14, right: 14 })
            .borderRadius(12)
            .border({ width: 1, color: Theme.hairline(this.themeEpoch, this.darkModeOn) })
            .onChange((v: string): void => { this.name = v })
          AppButton({ label: '创建收藏夹', onTap: (): void => { void this.create() } })
          if (this.albums.length === 0) {
            AppEmpty({
              title: '还没有收藏夹',
              description: '创建一个夹子，把趣知按主题整理。'
            })
          } else {
            ForEach(this.albums, (a: ExploreAlbum) => {
              Row() {
                Column({ space: 4 }) {
                  Text(a.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                  Text(a.ids.length > 0 ? `${a.ids.split(',').length} 篇` : '空夹')
                    .fontSize(12)
                    .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                if (this.articleId.length > 0 && this.articleId !== 'all') {
                  Text(ExploreStore.albumHas(a, this.articleId) ? '已在夹中' : '放入')
                    .fontSize(13)
                    .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
                    .onClick((): void => { void this.add(a.id) })
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
              .borderRadius(12)
            }, (a: ExploreAlbum) => a.id)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        .width('100%')
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .padding(10)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(20)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
