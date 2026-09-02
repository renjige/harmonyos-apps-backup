import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppButton } from '../components/design-system/AppButton'
import { AskNav } from '../services/AskNav'
import { GrowthStore } from '../services/GrowthStore'
import { LearnStore } from '../services/LearnStore'
import { VaultStore } from '../services/VaultStore'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('vaultRefresh') @Watch('onRefresh') vaultRefresh: number = 0
  @State todayAsk: number = 0
  @State weekCheckin: number = 0
  @State monthCheckin: number = 0
  @State weekLearn: number = 0
  @State collectTotal: number = 0

  aboutToAppear(): void {
    this.sync()
  }

  onRefresh(): void {
    this.sync()
  }

  private sync(): void {
    this.todayAsk = LearnStore.todayCount()
    this.weekCheckin = GrowthStore.weekCheckinCount()
    this.monthCheckin = GrowthStore.monthCheckinCount()
    this.collectTotal = VaultStore.count()
    let sum = 0
    const days = GrowthStore.weekDayCounts()
    for (const d of days) {
      sum += d.count
    }
    this.weekLearn = sum
  }

  build() {
    Column() {
      AppNavBar({ title: '学习回顾', onBack: (): void => { AskNav.closeLearn() } })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          this.ReviewCard('今日回顾', `今日学习 ${this.todayAsk} 次，连续 ${VaultStore.streakDays()} 天`)
          this.ReviewCard('本周回顾', `本周学习动作 ${this.weekLearn} 次，打卡 ${this.weekCheckin} 天`)
          this.ReviewCard('本月回顾', `本月打卡 ${this.monthCheckin} 天，累计收藏 ${this.collectTotal} 条`)
          AppButton({
            label: '查看成长统计',
            variant: 'secondary',
            onTap: (): void => { AskNav.openLearn('stats') }
          })
          AppButton({
            label: '打开学习动态',
            variant: 'secondary',
            onTap: (): void => { AskNav.openLearn('timeline') }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  ReviewCard(title: string, body: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(body)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
  }
}
