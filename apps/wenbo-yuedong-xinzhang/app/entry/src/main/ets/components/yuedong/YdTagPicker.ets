import { Theme } from '../design-system/Theme'
import { YdTag } from '../../models/YdModels'
import { YdLocalStore } from '../../services/YdLocalStore'
import { YdDetailNav } from '../../services/YdDetailNav'

@Component
export struct YdTagPicker {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entityType: string = 'task'
  @Prop @Watch('onEntityChange') entityId: string = ''
  onChanged: () => void = () => {}
  @State allTags: YdTag[] = []
  @State selectedIds: string[] = []

  aboutToAppear(): void {
    void this.load()
  }

  onEntityChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.entityId.length === 0) {
      return
    }
    this.allTags = await YdLocalStore.loadTags()
    this.selectedIds = await YdLocalStore.getEntityTagIds(this.entityType, this.entityId)
  }

  private isSelected(id: string): boolean {
    for (const s of this.selectedIds) {
      if (s === id) {
        return true
      }
    }
    return false
  }

  private async toggleTag(tagId: string): Promise<void> {
    const next: string[] = []
    let found = false
    for (const s of this.selectedIds) {
      if (s === tagId) {
        found = true
      } else {
        next.push(s)
      }
    }
    if (!found) {
      next.push(tagId)
    }
    this.selectedIds = next
    await YdLocalStore.setEntityTagIds(this.entityType, this.entityId, next)
    this.onChanged()
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text('标签')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
        Blank()
        Text('管理')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { YdDetailNav.openTagsManage() })
      }
      .width('100%')

      if (this.allTags.length === 0) {
        Text('暂无标签，点「管理」创建后可为内容分类')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textTertiary)
      } else {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          ForEach(this.allTags, (t: YdTag) => {
            Text(t.label)
              .fontSize(Theme.type.caption)
              .fontColor(this.isSelected(t.id) ? Theme.colors().brandOnPrimary : t.colorHex())
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.isSelected(t.id) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { void this.toggleTag(t.id) })
          }, (t: YdTag) => t.id)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Start)
  }
}
