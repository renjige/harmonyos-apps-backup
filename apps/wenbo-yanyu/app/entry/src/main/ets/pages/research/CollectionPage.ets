import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { AppEmpty } from '../../components/design-system/AppEmpty'
import { ResearchBar } from '../../components/research/ResearchBar'
import { CollectionFolder, ResearchNote } from '../../models/ResearchModels'
import { ResearchNav } from '../../services/ResearchNav'
import { ResearchStore } from '../../services/ResearchStore'

@Component
export struct CollectionPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State folders: CollectionFolder[] = []
  @State starred: ResearchNote[] = []
  @State title: string = ''
  @State filterId: string = 'starred'
  @State filtered: ResearchNote[] = []
  @State toastText: string = ''
  @State pendingId: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.folders = await ResearchStore.listFolders()
    this.starred = await ResearchStore.notesInCollection('starred')
    if (this.filterId === 'starred') {
      this.filtered = this.starred
    } else {
      this.filtered = await ResearchStore.notesInCollection(this.filterId)
    }
  }

  private async addFolder(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写收藏分类名')
      return
    }
    const f = CollectionFolder.create()
    f.title = this.title.trim()
    await ResearchStore.saveFolder(f)
    this.title = ''
    this.showToast('分类已创建')
    await this.reload()
  }

  private async pick(id: string): Promise<void> {
    this.filterId = id
    await this.reload()
  }

  private async assign(note: ResearchNote, folderId: string): Promise<void> {
    note.collectionId = folderId
    await ResearchStore.saveNote(note)
    this.showToast('已放入该分类')
    await this.reload()
  }

  private async removeFolder(id: string): Promise<void> {
    if (this.pendingId !== id) {
      this.pendingId = id
      this.showToast('再点一次确认删除分类')
      return
    }
    await ResearchStore.deleteFolder(id)
    this.pendingId = ''
    this.filterId = 'starred'
    await this.reload()
  }

  build() {
    Stack() {
      Column() {
        ResearchBar({ title: '收藏管理' })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextInput({ text: this.title, placeholder: '新建收藏分类，如：论文摘录' })
              .onChange((v: string) => { this.title = v })
            AppButton({
              label: '创建分类',
              variant: 'secondary',
              onTap: (): void => { void this.addFolder() }
            })
            Flex({ wrap: FlexWrap.Wrap }) {
              Text(`星标 ${this.starred.length}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.filterId === 'starred' ?
                  Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
                .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.filterId === 'starred' ?
                  Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { void this.pick('starred') })
              ForEach(this.folders, (f: CollectionFolder) => {
                Text(f.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.filterId === f.id ?
                    Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
                  .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.filterId === f.id ?
                    Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.pick(f.id) })
                  .gesture(
                    LongPressGesture().onAction((): void => { void this.removeFolder(f.id) })
                  )
              }, (f: CollectionFolder) => f.id)
            }
            .width('100%')
            Text('在笔记详情点「收藏」会进入星标；也可把星标笔记归入分类。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            if (this.filterId !== 'starred') {
              AppButton({
                label: this.pendingId === this.filterId ? '再点一次确认删除分类' : '删除当前分类',
                variant: 'danger',
                onTap: (): void => { void this.removeFolder(this.filterId) }
              })
            }
            if (this.filtered.length === 0) {
              AppEmpty({
                title: '该分类还是空的',
                description: '先在笔记详情收藏，再回到这里按分类查找。'
              })
            } else {
              ForEach(this.filtered, (n: ResearchNote) => {
                Column({ space: 6 }) {
                  Text(n.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .width('100%')
                  Text(n.viewpoint.length > 0 ? n.viewpoint : n.body)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.of(this.darkModeOn).textSecondary)
                    .maxLines(2)
                    .width('100%')
                  if (this.filterId === 'starred' && this.folders.length > 0) {
                    Flex({ wrap: FlexWrap.Wrap }) {
                      ForEach(this.folders, (f: CollectionFolder) => {
                        Text(`放入 ${f.title}`)
                          .fontSize(Theme.type.caption)
                          .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                          .margin({ right: 8, bottom: 4 })
                          .onClick((): void => { void this.assign(n, f.id) })
                      }, (f: CollectionFolder) => `put_${f.id}_${n.id}`)
                    }
                    .width('100%')
                  }
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { ResearchNav.openNoteDetail(n.id) })
              }, (n: ResearchNote) => n.id)
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.of(this.darkModeOn).surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
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
