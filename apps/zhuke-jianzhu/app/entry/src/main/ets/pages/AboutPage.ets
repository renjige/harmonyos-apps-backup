import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppCard } from '../components/design-system/AppCard'
import { ContentService } from '../services/ContentService'

@Component
export struct AboutPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '筑科建筑'
  onBack: () => void = () => {}

  build() {
    Column() {
      AppNavBar({ title: '关于我们', onBack: () => this.onBack() })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: Theme.space.s2 }) {
            Text(this.appName)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('版本 1.0.0')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textTertiary)
          }
          .width('100%')
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Center)

          AppCard({ title: '应用介绍' }) {
            Text('筑科建筑是筑科建筑工程有限公司官方展示应用，' +
              '提供企业宣传、工程案例、业务范围、资质荣誉、新闻资讯、人才招聘与联系我们等服务。' +
              '本应用不含在线支付、购物车、AI功能及用户社区。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(24)
          }

          AppCard({ title: '运营主体' }) {
            Column({ space: Theme.space.s2 }) {
              Text(ContentService.company().name)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(ContentService.contact().address)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s8
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
