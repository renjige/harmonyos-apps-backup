import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { QgClip, QgDateUtil, QgEntry, QgTheme } from '../../models/QgModels'
import { QgStore } from '../../services/QgStore'
import { QgDetailNav } from '../../services/QgDetailNav'
import { QgMedia } from '../../services/QgMedia'
import { EntryListCard } from '../qg/EntryListCard'
import { ClipListCard } from '../qg/ClipListCard'
import { QgConfirmDialog } from '../qg/QgConfirmDialog'

@Component
export struct ThemeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop themeId: string = ''
  onChanged: () => void = () => {}
  @State theme: QgTheme = new QgTheme()
  @State entries: QgEntry[] = []
  @State clips: QgClip[] = []
  @State confirmDel: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await QgStore.findTheme(this.themeId)
    if (found !== undefined) {
      this.theme = found
    }
    this.entries = await QgStore.entriesForTheme(this.themeId)
    this.clips = await QgStore.clipsForTheme(this.themeId)
  }

  private async remove(): Promise<void> {
    await QgStore.deleteTheme(this.themeId)
    this.onChanged()
    QgDetailNav.closeTheme()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(QgMedia.coverOf(this.theme.coverKey))
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
              Text(`${this.entries.length + this.clips.length} 条 · 更新于 ${QgDateUtil.displayDate(QgDateUtil.keyFromDate(new Date(this.theme.updatedAt)))}`)
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

          Text('册内札记')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.entries.length === 0) {
            AppEmpty({ title: '还没有札记', description: '在札记详情里点选本主题即可收入' })
          } else {
            ForEach(this.entries, (e: QgEntry) => {
              EntryListCard({
                entry: e,
                categoryLabel: e.categoryKey,
                onOpen: (): void => { QgDetailNav.openEntry(e.id) }
              })
            }, (e: QgEntry) => e.id)
          }

          Text('册内光影')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.clips.length === 0) {
            AppEmpty({ title: '还没有光影', description: '在光影详情里点选本主题即可收入' })
          } else {
            ForEach(this.clips, (c: QgClip) => {
              ClipListCard({ item: c, onOpen: (): void => { QgDetailNav.openClip(c.id) } })
            }, (c: QgClip) => c.id)
          }

          AppButton({ label: '编辑主题', onTap: (): void => { QgDetailNav.openThemeEditor(this.theme.id) } })
          AppButton({ label: '删除主题', variant: 'danger', onTap: (): void => { this.confirmDel = true } })
          Column().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
      .height('100%')

      if (this.confirmDel) {
        QgConfirmDialog({
          title: '删除这个主题？',
          message: '主题册将被删除，内容本身仍保留在札记与光影里。',
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
