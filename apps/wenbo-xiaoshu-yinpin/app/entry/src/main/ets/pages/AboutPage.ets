import { Theme } from '../components/design-system/Theme'
import { DetailShell } from '../components/detail/DetailShell'
import { DrinkDetailNav } from '../services/DrinkDetailNav'

@Component
export struct AboutPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  build() {
    DetailShell({
      title: '关于',
      contentKey: 'about',
      onClose: () => DrinkDetailNav.close()
    }) {
      Column({ space: Theme.space.s3 }) {
        Text('消暑饮品')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('按体感温度与时段智慧推荐自制消暑饮。游客可浏览饮品库；登录后可收藏、记下试做。不申请定位，不含支付与外卖，不含生成式对话。')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text('运营者：承德锐泓科技信息有限公司')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text('版本 1.0.0')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}
