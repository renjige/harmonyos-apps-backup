import { Theme } from '../design-system/Theme'
import { CourtMedia } from '../../config/CourtMedia'
import { FanKind, FanScenario } from '../../models/FanModels'
import { FanMemoryStore } from '../../services/FanMemoryStore'
import { CourtDetailNav } from '../../services/CourtDetailNav'

/** 场景化创作入口：覆盖赛后复盘 / 成长报告 / 赛季合集 / 下一场观赛 */
@Component
export struct FanScenarioStrip {
  @StorageLink('fanEpoch') fanEpoch: number = 0
  @State scenarios: FanScenario[] = []

  aboutToAppear(): void {
    this.scenarios = FanMemoryStore.scenarios()
  }

  private openScenario(s: FanScenario): void {
    if (s.id === 'post_match') {
      CourtDetailNav.openFanWizard()
      return
    }
    if (s.id === 'growth_report') {
      CourtDetailNav.openFanDashboard()
      return
    }
    if (s.id === 'season_album') {
      AppStorage.setOrCreate('courtFanPrefillTitle', '我的赛季记忆')
      AppStorage.setOrCreate('courtFanPrefillBody',
        '收录本季经典比赛、关键瞬间与个人感受，可按决赛/德比/主队等主题整理。')
      CourtDetailNav.openFanEditor(FanKind.ALBUM, '')
      return
    }
    AppStorage.setOrCreate('courtFanPrefillTitle', '下一场想看的比赛')
    AppStorage.setOrCreate('courtFanPrefillBody', '看点备忘、和谁一起看、是否需要订场')
    CourtDetailNav.openFanEditor(FanKind.EVENT, '')
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('场景创作')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('围绕真实观赛场景，一次完成多条关联记忆')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')

      Scroll() {
        Row({ space: Theme.space.s3 }) {
          ForEach(this.scenarios, (s: FanScenario) => {
            Column({ space: Theme.space.s2 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(CourtMedia.byKey(s.coverKey))
                  .width(148)
                  .height(88)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.lg)
                Column()
                  .width(148)
                  .height(88)
                  .borderRadius(Theme.radius.lg)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(26,42,58,0.05)', 0.0], ['rgba(26,42,58,0.82)', 1.0]]
                  })
                Text(s.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .maxLines(1)
                  .padding(Theme.space.s3)
              }
              Text(s.subtitle)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width(148)
                .maxLines(2)
            }
            .onClick((): void => {
              this.openScenario(s)
            })
          }, (s: FanScenario) => s.id)
        }
        .padding({ right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
  }
}
