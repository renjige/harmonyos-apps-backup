import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { ChecklistLine, ChecklistPack } from '../../models/JujiaModels'

@Component
export struct ChecklistDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop pack: ChecklistPack = new ChecklistPack()
  onClose: () => void = () => {}
  onToggleLine: (lineId: string) => void = (_id: string) => {}
  onDelete: () => void = () => {}

  build() {
    Column() {
      Row() {
        Row({ space: 6 }) {
          AppIcon({ name: 'close', iconSize: 18, color: Theme.colors().textPrimary })
          Text('关闭')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.button)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16 })

      Text(this.pack.title)
        .fontSize(Theme.type.titleM)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: 16, right: 16, top: 8 })
      Text(`${this.pack.kind} · 进度 ${this.pack.progressLabel()}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })

      Scroll() {
        Column({ space: 8 }) {
          ForEach(this.pack.lines, (ln: ChecklistLine) => {
            Row({ space: 10 }) {
              Toggle({ type: ToggleType.Checkbox, isOn: ln.done })
                .onChange(() => this.onToggleLine(ln.id))
              Text(ln.text)
                .fontSize(Theme.type.body)
                .fontColor(ln.done ? Theme.colors().textTertiary : Theme.colors().textPrimary)
                .decoration({ type: ln.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                .layoutWeight(1)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
          }, (ln: ChecklistLine) => ln.id)
          AppButton({ label: '删除清单', variant: 'danger', onTap: () => this.onDelete() })
        }
        .padding({ left: 16, right: 16, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
