import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AuthService } from '../../services/AuthService'

@Component
export struct RitualBanner {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop doneToday: boolean = false
  onOpen: () => void = () => {}
  onRequireAuth: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('今日成长仪式')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (!AuthService.isLoggedIn()) {
        AppEmpty({
          title: '登录后完成三问仪式',
          description: '用 1 分钟对齐精力、最重要的事和给自己的一句话',
          actionLabel: '去登录',
          onAction: (): void => { this.onRequireAuth() }
        })
      } else if (this.doneToday) {
        Text('今日仪式已完成，可在成长记录里回顾。')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({
          label: '再看一次 / 补写',
          variant: 'secondary',
          onTap: (): void => { this.onOpen() }
        })
      } else {
        Text('三问对齐今天：精力、最重要的一件事、给自己的一句话。完成后会写入成长记录。')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({
          label: '开始今日仪式',
          onTap: (): void => { this.onOpen() }
        })
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().brandPrimaryContainer)
    .borderRadius(Theme.radius.xl)
    .alignItems(HorizontalAlign.Start)
  }
}
