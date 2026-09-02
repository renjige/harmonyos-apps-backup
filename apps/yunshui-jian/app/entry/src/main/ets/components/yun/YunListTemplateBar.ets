import { Theme } from '../design-system/Theme'
import { YunListTemplate, YunTodoItem } from '../../models/YunModels'
import { YunDateHelper, YunLocalStore } from '../../services/YunLocalStore'

@Component
export struct YunListTemplateBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onApplied: () => void = () => {}
  @State toast: string = ''

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 1800)
  }

  private async apply(tpl: YunListTemplate): Promise<void> {
    for (const line of tpl.lines) {
      const todo = YunTodoItem.create(YunDateHelper.newId(), line)
      todo.listKind = tpl.listKind
      await YunLocalStore.saveTodo(todo)
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
        ForEach(YunListTemplate.all(), (tpl: YunListTemplate) => {
          Text(tpl.title)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 10, right: 10, top: 8, bottom: 8 })
            .margin({ right: Theme.space.s2, bottom: Theme.space.s2 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { void this.apply(tpl) })
        }, (tpl: YunListTemplate) => tpl.key)
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
