import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { BadgeGridItem, SkillRadarChart } from '../components/skill/SkillCards'
import { SkillBadge, BadgeRule, RadarDimension } from '../models/SkillModels'
import { SkillBizService } from '../services/SkillBizService'
import { SkillNav } from '../services/SkillNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State badges: SkillBadge[] = []
  @State allLevelIds: string[] = []
  @State radarDims: RadarDimension[] = []
  @StorageLink('skillTick') tick: number = 0
  @StorageLink('growthValue') growthValue: number = 0
  @StorageLink('growthRank') growthRank: string = ''
  @StorageLink('growthLevel') growthLevel: number = 1

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.badges = await SkillBizService.loadBadges()
    const levels = await SkillBizService.loadAllLevels()
    this.allLevelIds = []
    for (const lv of levels) {
      this.allLevelIds.push(lv.id)
    }
    const badgeRules: BadgeRule[] = []
    for (const b of this.badges) {
      const row = new BadgeRule()
      row.id = b.id
      row.rule = b.rule
      badgeRules.push(row)
    }
    await ProgressStore.syncBadges(this.allLevelIds, badgeRules)
    this.radarDims = ProgressStore.radarDimensions()
  }

  private tierFilter(tier: string): SkillBadge[] {
    const out: SkillBadge[] = []
    for (const b of this.badges) {
      if (b.tier === tier) {
        out.push(b)
      }
    }
    return out
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('成长')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Column({ space: 10 }) {
          Text(this.growthRank)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          Text(`Lv.${this.growthLevel} · 累计成长值 ${this.growthValue}`)
            .fontSize(14)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Stack({ alignContent: Alignment.Start }) {
            Column()
              .width('100%')
              .height(10)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
            Column()
              .width(`${Math.round(ProgressStore.growthProgress() * 100)}%`)
              .height(10)
              .backgroundColor(Theme.colors().brandAccent)
              .borderRadius(Theme.radius.pill)
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)

        SkillRadarChart({ dimensions: this.radarDims })

        this.BadgeSection('金章', 'gold')
        this.BadgeSection('银章', 'silver')
        this.BadgeSection('铜章', 'bronze')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s5,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  BadgeSection(title: string, tier: string) {
    Column({ space: 10 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.tierFilter(tier).length === 0) {
        AppEmpty({ title: '暂无勋章', description: '完成关卡后可解锁' })
      } else {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          ForEach(this.tierFilter(tier), (b: SkillBadge) => {
            BadgeGridItem({
              title: b.title,
              tier: b.tier,
              coverKey: b.coverKey.length > 0 ? b.coverKey : 'badge_bronze',
              lit: ProgressStore.badgeLit(b.rule, this.allLevelIds) ||
                ProgressStore.isBadgeUnlocked(b.id),
              onTap: () => SkillNav.openBadge(b.id)
            })
          }, (b: SkillBadge) => b.id)
        }
        .width('100%')
      }
    }
    .width('100%')
  }
}
