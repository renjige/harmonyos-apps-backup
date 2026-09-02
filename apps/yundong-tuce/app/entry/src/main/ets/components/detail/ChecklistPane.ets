import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ChecklistItem } from '../../models/TuceModels'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'

@Component
export struct ChecklistPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tuceReload') @Watch('onReload') reloadToken: number = 0
  @State items: ChecklistItem[] = []
  @State listEpoch: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  onReload(): void {
    void this.load()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async load(): Promise<void> {
    this.items = await TuceStore.checklist()
    this.listEpoch++
  }

  private beforeItems(): ChecklistItem[] {
    const out: ChecklistItem[] = []
    for (const it of this.items) {
      if (it.phase === 'before') {
        out.push(it)
      }
    }
    return out
  }

  private afterItems(): ChecklistItem[] {
    const out: ChecklistItem[] = []
    for (const it of this.items) {
      if (it.phase === 'after') {
        out.push(it)
      }
    }
    return out
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('训练前后清单')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('逐项勾选，养成稳定训练习惯')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')

          Text('训练前')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.beforeItems(), (it: ChecklistItem) => {
            this.CheckRow(it)
          }, (it: ChecklistItem) => `${it.id}_${it.done ? '1' : '0'}_${this.listEpoch}`)

          Text('训练后')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.afterItems(), (it: ChecklistItem) => {
            this.CheckRow(it)
          }, (it: ChecklistItem) => `${it.id}_${it.done ? '1' : '0'}_${this.listEpoch}`)

          AppButton({
            label: '重置清单',
            variant: 'secondary',
            onTap: (): void => { void this.resetAll() }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  CheckRow(it: ChecklistItem) {
    Row({ space: Theme.space.s3 }) {
      Column()
        .width(22)
        .height(22)
        .borderRadius(11)
        .backgroundColor(it.done ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
        .border({ width: it.done ? 0 : 1, color: Theme.colors().strokeHairline })
      Text(it.label)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { void this.toggle(it.id) })
  }

  private async toggle(id: string): Promise<void> {
    await TuceStore.toggleChecklist(id)
    await this.load()
    TuceNav.bump()
    this.showToast('已更新清单')
  }

  private async resetAll(): Promise<void> {
    await TuceStore.resetChecklist()
    await this.load()
    TuceNav.bump()
    this.showToast('清单已重置')
  }
}
