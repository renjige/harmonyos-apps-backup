import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { XdClip, XdDateUtil, XdEntry, XdTheme } from '../../models/XdModels'
import { XdStore } from '../../services/XdStore'
import { XdDetailNav } from '../../services/XdDetailNav'
import { XdMedia } from '../../services/XdMedia'
import { EntryListCard } from '../xd/EntryListCard'
import { ClipListCard } from '../xd/ClipListCard'
import { XdConfirmDialog } from '../xd/XdConfirmDialog'

@Component
export struct ThemeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop themeId: string = ''
  onChanged: () => void = () => {}
  @State theme: XdTheme = new XdTheme()
  @State entries: XdEntry[] = []
  @State clips: XdClip[] = []
  @State confirmDel: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await XdStore.findTheme(this.themeId)
    if (found !== undefined) {
      this.theme = found
    }
    this.entries = await XdStore.entriesForTheme(this.themeId)
    this.clips = await XdStore.clipsForTheme(this.themeId)
  }

  private async remove(): Promise<void> {
    await XdStore.deleteTheme(this.themeId)
    this.onChanged()
    XdDetailNav.closeTheme()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(XdMedia.coverOf(this.theme.coverKey))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(100)
              .linearGradient({ angle: 180, colors: [['rgba(47,74,71,0)', 0], ['rgba(47,74,71,0.82)', 1]] })
            Column({ space: 4 }) {
              Text(this.theme.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F6F1E8')
              Text(`${this.entries.length + this.clips.length} 条 · 更新于 ${XdDateUtil.displayDate(XdDateUtil.keyFromDate(new Date(this.theme.updatedAt)))}`)
                .fontSize(Theme.type.footnote)
                .fontColor('#F6F1E8')
            }
            .padding({ left: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .clip(true)
          .borderRadius(Theme.radius.md)

          if (this.theme.summary.length > 0) {
            Text(this.theme.summary)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }

          Text('册内慢记')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.entries.length === 0) {
            AppEmpty({ title: '还没有慢记', description: '在慢记详情里点选本主题即可收入' })
          } else {
            ForEach(this.entries, (e: XdEntry) => {
              EntryListCard({
                entry: e,
                categoryLabel: e.categoryKey,
                onOpen: (): void => { XdDetailNav.openEntry(e.id) }
              })
            }, (e: XdEntry) => e.id)
          }

          Text('册内瞬间')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.clips.length === 0) {
            AppEmpty({ title: '还没有瞬间', description: '在瞬间详情里点选本主题即可收入' })
          } else {
            ForEach(this.clips, (c: XdClip) => {
              ClipListCard({ item: c, onOpen: (): void => { XdDetailNav.openClip(c.id) } })
            }, (c: XdClip) => c.id)
          }

          AppButton({ label: '编辑主题', onTap: (): void => { XdDetailNav.openThemeEditor(this.theme.id) } })
          AppButton({ label: '删除主题', variant: 'danger', onTap: (): void => { this.confirmDel = true } })
          Column().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
      .height('100%')

      if (this.confirmDel) {
        XdConfirmDialog({
          title: '删除这个主题？',
          message: '主题册将被删除，内容本身仍保留在慢记与瞬间里。',
          confirmLabel: '删除',
          onConfirm: (): void => { void this.remove() },
          onCancel: (): void => { this.confirmDel = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
