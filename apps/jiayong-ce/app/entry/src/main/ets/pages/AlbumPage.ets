import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { LocalPhotoImage } from '../components/album/LocalPhotoImage'
import { FamilyPhoto, ThemeAlbum } from '../models/AlbumModels'
import { AlbumStore } from '../services/AlbumStore'
import { AlbumNav } from '../services/AlbumNav'

class CategoryItem {
  id: string = ''
  label: string = ''
  cover: Resource = $r('app.media.cat_people')
  count: number = 0

  static all(): CategoryItem[] {
    const items: CategoryItem[] = []
    const c1 = new CategoryItem()
    c1.id = 'people'
    c1.label = '人物'
    c1.cover = $r('app.media.cat_people')
    c1.count = AlbumStore.members().length
    items.push(c1)
    const c2 = new CategoryItem()
    c2.id = 'time'
    c2.label = '时间'
    c2.cover = $r('app.media.cat_time')
    c2.count = AlbumStore.monthBuckets().length
    items.push(c2)
    const c3 = new CategoryItem()
    c3.id = 'place'
    c3.label = '地点'
    c3.cover = $r('app.media.cat_place')
    c3.count = AlbumStore.locations().length
    items.push(c3)
    const c4 = new CategoryItem()
    c4.id = 'favorite'
    c4.label = '珍藏'
    c4.cover = $r('app.media.banner_02')
    c4.count = AlbumStore.favorites().length
    items.push(c4)
    return items
  }
}

