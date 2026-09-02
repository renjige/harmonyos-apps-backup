import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { InsightEntry } from '../../models/InsightModels'
import { DateHelper } from '../../services/DateHelper'
import { InsightStore } from '../../services/InsightStore'
import { PromptCatalog } from '../../services/PromptCatalog'

@Component
export struct WeekReviewPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State a1: string = ''
  @State a2: string = ''
  @State a3: string = ''
  @State toastText: string = ''

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    if (this.a1.trim().length === 0 || this.a2.trim().length === 0 || this.a3.trim().length === 0) {
      this.showToast('三问都写完再保存')
      return
    }
    const e = InsightEntry.createNew(DateHelper.todayKey())
    e.title = '本周三问'
    e.body = `一、${PromptCatalog.weekQ1()}\n${this.a1.trim()}\n\n` +
      `二、${PromptCatalog.weekQ2()}\n${this.a2.trim()}\n\n` +
      `三、${PromptCatalog.weekQ3()}\n${this.a3.trim()}`
    e.tags = '本周三问'
    e.frameKind = 'review'
    e.notebookId = 'nb_work'
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
        DetailShell({ title: '本周三问', onClose: (): void => { this.onClose() } })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('不是流水账周报。对照判断有没有被现实碰到，再决定下周验证什么。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(22)
              .width('100%')
            Text(PromptCatalog.weekQ1())
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.a1, placeholder: '应验 / 落空 / 要修正…' })
              .width('100%')
              .height(88)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .onChange((v: string) => { this.a1 = v })
            Text(PromptCatalog.weekQ2())
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.a2, placeholder: '那件还没写成见解的事' })
              .width('100%')
              .height(88)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .onChange((v: string) => { this.a2 = v })
            Text(PromptCatalog.weekQ3())
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.a3, placeholder: '下周要看清的一件事，以及验证信号' })
              .width('100%')
              .height(88)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .onChange((v: string) => { this.a3 = v })
            AppButton({
              label: '生成本周见解',
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
