import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { InspectionItem, InspectionRecord } from '../../models/QualityModels'
import { QualityLocalStore } from '../../services/QualityLocalStore'
import { QualityService } from '../../services/QualityService'

@Component
struct CheckItemCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop title: string = ''
  @Prop status: string = 'ok'
  @State pressed: boolean = false
  onToggle: () => void = () => {}
  onCreateIssue: () => void = () => {}

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(this.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text(this.status === 'ok' ? '正常' : '存在问题')
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.status === 'ok' ? Theme.colors().success : Theme.colors().danger)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor(this.status === 'ok' ? Theme.colors().successContainer : Theme.colors().dangerContainer)
          .borderRadius(999)
      }
      .width('100%')
      if (this.status === 'issue') {
        Text('创建质量问题')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => this.onCreateIssue())
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(16)
    .opacity(this.pressed ? 0.86 : 1)
    .scale({ x: this.pressed ? 0.98 : 1, y: this.pressed ? 0.98 : 1 })
    .animation({ duration: Theme.motion.instant, curve: Curve.EaseOut })
    .onTouch((e: TouchEvent) => {
      if (e.type === TouchType.Down) {
        this.pressed = true
      }
      if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
        this.pressed = false
      }
    })
    .onClick(() => this.onToggle())
  }
}

@Component
export struct ChecklistPane {
  @Prop @Watch('onInspectId') inspectId: string = ''
  @State row: InspectionRecord = new InspectionRecord()
  @State items: InspectionItem[] = []
  @State missing: boolean = false
  onBack: () => void = () => {}
  onDone: (id: string) => void = (_id: string) => {}
  onCreateIssue: (inspectId: string, title: string) => void = (_i: string, _t: string) => {}

  aboutToAppear(): void {
    this.reload()
  }

  onInspectId(): void {
    this.reload()
  }

  private reload(): void {
    const found = QualityService.findInspection(this.inspectId)
    if (found === undefined) {
      this.missing = true
      return
    }
    this.missing = false
    this.row = found
    this.items = QualityLocalStore.parseItems(found.itemsJson)
  }

  private toggle(itemId: string): void {
    const next: InspectionItem[] = []
    for (const row of this.items) {
      const copy = new InspectionItem()
      copy.id = row.id
      copy.title = row.title
      if (row.id === itemId) {
        copy.status = row.status === 'ok' ? 'issue' : 'ok'
      } else {
        copy.status = row.status
      }
      next.push(copy)
    }
    this.items = next
    this.row.itemsJson = QualityLocalStore.stringifyItems(next)
    void QualityService.saveInspection(this.row)
  }

  private async finish(): Promise<void> {
    this.row.status = '已完成'
    await QualityService.saveInspection(this.row)
    this.onDone(this.row.id)
  }

  build() {
    Column() {
      Row() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          .rotate({ angle: 180 })
          .onClick(() => this.onBack())
        Text('巡查检查')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 16, right: 20, top: 16, bottom: 8 })

      if (this.missing) {
        Text('巡查不存在')
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(20)
      } else {
        Text(`${this.row.projectName}  ·  ${this.row.area}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding({ left: 20, right: 20, bottom: 8 })
          .width('100%')
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.items, (it: InspectionItem) => {
              CheckItemCard({
                itemId: it.id,
                title: it.title,
                status: it.status,
                onToggle: () => this.toggle(it.id),
                onCreateIssue: () => this.onCreateIssue(this.row.id, it.title)
              })
            }, (it: InspectionItem) => `${it.id}-${it.status}`)
          }
          .padding({ left: 20, right: 20, bottom: 24 })
        }
        .layoutWeight(1)
      }

      Column() {
        AppButton({ label: '完成巡查', onTap: (): void => { void this.finish() } })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20, top: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
