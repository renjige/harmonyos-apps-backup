import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ThemeAlbum } from '../../models/LifeModels'
import { LifeStore } from '../../services/LifeStore'
import { LifeStorePhase3 } from '../../services/LifeStorePhase3'
import { ArchiveStore } from '../../services/ArchiveStore'
import { ThemeAlbumCover } from './ThemeAlbumCover'

class RefDisplayItem {
  ref: string = ''
  title: string = ''
  typeLabel: string = ''

  static make(ref: string, title: string, typeLabel: string): RefDisplayItem {
    const r = new RefDisplayItem()
    r.ref = ref
    r.title = title
    r.typeLabel = typeLabel
    return r
  }
}

@Component
export struct ThemeAlbumDetailPane {
  @Prop albumId: string = ''
  @State album: ThemeAlbum = new ThemeAlbum()
  @State refItems: RefDisplayItem[] = []
  @State editTitle: string = ''
  @State editSummary: string = ''
  @State showEdit: boolean = false
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await LifeStorePhase3.findThemeAlbum(this.albumId)
    if (found !== undefined) {
      this.album = found
      this.editTitle = found.title
      this.editSummary = found.summary
      await this.resolveRefs()
    }
  }

  private async resolveRefs(): Promise<void> {
    const items: RefDisplayItem[] = []
    for (const ref of this.album.refList()) {
      if (ref.startsWith('arc:')) {
        const id = ref.substring(4)
        const a = await ArchiveStore.findArchive(id)
        items.push(RefDisplayItem.make(ref, a !== undefined ? a.title : id, '档案'))
      } else if (ref.startsWith('insp:')) {
        const id = ref.substring(5)
        const list = await LifeStore.loadInspirations()
        let title = id
        for (const i of list) {
          if (i.id === id) {
            title = i.text.length > 30 ? i.text.substring(0, 30) + '…' : i.text
          }
        }
        items.push(RefDisplayItem.make(ref, title, '灵感'))
      } else if (ref.startsWith('moment:')) {
        const id = ref.substring(7)
        const list = await LifeStore.loadMoments()
        let title = id
        for (const m of list) {
          if (m.id === id) {
            title = m.title
          }
        }
        items.push(RefDisplayItem.make(ref, title, '时刻'))
      }
    }
    this.refItems = items
  }

  private async saveEdit(): Promise<void> {
    this.album.title = this.editTitle.trim()
    this.album.summary = this.editSummary.trim()
    await LifeStorePhase3.saveThemeAlbum(this.album)
    this.showEdit = false
    this.onChanged()
    await this.reload()
  }

  private async removeRef(ref: string): Promise<void> {
    const refs = this.album.refList()
    const next: string[] = []
    for (const r of refs) {
      if (r !== ref) {
        next.push(r)
      }
    }
    this.album.itemRefs = next.join(',')
    await LifeStorePhase3.saveThemeAlbum(this.album)
    this.onChanged()
    await this.reload()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          ThemeAlbumCover({ album: this.album, compact: false, onTap: (): void => {} })
          AppButton({
            label: '编辑信息',
            variant: 'secondary',
            onTap: (): void => { this.showEdit = true }
          })
          Text('关联内容')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.refItems.length === 0) {
            Text('暂无关联，可从收藏中心添加')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
          } else {
            ForEach(this.refItems, (item: RefDisplayItem) => {
              Row({ space: Theme.space.s3 }) {
                Text(item.typeLabel)
                  .fontSize(Theme.type.overline)
                  .fontColor(Theme.colors().brandPrimary)
                Text(item.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text('移除')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().danger)
                  .onClick((): void => { void this.removeRef(item.ref) })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (item: RefDisplayItem) => item.ref)
          }
        }
        .padding(Theme.space.pageX)
      }
      .width('100%')
      .height('100%')

      if (this.showEdit) {
        this.EditOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  EditOverlay() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.showEdit = false })
      Column({ space: Theme.space.s4 }) {
        Text('编辑主题册')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        TextInput({ text: this.editTitle, placeholder: '标题' })
          .onChange((v: string): void => { this.editTitle = v })
        TextArea({ text: this.editSummary, placeholder: '摘要' })
          .height(80)
          .onChange((v: string): void => { this.editSummary = v })
        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: (): void => { this.showEdit = false }
          }).layoutWeight(1)
          AppButton({
            label: '保存',
            variant: 'primary',
            onTap: (): void => { void this.saveEdit() }
          }).layoutWeight(1)
        }
        .width('100%')
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(20)
  }
}
