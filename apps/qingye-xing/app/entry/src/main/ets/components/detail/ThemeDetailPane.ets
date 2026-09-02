import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { QyClip, QyDateUtil, QyEntry, QyTheme } from '../../models/QyModels'
import { QyStore } from '../../services/QyStore'
import { QyDetailNav } from '../../services/QyDetailNav'
import { QyMedia } from '../../services/QyMedia'
import { EntryListCard } from '../qy/EntryListCard'
import { ClipListCard } from '../qy/ClipListCard'
import { QyConfirmDialog } from '../qy/QyConfirmDialog'

@Component
export struct ThemeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop themeId: string = ''
  onChanged: () => void = () => {}
  @State theme: QyTheme = new QyTheme()
  @State entries: QyEntry[] = []
  @State clips: QyClip[] = []
  @State confirmDel: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await QyStore.findTheme(this.themeId)
    if (found !== undefined) {
      this.theme = found
    }
    this.entries = await QyStore.entriesForTheme(this.themeId)
    this.clips = await QyStore.clipsForTheme(this.themeId)
  }

  private async remove(): Promise<void> {
    await QyStore.deleteTheme(this.themeId)
    this.onChanged()
    QyDetailNav.closeTheme()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(QyMedia.coverOf(this.theme.coverKey))
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
              Text(`${this.entries.length + this.clips.length} 条 · 更新于 ${QyDateUtil.displayDate(QyDateUtil.keyFromDate(new Date(this.theme.updatedAt)))}`)
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

          Text('册内记录')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.entries.length === 0) {
            AppEmpty({ title: '还没有记录', description: '在记录详情里点选本主题即可收入' })
          } else {
            ForEach(this.entries, (e: QyEntry) => {
              EntryListCard({
                entry: e,
                categoryLabel: e.categoryKey,
                onOpen: (): void => { QyDetailNav.openEntry(e.id) }
              })
            }, (e: QyEntry) => e.id)
          }

          Text('册内观察')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.clips.length === 0) {
            AppEmpty({ title: '还没有观察', description: '在观察详情里点选本主题即可收入' })
          } else {
            ForEach(this.clips, (c: QyClip) => {
              ClipListCard({ item: c, onOpen: (): void => { QyDetailNav.openClip(c.id) } })
            }, (c: QyClip) => c.id)
          }

          AppButton({ label: '编辑主题', onTap: (): void => { QyDetailNav.openThemeEditor(this.theme.id) } })
          AppButton({ label: '删除主题', variant: 'danger', onTap: (): void => { this.confirmDel = true } })
          Column().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
      .height('100%')

      if (this.confirmDel) {
        QyConfirmDialog({
          title: '删除这个主题？',
          message: '主题册将被删除，内容本身仍保留在记录与观察里。',
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
