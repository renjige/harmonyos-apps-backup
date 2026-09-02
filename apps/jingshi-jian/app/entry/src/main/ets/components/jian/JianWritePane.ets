import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { MoodSelector } from './MoodSelector'
import { JianEntry } from '../../models/JianModels'
import { DateHelper } from '../../services/DateHelper'
import { JianStore } from '../../services/JianStore'

@Component
export struct JianWritePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State body: string = ''
  @State moodId: string = ''
  @State saving: boolean = false
  @State toastText: string = ''
  @State entryId: string = ''
  @State dateKey: string = DateHelper.todayKey()
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    this.dateKey = DateHelper.todayKey()
    const draft = await JianStore.loadDraft(this.dateKey)
    this.body = draft[0]
    this.moodId = draft[1]
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    if (this.body.trim().length === 0) {
      this.showToast('请先写一点内容')
      return
    }
    this.saving = true
    let entry: JianEntry
    if (this.entryId.length > 0) {
      const found = await JianStore.findById(this.entryId)
      entry = found ?? JianEntry.createNew(this.dateKey)
    } else {
      entry = JianEntry.createNew(this.dateKey)
      this.entryId = entry.id
    }
    entry.body = this.body
    entry.moodId = this.moodId
    entry.dateKey = this.dateKey
    await JianStore.saveEntry(entry)
    this.saving = false
    this.showToast('落笔成笺')
    this.onSaved()
    setTimeout((): void => { this.onClose() }, 600)
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onClose() })

      Column() {
        Column() {
          Row() {
            Row() {
              AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.onClose() })
            Blank()
            Text('写一笺')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            if (this.saving) {
              Text('保存中…')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            } else {
              Column().width(44)
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Column({ space: 4 }) {
                Text(DateHelper.displayDate(this.dateKey))
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(DateHelper.displayWeekday(this.dateKey))
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)

              TextArea({ text: this.body, placeholder: '在此落笔，记录此刻心绪…' })
                .width('100%')
                .height(160)
                .fontSize(Theme.type.bodyL)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .padding(Theme.space.s4)
                .onChange((v: string): void => {
                  this.body = v
                  void JianStore.saveDraft(this.dateKey, v, this.moodId)
                })

              Column({ space: Theme.space.s3 }) {
                Text('今日心情')
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                MoodSelector({
                  selectedId: this.moodId,
                  onSelect: (id: string): void => {
                    this.moodId = id
                    void JianStore.saveDraft(this.dateKey, this.body, id)
                  }
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.s3,
              bottom: Theme.space.s4
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)

          Column() {
            AppButton({
              label: '保存笺页',
              variant: 'primary',
              onTap: (): void => { void this.save() }
            })
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s3,
            bottom: Theme.space.s8
          })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
      }
      .width('100%')
      .height('90%')
      .justifyContent(FlexAlign.End)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '20%', y: 48 })
          .zIndex(80)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(60)
    .onAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', true)
    })
    .onDisAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
    })
  }
}
