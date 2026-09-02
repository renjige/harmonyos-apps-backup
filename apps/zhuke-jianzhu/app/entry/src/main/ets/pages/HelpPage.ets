import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppCard } from '../components/design-system/AppCard'

class HelpItem {
  q: string = ''
  a: string = ''

  static make(q: string, a: string): HelpItem {
    const h = new HelpItem()
    h.q = q
    h.a = a
    return h
  }
}

@Component
export struct HelpPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onBack: () => void = () => {}

  private items: HelpItem[] = [
    HelpItem.make('如何查看项目进度？', '进入「项目」Tab，点击项目卡片可查看详情与施工进度、负责人及状态流转。'),
    HelpItem.make('安全巡检如何闭环？', '「巡检」Tab 展示安全检查与隐患记录。进入详情后可标记整改中或已关闭。'),
    HelpItem.make('工程资料在哪里？', '「资料」Tab 按施工图纸、合同、报告等分类浏览，支持查看版本与审核状态。'),
    HelpItem.make('忘记密码怎么办？', '请联系企业管理员在管理后台重置账号，或使用注册功能创建新账号。')
  ]

  build() {
    Column() {
      AppNavBar({ title: '帮助中心', onBack: () => this.onBack() })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppCard({ title: '筑科建筑使用指南' }) {
            Text('面向建筑工程企业的智慧工程管理应用，覆盖项目、安全、质量、资料与人员协同。')
              .fontSize(Theme.type.callout)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(24)
          }

          ForEach(this.items, (item: HelpItem) => {
            AppCard({ title: item.q }) {
              Text(item.a)
                .fontSize(Theme.type.callout)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .lineHeight(22)
            }
          }, (item: HelpItem) => item.q)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s10
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
