import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { BodyRichText } from './BodyRichText'
import { InsightEntry } from '../../models/InsightModels'
import { InsightStore } from '../../services/InsightStore'

@Component
export struct RecallPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}
  onMutated: () => void = () => {}
  @State entry: InsightEntry = new InsightEntry()
  @State reviewDraft: string = ''
  @State toastText: string = ''
  @State empty: boolean = false

  aboutToAppear(): void {
    void this.draw('')
  }

  private async draw(excludeId: string): Promise<void> {
    const found = await InsightStore.randomOne(excludeId)
    if (found === undefined) {
      this.empty = true
      return
    }
    this.empty = false
    this.entry = found
    this.reviewDraft = found.reviewNote
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async toggleStar(): Promise<void> {
    if (this.entry.id.length === 0) {
      return
    }
    const next = !this.entry.starred
    const ok = await InsightStore.patchMeta(this.entry.id, next, this.entry.pinned, this.entry.verdict)
    if (!ok) {
      this.showToast(InsightStore.lastError)
      return
    }
    this.entry.starred = next
    this.showToast(next ? '已星标' : '已取消星标')
    this.onMutated()
  }

  private async saveReview(): Promise<void> {
    if (this.entry.id.length === 0) {
      return
    }
    this.entry.reviewNote = this.reviewDraft
    const ok = await InsightStore.saveEntry(this.entry)
    if (!ok) {
      this.showToast(InsightStore.lastError)
      return
    }
    this.showToast('已写下现在怎么看')
    this.onMutated()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        DetailShell({ title: '随机回看', onClose: (): void => { this.onClose() } })
        if (this.empty) {
          AppEmpty({
            title: '还没有可回看的见解',
            description: '先写两条，再来抽旧想法对照。',
            actionLabel: '',
            onAction: (): void => {}
          })
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Text(this.entry.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
                .onClick((): void => { this.onOpen(this.entry.id) })
              BodyRichText({ body: this.entry.body.length > 0 ? this.entry.body : '（空）' })
              TextArea({ text: this.reviewDraft, placeholder: '现在怎么看？写一句对照当时的判断。' })
                .width('100%')
                .height(88)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .onChange((v: string) => { this.reviewDraft = v })
              AppButton({
                label: '保存现在怎么看',
                variant: 'primary',
                onTap: (): void => { void this.saveReview() }
              })
              AppButton({
                label: this.entry.starred ? '取消星标' : '星标这条',
                variant: 'secondary',
                onTap: (): void => { void this.toggleStar() }
              })
              AppButton({
                label: '再抽一条',
                variant: 'secondary',
                onTap: (): void => { void this.draw(this.entry.id) }
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
