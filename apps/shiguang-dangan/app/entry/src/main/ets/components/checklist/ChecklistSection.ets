import { Theme } from '../design-system/Theme'
import { ChecklistItem } from '../../models/LifeModels'

@Component
export struct ChecklistSection {
  @Prop items: ChecklistItem[] = []
  onToggleStatus: (id: string) => void = () => {}
  onDelete: (id: string) => void = () => {}

  private itemsForCategory(cat: string): ChecklistItem[] {
    const out: ChecklistItem[] = []
    for (const c of this.items) {
      if (c.category === cat) {
        out.push(c)
      }
    }
    return out
  }

  private statusLabel(status: string): string {
    if (status === 'active') {
      return '进行中'
    }
    if (status === 'done') {
      return '已完成'
    }
    return '待开始'
  }

  private statusColor(status: string): string {
    if (status === 'done') {
      return Theme.colors().success
    }
    if (status === 'active') {
      return Theme.colors().brandPrimary
    }
    return Theme.colors().textTertiary
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      ForEach(ChecklistItem.allCategories(), (cat: string) => {
        if (this.itemsForCategory(cat).length > 0) {
          Column({ space: Theme.space.s2 }) {
            Text(ChecklistItem.categoryLabel(cat))
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.itemsForCategory(cat), (item: ChecklistItem) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(Theme.type.body)
                    .fontColor(item.status === 'done' ?
                      Theme.colors().textTertiary : Theme.colors().textPrimary)
                    .decoration({ type: item.status === 'done' ? TextDecorationType.LineThrough : TextDecorationType.None })
                    .layoutWeight(1)
                  Text(this.statusLabel(item.status))
                    .fontSize(Theme.type.overline)
                    .fontColor(this.statusColor(item.status))
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .backgroundColor(Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Text('切换')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => { this.onToggleStatus(item.id) })
                Text('删')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().danger)
                  .onClick((): void => { this.onDelete(item.id) })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (item: ChecklistItem) => item.id)
          }
        }
      }, (cat: string) => cat)
    }
    .width('100%')
  }
}
