import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { QgCategory, QgDateUtil, QgEntry, QgLabels, QgTheme } from '../../models/QgModels'
import { QgStore } from '../../services/QgStore'
import { QgDetailNav } from '../../services/QgDetailNav'
import { QgMedia } from '../../services/QgMedia'
import { QgConfirmDialog } from '../qg/QgConfirmDialog'

@Component
export struct EntryDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entryId: string = ''
  onChanged: () => void = () => {}
  @State entry: QgEntry = new QgEntry()
  @State catLabel: string = ''
  @State confirmDel: boolean = false
  @State themes: QgTheme[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await QgStore.findEntry(this.entryId)
    if (found !== undefined) {
      this.entry = found
    }
    const cats = await QgStore.loadCategories()
    this.catLabel = QgStore.categoryLabel(this.entry.categoryKey, cats)
    this.themes = await QgStore.loadThemes()
  }

  private async setStatus(status: string): Promise<void> {
    this.entry.status = status
    await QgStore.saveEntry(this.entry)
    this.onChanged()
    await this.reload()
  }

  private async toggleTheme(id: string): Promise<void> {
    this.entry.themeCsv = QgStore.toggleCsv(this.entry.themeCsv, id)
    await QgStore.saveEntry(this.entry)
    this.onChanged()
    await this.reload()
  }

  private async remove(): Promise<void> {
    await QgStore.deleteEntry(this.entryId)
    this.confirmDel = false
    this.onChanged()
    QgDetailNav.closeEntry()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(QgMedia.paperBanner())
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(100)
              .linearGradient({ angle: 180, colors: [['rgba(47,74,71,0)', 0], ['rgba(47,74,71,0.82)', 1]] })
            Text(this.entry.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F6F1E8')
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')
          .clip(true)
          .borderRadius(Theme.radius.md)

          Text(`${this.catLabel} · ${QgLabels.statusLabel(this.entry.status)} · ${QgDateUtil.displayDate(this.entry.dateKey)}`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          AppCard({ title: '摘要' }) {
            Text(this.entry.summaryText())
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }

          if (this.entry.templateKey !== 'blank') {
            AppCard({ title: QgLabels.templateLabel(this.entry.templateKey) }) {
              Column({ space: 8 }) {
                Text(`${QgLabels.fieldALabel(this.entry.templateKey)}：${this.entry.fieldA}`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(`${QgLabels.fieldBLabel(this.entry.templateKey)}：${this.entry.fieldB}`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(`${QgLabels.fieldCLabel(this.entry.templateKey)}：${this.entry.fieldC}`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
              }
            }
          }

          if (this.entry.body.length > 0) {
            AppCard({ title: '正文' }) {
              Text(this.entry.body)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
            }
          }

          Text('整理状态')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Row({ space: 8 }) {
            this.statusChip('inbox', '待整理')
            this.statusChip('normal', '普通')
            this.statusChip('important', '重要')
            this.statusChip('treasure', '珍藏')
          }

          if (this.themes.length > 0) {
            Text('归入主题')
              .fontSize(Theme.type.subtitleS)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.themes, (t: QgTheme) => {
                Text(t.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(QgStore.csvHas(this.entry.themeCsv, t.id) ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(QgStore.csvHas(this.entry.themeCsv, t.id) ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.toggleTheme(t.id) })
              }, (t: QgTheme) => t.id)
            }
          }

          AppButton({ label: '编辑札记', onTap: (): void => { QgDetailNav.openEntryEditor(this.entry.id, this.entry.templateKey) } })
          AppButton({ label: '删除', variant: 'danger', onTap: (): void => { this.confirmDel = true } })
          Column().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)

      if (this.confirmDel) {
        QgConfirmDialog({
          title: '删除这条札记？',
          message: '删除后无法恢复。',
          confirmLabel: '删除',
          onConfirm: (): void => { void this.remove() },
          onCancel: (): void => { this.confirmDel = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  statusChip(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.entry.status === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.entry.status === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.setStatus(key) })
  }
}
