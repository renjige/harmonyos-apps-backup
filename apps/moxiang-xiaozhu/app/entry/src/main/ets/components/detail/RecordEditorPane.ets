import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { InkWriteRequest } from '../../models/InkModels'
import { InkBizService } from '../../services/InkBizService'
import { InkDetailNav } from '../../services/InkDetailNav'

@Component
export struct RecordEditorPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop kind: string = 'note'
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State titleText: string = ''
  @State bodyText: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.prefill()
  }

  onRefreshTokenChange(): void {
    void this.prefill()
  }

  private async prefill(): Promise<void> {
    if (this.itemId.length === 0) {
      return
    }
    const found = this.kind === 'review' ?
      await InkBizService.findReview(this.itemId) :
      await InkBizService.findNote(this.itemId)
    if (found !== undefined) {
      this.titleText = found.title
      this.bodyText = found.body
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    const req = new InkWriteRequest()
    req.title = this.titleText.trim()
    req.body = this.bodyText.trim()
    if (req.title.length === 0 || req.body.length === 0) {
      this.showToast('请填写标题和正文')
      return
    }
    let ok = false
    if (this.kind === 'review') {
      if (this.itemId.length > 0) {
        ok = await InkBizService.updateReview(this.itemId, req)
      } else {
        ok = await InkBizService.saveReview(req)
      }
    } else if (this.itemId.length > 0) {
      ok = await InkBizService.updateNote(this.itemId, req)
    } else {
      ok = await InkBizService.saveNote(req)
    }
    if (ok) {
      InkDetailNav.bumpRefresh()
      InkDetailNav.close()
    } else {
      this.showToast('保存失败')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.kind === 'review' ? '写书评' : '写墨迹',
        onClose: (): void => { InkDetailNav.close() }
      }) {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.titleText, placeholder: '✨ 标题' })
            .onChange((v: string): void => { this.titleText = v })
          TextArea({ text: this.bodyText, placeholder: '💭 写下此刻的感受…' })
            .layoutWeight(1)
            .onChange((v: string): void => { this.bodyText = v })
          AppButton({
            label: '保存',
            variant: 'primary',
            onTap: (): void => { void this.save() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
        .layoutWeight(1)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
