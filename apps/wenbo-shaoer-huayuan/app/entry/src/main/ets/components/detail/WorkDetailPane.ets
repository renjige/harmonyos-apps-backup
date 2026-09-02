import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { ArtworkItem, AlbumItem } from '../../models/KagModels'
import { KagMedia } from '../../services/KagMedia'
import { KagNav } from '../../services/KagNav'
import { KagBizService } from '../../services/KagBizService'
import { AuthService } from '../../services/AuthService'
import { DetailShell } from './DetailShell'

@Component
export struct WorkDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: ArtworkItem = new ArtworkItem()
  @State albums: AlbumItem[] = []
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.loadAlbums()
  }

  private async loadAlbums(): Promise<void> {
    this.albums = await KagBizService.loadAlbums(this.item.childId)
  }

  private async addToFirstAlbum(): Promise<void> {
    if (!AuthService.requireAuth('create_album')) {
      this.onRequireAuth()
      return
    }
    if (this.albums.length === 0) {
      KagNav.openBare('albumForm')
      return
    }
    const album = KagBizService.firstAlbum(this.albums)
    if (album === undefined) {
      KagNav.openBare('albumForm')
      return
    }
    const ids: string[] = []
    for (const x of this.item.albumIds) {
      ids.push(x)
    }
    let found = false
    for (const x of ids) {
      if (x === album.id) {
        found = true
      }
    }
    if (!found) {
      ids.push(album.id)
    }
    const ok = await KagBizService.patchWorkAlbum(this.item.id, ids)
    this.toastText = ok ? `已加入「${album.title}」` : '加入失败，请稍后重试'
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
    KagNav.bump()
  }

  private async removeWork(): Promise<void> {
    const ok = await KagBizService.deleteWork(this.item.id)
    if (ok) {
      KagNav.bump()
      KagNav.close()
    }
  }

  private story(): string {
    if (this.item.story.length > 0) {
      return this.item.story
    }
    if (this.item.body.length > 0) {
      return this.item.body
    }
    return this.item.summary
  }

  build() {
    Stack() {
      DetailShell({
        title: this.item.title,
        onBack: () => KagNav.close()
      }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              if (this.item.imageFile.length > 0) {
                Image(this.item.imageFile)
                  .width('100%')
                  .height(320)
                  .objectFit(ImageFit.Cover)
              } else {
                Image(KagMedia.cover(this.item.coverKey))
                  .width('100%')
                  .height(320)
                  .objectFit(ImageFit.Cover)
              }
              Column()
                .width('100%')
                .height(320)
                .linearGradient({
                  angle: 180,
                  colors: [[0x00000000, 0.15], [0xCC2D1E16, 1.0]]
                })
              Text(this.item.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFF8F3')
                .padding({
                  left: Theme.space.pageX,
                  right: Theme.space.pageX,
                  bottom: Theme.space.s4
                })
            }
            .width('100%')
            .height(320)
            .clip(true)

            Column({ space: Theme.space.s4 }) {
              Text(`${this.item.createdOn}  ·  ${this.item.ageLabel.length > 0 ? this.item.ageLabel : '年龄未填'}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              AppCard({ title: '创作故事' }) {
                Text(this.story().length > 0 ? this.story() : '还没有写下当天的心情。可返回编辑或在下次珍藏时补上。')
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }
              AppButton({
                label: '加入画册',
                variant: 'primary',
                onTap: () => {
                  void this.addToFirstAlbum()
                }
              })
              AppButton({
                label: '生成分享海报',
                variant: 'secondary',
                onTap: () => KagNav.open('share', this.item.id)
              })
              AppButton({
                label: '删除这幅作品',
                variant: 'ghost',
                onTap: () => {
                  void this.removeWork()
                }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
          }
        }
        .width('100%')
        .layoutWeight(1)
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
