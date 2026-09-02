import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { CwDateUtil, CwJournalEntry } from '../../models/ChenwuModels'
import { ChenwuStore } from '../../services/ChenwuStore'
import { ChenwuDetailNav } from '../../services/ChenwuDetailNav'
import { ChenwuMedia } from '../../services/ChenwuMedia'
import { CwConfirmDialog } from '../chenwu/CwConfirmDialog'

@Component
export struct JournalDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop journalId: string = ''
  onChanged: () => void = () => {}
  @State journal: CwJournalEntry = new CwJournalEntry()
  @State confirmDel: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await ChenwuStore.findJournal(this.journalId)
    if (found !== undefined) {
      this.journal = found
    }
  }

  private async remove(): Promise<void> {
    await ChenwuStore.deleteJournal(this.journalId)
    this.confirmDel = false
    this.onChanged()
    ChenwuDetailNav.closeJournal()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(ChenwuMedia.ambientJournal())
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(100)
              .linearGradient({ angle: 180, colors: [['rgba(61,90,108,0)', 0], ['rgba(61,90,108,0.82)', 1]] })
            Text('晨间札记')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F7F5F0')
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')
          .clip(true)
          .borderRadius(Theme.radius.md)

          Text(CwDateUtil.displayDate(this.journal.dateKey))
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          AppCard({ title: '今日完成' }) {
            Text(this.journal.doneToday.length > 0 ? this.journal.doneToday : '未填写')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }

          AppCard({ title: '今日发现' }) {
            Text(this.journal.discovery.length > 0 ? this.journal.discovery : '未填写')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }

          AppCard({ title: '明日调整' }) {
            Text(this.journal.tomorrowAdjust.length > 0 ? this.journal.tomorrowAdjust : '未填写')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }

          AppButton({ label: '编辑晨记', onTap: (): void => { ChenwuDetailNav.openJournalEditor(this.journal.id) } })
          AppButton({ label: '删除晨记', variant: 'danger', onTap: (): void => { this.confirmDel = true } })
          Column().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)

      if (this.confirmDel) {
        CwConfirmDialog({
          title: '删除这条晨记？',
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
}
