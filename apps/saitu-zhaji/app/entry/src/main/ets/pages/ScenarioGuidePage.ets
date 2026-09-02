import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { SaituDetailNav } from '../services/SaituDetailNav'

class ScenarioItem {
  title: string = ''
  desc: string = ''
  actionLabel: string = ''

  static all(): ScenarioItem[] {
    const rows: string[][] = [
      ['现场观赛复盘', '记录比分、配图与四段结构化复盘，可复制分享', '写赛事复盘'],
      ['自主训练日志', '时长、强度、项目与训练感受，与观赛档案互补', '记训练'],
      ['旅途阶段推进', '旅途详情汇总札记/节点/计划/打卡，看板实时进度', '管理旅途'],
      ['球队选手关注', '关注详情自动关联赛事档案，沉淀个人主队记忆', '添加关注'],
      ['习惯打卡月历', '每日打卡 + 月历回顾，连续天与成就联动', '去打卡'],
      ['成长数据导出', '一键导出全量 JSON，含札记/赛事/训练/打卡/成就', '去我的导出']
    ]
    const out: ScenarioItem[] = []
    for (const r of rows) {
      const s = new ScenarioItem()
      s.title = r[0]
      s.desc = r[1]
      s.actionLabel = r[2]
      out.push(s)
    }
    return out
  }
}

@Component
export struct ScenarioGuidePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  private items: ScenarioItem[] = ScenarioItem.all()

  private runAction(label: string): void {
    SaituDetailNav.closeScenarioGuide()
    if (label === '写赛事复盘') {
      SaituDetailNav.openNewSportEditor('review', '')
      return
    }
    if (label === '记训练') {
      SaituDetailNav.openNewTrainingEditor()
      return
    }
    if (label === '管理旅途') {
      SaituDetailNav.openJourneyManage()
      return
    }
    if (label === '添加关注') {
      SaituDetailNav.openFollow()
      return
    }
    if (label === '去打卡') {
      SaituDetailNav.openCheckInEditor('')
      return
    }
    AppStorage.setOrCreate('saituMainTab', 4)
  }

  build() {
    Column() {
      AppNavBar({
        title: '适用场景',
        onBack: (): void => SaituDetailNav.closeScenarioGuide()
      })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text('赛途札记覆盖观赛、训练、旅途与习惯四大类个人场景，全部本机存储。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          ForEach(this.items, (s: ScenarioItem) => {
            Column({ space: Theme.space.s2 }) {
              Text(s.title)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(s.desc)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              AppButton({
                label: s.actionLabel,
                variant: 'secondary',
                onTap: (): void => this.runAction(s.actionLabel)
              })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
          }, (s: ScenarioItem) => s.title)
          Blank().height(Theme.space.s10)
        }
        .padding(Theme.space.pageX)
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
