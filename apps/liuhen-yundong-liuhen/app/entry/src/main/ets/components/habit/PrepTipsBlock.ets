import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { PrepList, TipNote } from '../../models/HabitModels'
import { HabitStore } from '../../services/HabitStore'

@Component
export struct PrepTipsBlock {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onListsChange') lists: PrepList[] = []
  @Prop @Watch('onTipsChange') tips: TipNote[] = []
  onChanged: () => void = () => {}
  @State displayLists: PrepList[] = []
  @State displayTips: TipNote[] = []
  @State listRevision: number = 0
  @State tipTitle: string = ''
  @State tipBody: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    this.syncFromProps()
  }

  onListsChange(): void {
    this.syncFromProps()
  }

  onTipsChange(): void {
    this.syncFromProps()
  }

  private syncFromProps(): void {
    this.displayLists = PrepList.cloneAll(this.lists)
    const next: TipNote[] = []
    for (const t of this.tips) {
      const copy = new TipNote()
      copy.id = t.id
      copy.title = t.title
      copy.body = t.body
      next.push(copy)
    }
    this.displayTips = next
    this.listRevision++
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private applyToggleLocal(listId: string, itemIndex: number): void {
    const next: PrepList[] = []
    for (const list of this.displayLists) {
      if (list.id === listId) {
        const copy = PrepList.cloneOne(list)
        const items = copy.itemArr()
        const parts: string[] = []
        for (let i = 0; i < items.length; i++) {
          if (i === itemIndex) {
            parts.push(copy.isChecked(i) ? '0' : '1')
          } else {
            parts.push(copy.isChecked(i) ? '1' : '0')
          }
        }
        copy.checks = parts.join(',')
        next.push(copy)
      } else {
        next.push(PrepList.cloneOne(list))
      }
    }
    this.displayLists = next
    this.listRevision++
  }

  private async toggleItem(listId: string, itemIndex: number): Promise<void> {
    this.applyToggleLocal(listId, itemIndex)
    await HabitStore.toggleListItem(listId, itemIndex)
    this.onChanged()
  }

  private async addTip(): Promise<void> {
    if (this.tipTitle.trim().length < 2 || this.tipBody.trim().length < 2) {
      this.showToast('请填写心得标题和内容')
      return
    }
    const tip = new TipNote()
    tip.id = `tip_${Date.now()}`
    tip.title = this.tipTitle.trim()
    tip.body = this.tipBody.trim()
    await HabitStore.saveTip(tip)
    this.tipTitle = ''
    this.tipBody = ''
    this.displayTips = await HabitStore.loadTips()
    this.onChanged()
  }

  @Builder
  CheckMark(checked: boolean) {
    Column() {
      if (checked) {
        AppIcon({
          name: 'check',
          iconSize: Theme.icon.sm,
          color: Theme.colors().brandOnPrimary
        })
      }
    }
    .width(22)
    .height(22)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(checked ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
    .borderRadius(6)
    .border({
      width: 1,
      color: checked ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
    })
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Text('准备清单')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Column({ space: Theme.space.s3 }) {
        ForEach(this.displayLists, (list: PrepList) => {
          Column({ space: Theme.space.s2 }) {
            Text(list.title)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(list.itemArr(), (item: string, index: number) => {
              Row({ space: Theme.space.s2 }) {
                this.CheckMark(list.isChecked(index))
                Text(item)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(list.isChecked(index) ?
                    Theme.colors().textSecondary : Theme.colors().textPrimary)
                  .decoration({ type: list.isChecked(index) ? TextDecorationType.LineThrough : TextDecorationType.None })
              }
              .width('100%')
              .padding({ top: 4, bottom: 4 })
              .onClick((): void => { void this.toggleItem(list.id, index) })
            }, (item: string, index: number) => `${list.id}_${index}_${this.listRevision}_${list.isChecked(index) ? '1' : '0'}`)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }, (list: PrepList) => `${list.id}_${this.listRevision}_${list.checks}`)
      }

      Text('运动心得')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      TextInput({ text: this.tipTitle, placeholder: '标题，如：晨跑热身' })
        .onChange((v: string): void => { this.tipTitle = v })
      TextInput({ text: this.tipBody, placeholder: '记下今天的训练体验' })
        .onChange((v: string): void => { this.tipBody = v })
      AppButton({ label: '收藏这条心得', variant: 'secondary', onTap: (): void => { void this.addTip() } })
      ForEach(this.displayTips, (tip: TipNote) => {
        Column({ space: 4 }) {
          Text(tip.title)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(tip.body)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text('轻点删除')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onClick((): void => {
          void HabitStore.deleteTip(tip.id).then(async (): Promise<void> => {
            this.displayTips = await HabitStore.loadTips()
            this.onChanged()
          })
        })
      }, (tip: TipNote) => tip.id)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
      }
    }
    .width('100%')
  }
}
