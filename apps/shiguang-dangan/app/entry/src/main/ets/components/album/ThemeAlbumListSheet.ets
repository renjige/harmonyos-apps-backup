import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { ThemeAlbum } from '../../models/LifeModels'
import { LifeStorePhase3 } from '../../services/LifeStorePhase3'
import { AchievementService } from '../../services/AchievementService'
import { ThemeAlbumCover } from './ThemeAlbumCover'
import { ThemeAlbumDetailPane } from './ThemeAlbumDetailPane'

@Component
export struct ThemeAlbumListSheet {
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  @State albums: ThemeAlbum[] = []
  @State newTitle: string = ''
  @State detailId: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.albums = await LifeStorePhase3.loadThemeAlbums()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async createAlbum(): Promise<void> {
    const title = this.newTitle.trim()
    if (title.length < 2) {
      this.showToast('标题至少 2 字')
      return
    }
    const album = ThemeAlbum.createNew(title)
    await LifeStorePhase3.saveThemeAlbum(album)
    this.newTitle = ''
    await AchievementService.checkAndUnlock()
    this.onChanged()
    await this.reload()
    this.showToast('主题册已创建')
  }

  private closeDetail(): void {
    this.detailId = ''
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.detailId.length > 0) {
        DetailShell({
          title: '主题册详情',
          onClose: (): void => { this.closeDetail() },
          body: this.DetailBody
        })
      } else {
        Column() {
          Row({ space: Theme.space.s2 }) {
            Text('主题册')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('关闭')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.onClose() })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

          Row({ space: Theme.space.s2 }) {
            TextInput({ text: this.newTitle, placeholder: '新主题册名称' })
              .layoutWeight(1)
              .onChange((v: string): void => { this.newTitle = v })
            AppButton({
              label: '创建',
              variant: 'primary',
              onTap: (): void => { void this.createAlbum() }
            })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Scroll() {
            Column({ space: Theme.space.s3 }) {
              if (this.albums.length === 0) {
                AppEmpty({
                  title: '还没有主题册',
                  description: '把档案、灵感和时刻串联成主题故事',
                  actionLabel: '',
                  onAction: (): void => {}
                })
              } else {
                ForEach(this.albums, (a: ThemeAlbum) => {
                  ThemeAlbumCover({
                    album: a,
                    compact: false,
                    onTap: (): void => {
                      this.detailId = a.id
                      AppStorage.setOrCreate('tabBarHidden', true)
                    }
                  })
                }, (a: ThemeAlbum) => a.id)
              }
            }
            .padding(Theme.space.pageX)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s2 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    ThemeAlbumDetailPane({
      albumId: this.detailId,
      onChanged: (): void => {
        this.onChanged()
        void this.reload()
      }
    })
  }
}
