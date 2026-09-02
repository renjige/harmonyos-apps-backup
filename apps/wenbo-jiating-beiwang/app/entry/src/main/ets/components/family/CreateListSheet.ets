import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct CreateListSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State title: string = ''
  onClose: () => void = () => {}
  onConfirm: (title: string) => void = () => {}

  build() {
    Column({ space: Theme.space.s5 }) {
      Row() {
        Text('新家庭清单')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('取消')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onClick(() => this.onClose())
      }
      .width('100%')
      TextInput({ text: this.title, placeholder: '例如 周末计划' })
        .height(48)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.lg)
        .padding({ left: 14, right: 14 })
        .onChange((v: string) => { this.title = v })
      Text('常用名称：周末计划、家庭清洁、节日准备、搬家准备')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      AppButton({
        label: '创建家庭清单',
        onTap: (): void => {
          if (this.title.trim().length === 0) {
            return
          }
          this.onConfirm(this.title.trim())
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
