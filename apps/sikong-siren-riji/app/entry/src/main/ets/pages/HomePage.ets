import { Theme } from '../components/design-system/Theme'
import { AppBrandHero } from '../components/design-system/AppHeader'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppCard } from '../components/design-system/AppCard'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '内蒙古井良网络科技有限公司'
  @Prop appName: string = '井良智企管家'
  @Prop tagline: string = '企业数字化管理平台，AI经营分析、多端协同'
  onOpenMessages: () => void = () => {}

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        AppBrandHero({ company: this.company, appName: this.appName, tagline: this.tagline })
        Row({ space: Theme.space.s3 }) {
          AppStatCard({ label: '本月营收', value: '￥128万', trend: '环比 +8%', positive: true })
            .layoutWeight(1)
          AppStatCard({ label: '待办任务', value: '12', trend: '3项高优', positive: false })
            .layoutWeight(1)
        }
        .width('100%')
        AppCard({ title: '快捷入口', variant: 'plain' }) {
          Text('智企协同 · AI 经营分析 · 数据看板 · 多端同步')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        AppCard({ title: 'AI 经营助手', variant: 'glass' }) {
          Text('一键生成经营周报、分析本月概况与任务优先级')
            .fontSize(Theme.type.callout)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        AppCard({
          title: '消息中心',
          variant: 'outlined',
          onTap: () => this.onOpenMessages()
        }) {
          Text('审批提醒与协同通知')
            .fontSize(Theme.type.callout)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s8
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
