import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { EssayListCard } from './EssayListCard'
import { ObserveAlbum } from '../../models/GrowthModels'
import { MicroEssay } from '../../models/EssayModels'
import { EssayStore } from '../../services/EssayStore'
import { GrowthStore } from '../../services/GrowthStore'

@Component
export struct AlbumListPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('essayFontScale') fontScale: number = 1
  onClose: () => void = () => {}
  onOpenEssay: (id: string) => void = () => {}

  @State albums: ObserveAlbum[] = []
  @State essays: MicroEssay[] = []
  @State selectedId: string = ''
  @State newTitle: string = ''
  @State toastText: string = ''
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.albums = await GrowthStore.loadAlbums()
    this.essays = await EssayStore.loadAll()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private selected(): ObserveAlbum | undefined {
    for (const a of this.albums) {
      if (a.id === this.selectedId) {
        return a
      }
    }
    return undefined
  }

  private selectedTitle(): string {
    const a = this.selected()
    return a === undefined ? '' : a.title
  }

  private albumEssays(): MicroEssay[] {
    const a = this.selected()
    if (a === undefined) {
      return []
    }
    const ids = a.essayIds()
    const out: MicroEssay[] = []
    for (const id of ids) {
      for (const e of this.essays) {
        if (e.id === id) {
          out.push(e)
        }
      }
    }
    return out
  }

  private async createAlbum(): Promise<void> {
    const name = this.newTitle.trim()
    if (name.length === 0) {
      this.showToast('请填写专辑名')
      return
    }
    await GrowthStore.saveAlbum(ObserveAlbum.create(name))
    this.newTitle = ''
    await this.reload()
    this.showToast('专辑已创建')
  }

  private async deleteSelected(): Promise<void> {
    if (this.selectedId.length === 0) {
      return
    }
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await GrowthStore.deleteAlbum(this.selectedId)
    this.selectedId = ''
    this.confirmDelete = false
    await this.reload()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text(this.selectedId.length > 0 ? this.selectedTitle() : '观察专辑')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Text(this.selectedId.length > 0 ? '返回' : '关闭')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => {
              if (this.selectedId.length > 0) {
                this.selectedId = ''
                this.confirmDelete = false
              } else {
                this.onClose()
              }
            })
        }
        .width('100%')
        .padding(Theme.space.pageX)

        if (this.selectedId.length === 0) {
          Row({ space: Theme.space.s2 }) {
            TextInput({ text: this.newTitle, placeholder: '新专辑，如 雨天' })
              .layoutWeight(1)
              .height(44)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .padding({ left: 12, right: 12 })
              .onChange((v: string) => { this.newTitle = v })
            Text('创建')
              .fontSize(Theme.type.bodyS)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .backgroundColor('#1A2A3A')
              .borderRadius(Theme.radius.sm)
              .onClick((): void => { void this.createAlbum() })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

          if (this.albums.length === 0) {
            AppEmpty({
              title: '还没有专辑',
              description: '把珍藏的观察放进自己的集合',
              actionLabel: '',
              onAction: (): void => {}
            })
          } else {
            Scroll() {
              Column({ space: Theme.space.s3 }) {
                ForEach(this.albums, (item: ObserveAlbum) => {
                  Text(`${item.title} · ${item.essayIds().length} 篇`)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                    .padding(Theme.space.s4)
                    .backgroundColor(Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.md)
                    .onClick((): void => {
                      this.selectedId = item.id
                      this.confirmDelete = false
                    })
                }, (item: ObserveAlbum) => item.id)
              }
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .layoutWeight(1)
          }
        } else {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.banner_ink'))
              .width('100%')
              .height(100)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
            Column() {
              Blank()
              Column({ space: 4 }) {
                Text(this.selectedTitle())
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .width('100%')
                Text(`${this.albumEssays().length} 篇观察`)
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(26,42,58,0.82)', 1]]
              })
            }
            .width('100%')
            .height(100)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.albumEssays(), (item: MicroEssay) => {
                EssayListCard({
                  essay: item,
                  fontScale: this.fontScale,
                  onTap: (): void => { this.onOpenEssay(item.id) }
                })
              }, (item: MicroEssay) => item.id)
              if (this.albumEssays().length === 0) {
                AppEmpty({
                  title: '专辑还是空的',
                  description: '打开一篇观察，点加入专辑',
                  actionLabel: '',
                  onAction: (): void => {}
                })
              }
              Text(this.confirmDelete ? '再点一次删除专辑' : '删除此专辑')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
                .textAlign(TextAlign.Center)
                .onClick((): void => { void this.deleteSelected() })
              Blank().height(Theme.space.s8)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.body)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#1A2A3A')
          .borderRadius(Theme.radius.pill)
          .position({ x: '18%', y: 40 })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(40)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
