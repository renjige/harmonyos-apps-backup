import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { ObserveAlbum } from '../../models/GrowthModels'
import { GrowthStore } from '../../services/GrowthStore'
import { EssayStore } from '../../services/EssayStore'

@Component
export struct PickAlbumSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop essayId: string = ''
  onClose: () => void = () => {}
  onPicked: () => void = () => {}

  @State albums: ObserveAlbum[] = []
  @State toastText: string = ''
  @State newTitle: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.albums = await GrowthStore.loadAlbums()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async pick(album: ObserveAlbum): Promise<void> {
    await GrowthStore.putEssayInAlbum(this.essayId, album.id)
    const found = await EssayStore.findById(this.essayId)
    if (found !== undefined) {
      found.albumId = album.id
      found.favorite = true
      await EssayStore.saveEssay(found)
    }
    this.showToast(`已放入「${album.title}」`)
    this.onPicked()
  }

  private async createAndPick(): Promise<void> {
    const name = this.newTitle.trim()
    if (name.length === 0) {
      this.showToast('请先给专辑起名')
      return
    }
    const a = ObserveAlbum.create(name)
    a.addEssay(this.essayId)
    await GrowthStore.saveAlbum(a)
    const found = await EssayStore.findById(this.essayId)
    if (found !== undefined) {
      found.albumId = a.id
      found.favorite = true
      await EssayStore.saveEssay(found)
    }
    this.newTitle = ''
    this.showToast('专辑已创建')
    this.onPicked()
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onClose() })

      Column({ space: Theme.space.s3 }) {
        Row() {
          Text('加入观察专辑')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Text('关闭')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { this.onClose() })
        }
        .width('100%')

        Row({ space: Theme.space.s2 }) {
          TextInput({ text: this.newTitle, placeholder: '新专辑名，如 窗边' })
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
            .onClick((): void => { void this.createAndPick() })
        }
        .width('100%')

        if (this.albums.length === 0) {
          AppEmpty({
            title: '还没有专辑',
            description: '给珍藏的观察建一个集合，例如雨天或食堂',
            actionLabel: '',
            onAction: (): void => {}
          })
        } else {
          Scroll() {
            Column({ space: Theme.space.s2 }) {
              ForEach(this.albums, (item: ObserveAlbum) => {
                Text(`${item.title} · ${item.essayIds().length} 篇`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                  .padding(Theme.space.s4)
                  .backgroundColor(Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.md)
                  .onClick((): void => { void this.pick(item) })
              }, (item: ObserveAlbum) => item.id)
            }
            .width('100%')
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('70%')
      .padding(Theme.space.pageX)
      .backgroundColor(Theme.colors().surfacePage)
      .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
      .position({ x: 0, y: '30%' })

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.body)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#1A2A3A')
          .borderRadius(Theme.radius.pill)
          .position({ x: '16%', y: 24 })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(90)
  }
}
