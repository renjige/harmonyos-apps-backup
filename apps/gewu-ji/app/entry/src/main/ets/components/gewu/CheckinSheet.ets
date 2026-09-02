import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { FieldStore } from '../../services/FieldStore'
import { GewuDetailNav } from '../../services/GewuDetailNav'
import { KnowledgeCatalog } from '../../services/KnowledgeCatalog'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct CheckinSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTokenChange') refreshToken: number = 0
  onSaved: () => void = () => {}
  @State note: string = ''
  @State objectTitle: string = ''
  @State objectId: string = ''
  @State already: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.hydrate()
  }

  onTokenChange(): void {
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    const obj = KnowledgeCatalog.todayObject()
    this.objectId = obj.id
    this.objectTitle = obj.title
    const cur = await FieldStore.todayCheckin()
    this.already = cur !== undefined
    this.note = cur !== undefined ? cur.note : ''
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    const ok = await FieldStore.saveCheckin(this.note, this.objectId)
    if (ok) {
      this.onSaved()
      this.showToast('物候已记下')
      setTimeout((): void => { GewuDetailNav.closePractice() }, 400)
    }
  }

  build() {
    Stack() {
      DetailShell({
        title: '物候打卡',
        onClose: (): void => { GewuDetailNav.closePractice() },
        body: (): void => { this.Body() }
      })
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Body() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text(DateHelper.displayDate(DateHelper.todayKey()))
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(`今日知识物：${this.objectTitle}`)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.already ? '今天已经打过卡，可补充说明后再次保存。' : '用一句话记下今日物候：天气、光线、心情或你看见的变化。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.note, placeholder: '选填：今日补充说明' })
          .width('100%')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .padding(12)
          .onChange((v: string): void => { this.note = v })
        AppButton({
          label: this.already ? '更新今日打卡' : '完成今日打卡',
          variant: 'primary',
          onTap: (): void => { void this.save() }
        })
        Row().height(Theme.space.s10)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}
