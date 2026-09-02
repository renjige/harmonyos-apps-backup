import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { DetailShell } from './DetailShell'
import { RmWish, RmDateUtil, RmLabels } from '../../models/RmModels'
import { RmStore } from '../../services/RmStore'
import { RmDetailNav } from '../../services/RmDetailNav'

@Component
export struct WishEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  onChanged: () => void = () => {}
  @State text: string = ''
  @State clipKind: string = 'moment'
  @State dateKey: string = RmDateUtil.todayKey()
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    if (this.editId.length === 0) {
      return
    }
    const found = await RmStore.findWish(this.editId)
    if (found !== undefined) {
      this.text = found.text
      this.clipKind = found.clipKind
      this.dateKey = found.dateKey
    }
  }

  private async save(): Promise<void> {
    if (this.text.trim().length === 0) {
      this.toastText = '请写下要收藏的内容'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    let c = new RmWish()
    if (this.editId.length > 0) {
      const found = await RmStore.findWish(this.editId)
      if (found !== undefined) {
        c = found
      }
    } else {
      c = RmWish.createNew(this.text.trim(), this.clipKind)
    }
    c.text = this.text.trim()
    c.clipKind = this.clipKind
    c.dateKey = this.dateKey
    await RmStore.saveWish(c)
    this.onChanged()
    RmDetailNav.closeWishEditor()
    RmDetailNav.openWish(c.id)
  }

  build() {
    Stack() {
      DetailShell({ title: this.editId.length > 0 ? '编辑观察' : '收藏观察', onClose: (): void => { RmDetailNav.closeWishEditor() } }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('类型')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              this.kindChip('quote')
              this.kindChip('idea')
              this.kindChip('moment')
              this.kindChip('spark')
              this.kindChip('find')
            }
            TextArea({ text: this.text, placeholder: '一句话、一个想法、一个瞬间…' })
              .onChange((v: string): void => { this.text = v })
              .height(140)
            AppDatePickerField({
              label: '日期',
              value: this.dateKey,
              minDaysFromToday: -3650,
              maxDaysFromToday: 1,
              onChange: (v: string): void => { this.dateKey = v }
            })
            AppButton({ label: '保存', onTap: (): void => { void this.save() } })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .layoutWeight(1)
        .width('100%')
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .margin({ top: 16 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.sm)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  kindChip(key: string) {
    Text(RmLabels.clipKindLabel(key))
      .fontSize(Theme.type.caption)
      .fontColor(this.clipKind === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.clipKind === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.clipKind = key })
  }
}
