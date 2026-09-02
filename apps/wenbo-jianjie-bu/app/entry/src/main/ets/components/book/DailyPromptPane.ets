import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { InsightEntry } from '../../models/InsightModels'
import { DateHelper } from '../../services/DateHelper'
import { InsightStore } from '../../services/InsightStore'
import { PromptCatalog } from '../../services/PromptCatalog'

@Component
export struct DailyPromptPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State answer: string = ''
  @State toastText: string = ''
  private question: string = PromptCatalog.todayQuestion()

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    if (this.answer.trim().length === 0) {
      this.showToast('先写下你的回答')
      return
    }
    const e = InsightEntry.createNew(DateHelper.todayKey())
    e.title = '今日一问'
    e.body = `问：${this.question}\n\n答：${this.answer.trim()}`
    e.tags = '今日一问'
    e.frameKind = 'flash'
    e.notebookId = 'nb_life'
    const ok = await InsightStore.saveEntry(e)
    if (!ok) {
      this.showToast(InsightStore.lastError)
      return
    }
    this.onSaved()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        DetailShell({ title: '今日一问', onClose: (): void => { this.onClose() } })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('每天一题，把闪念逼成一句判断。回答会写入记录页。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(22)
              .width('100%')
            Text(this.question)
              .fontSize(Theme.type.subtitleL)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.answer, placeholder: '现象、判断、所以呢。写三句也够。' })
              .width('100%')
              .height(160)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .onChange((v: string) => { this.answer = v })
            AppButton({
              label: '写入见解簿',
              variant: 'primary',
              onTap: (): void => { void this.save() }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontColor('#FFFFFF')
          .fontSize(Theme.type.footnote)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
