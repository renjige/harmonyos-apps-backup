import { Theme } from '../design-system/Theme'
import { LifeListTemplate, LifeTodoItem } from '../../models/LifeModels'
import { LifeDateHelper, LifeLocalStore } from '../../services/LifeLocalStore'

@Component
export struct LifeListTemplateBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onApplied: () => void = () => {}
  @State toast: string = ''

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 1800)
  }

  private async apply(tpl: LifeListTemplate): Promise<void> {
    for (const line of tpl.lines) {
      const todo = LifeTodoItem.create(LifeDateHelper.newId(), line)
      todo.listKind = tpl.listKind
      await LifeLocalStore.saveTodo(todo)
    }
    this.onApplied()
    this.showToast(`已加入「${tpl.title}」，可再编辑`)
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('清单模板（点一下生成条目，不设系统提醒）')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(LifeListTemplate.all(), (tpl: LifeListTemplate) => {
          Text(tpl.title)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 10, right: 10, top: 8, bottom: 8 })
            .margin({ right: Theme.space.s2, bottom: Theme.space.s2 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { void this.apply(tpl) })
        }, (tpl: LifeListTemplate) => tpl.key)
      }
      .width('100%')
      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