@Component
export struct AlbumPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('albumRev') @Watch('onAlbumRev') storeRev: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onToast: (text: string) => void = (text: string) => {}

  @State photos: FamilyPhoto[] = []
  @State albums: ThemeAlbum[] = []
  @State selectMode: boolean = false
  @State selectedIds: string[] = []
  @State newAlbumName: string = ''
  @State showCreateAlbum: boolean = false
  @State categories: CategoryItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  onAlbumRev(): void {
    this.reload()
  }

  private reload(): void {
    this.categories = CategoryItem.all()
    this.photos = AlbumStore.sortedPhotos()
    this.albums = AlbumStore.albums()
  }

  private toggleSelect(id: string): void {
    const next: string[] = []
    let found = false
    for (const s of this.selectedIds) {
      if (s === id) {
        found = true
      } else {
        next.push(s)
      }
    }
    if (!found) {
      next.push(id)
    }
    this.selectedIds = next
  }

  private isSelected(id: string): boolean {
    for (const s of this.selectedIds) {
      if (s === id) {
        return true
      }
    }
    return false
  }

  private enterSelect(): void {
    this.selectMode = true
    this.selectedIds = []
    this.onToast('已进入多选，点选照片后可批量删除')
  }

  private async batchDelete(): Promise<void> {
    if (this.selectedIds.length === 0) {
      this.onToast('请先点选照片')
      return
    }
    const ok = await AlbumStore.deletePhotos(this.selectedIds)
    if (!ok) {
      this.onToast('批量删除失败')
      return
    }
    this.selectMode = false
    this.selectedIds = []
    this.reload()
    this.onToast('已删除选中照片')
  }

  private async createAlbum(): Promise<void> {
    const ok = await AlbumStore.addThemeAlbum(this.newAlbumName)
    if (!ok) {
      this.onToast('请填写主题册名称')
      return
    }
    this.newAlbumName = ''
    this.showCreateAlbum = false
    this.reload()
    this.onToast('主题册已创建，上传时可归入')
  }

  build() {
    Column() {
      Row() {
        Text('相册')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Row() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { AlbumNav.openSearch() })
        if (this.selectMode) {
          Text('取消')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width(48)
            .height(48)
            .textAlign(TextAlign.Center)
            .onClick((): void => {
              this.selectMode = false
              this.selectedIds = []
            })
        } else {
          Text('多选')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width(48)
            .height(48)
            .textAlign(TextAlign.Center)
            .onClick((): void => { this.enterSelect() })
        }
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Scroll() {
        Column() {
          Text('智慧分册 · 点进去按人物/时间/地点自动归类')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .margin({ bottom: Theme.space.s2 })

          GridRow({ columns: 2, gutter: Theme.space.s3 }) {
            ForEach(this.categories, (c: CategoryItem) => {
              GridCol() {
                Stack({ alignContent: Alignment.BottomStart }) {
                  Image(c.cover)
                    .width('100%')
                    .height(88)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(Theme.radius.card)
                  Column()
                    .width('100%')
                    .height(48)
                    .linearGradient({
                      angle: 180,
                      colors: [['rgba(0,0,0,0)', 0], ['rgba(45,58,74,0.65)', 1]]
                    })
                    .borderRadius({ bottomLeft: Theme.radius.card, bottomRight: Theme.radius.card })
                  Text(`${c.label} · ${c.count}`)
                    .fontSize(Theme.type.subhead)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Medium)
                    .margin({ left: Theme.space.s3, bottom: Theme.space.s2 })
                }
                .onClick((): void => { AlbumNav.openFilter(c.id, '') })
              }
            }, (c: CategoryItem) => c.id)
          }
          .width('100%')
          .margin({ bottom: Theme.space.s5 })

          Row() {
            Text('主题册')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('新建')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .height(48)
              .onClick((): void => { this.showCreateAlbum = !this.showCreateAlbum })
          }
          .width('100%')

          if (this.showCreateAlbum) {
            Column() {
              TextInput({ text: this.newAlbumName, placeholder: '例如：暑假旅行' })
                .onChange((v: string) => { this.newAlbumName = v })
              AppButton({ label: '创建主题册', onTap: (): void => { void this.createAlbum() } })
                .margin({ top: Theme.space.s3 })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .margin({ bottom: Theme.space.s3 })
          }

          ForEach(this.albums, (a: ThemeAlbum) => {
            Row() {
              AppIcon({ name: 'book', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
              Text(`${a.title} · ${AlbumStore.byAlbum(a.id).length} 张`)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
                .margin({ left: Theme.space.s3 })
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
            }
            .width('100%')
            .height(48)
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .margin({ bottom: Theme.space.s2 })
            .onClick((): void => { AlbumNav.openFilter('album', a.id) })
          }, (a: ThemeAlbum) => a.id)

          Text('全部照片')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .margin({ top: Theme.space.s4, bottom: Theme.space.s3 })

          if (this.selectMode) {
            Text(this.selectedIds.length > 0 ? `已选 ${this.selectedIds.length} 张` : '点选下方照片')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
              .margin({ bottom: Theme.space.s2 })
          }

          if (this.photos.length === 0) {
            AppEmpty({
              title: '暂无照片',
              description: '上传后会按人物、时间、地点自动整理成分册',
              actionLabel: '上传照片',
              onAction: (): void => { AlbumNav.openUpload() }
            })
          } else {
            GridRow({ columns: 3, gutter: 4 }) {
              ForEach(this.photos, (p: FamilyPhoto) => {
                GridCol() {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    LocalPhotoImage({ uri: p.uri, squareFill: true, radius: Theme.radius.sm })
                    if (this.selectMode) {
                      Column() {
                        AppIcon({
                          name: this.isSelected(p.id) ? 'check' : 'empty',
                          iconSize: Theme.icon.sm,
                          color: Theme.colors().brandOnPrimary
                        })
                      }
                      .width(24)
                      .height(24)
                      .borderRadius(12)
                      .backgroundColor(this.isSelected(p.id) ? Theme.colors().brandPrimary : 'rgba(0,0,0,0.35)')
                      .justifyContent(FlexAlign.Center)
                      .margin(6)
                    }
                  }
                  .onClick((): void => {
                    if (this.selectMode) {
                      this.toggleSelect(p.id)
                      return
                    }
                    AlbumNav.openDetail(p.id)
                  })
                }
              }, (p: FamilyPhoto) => `${p.id}-${p.uri}`)
            }
            .width('100%')
          }

          if (this.selectMode) {
            AppButton({
              label: this.selectedIds.length > 0 ? `删除 ${this.selectedIds.length} 张` : '请点选照片',
              onTap: (): void => { void this.batchDelete() }
            })
              .margin({ top: Theme.space.s5 })
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
