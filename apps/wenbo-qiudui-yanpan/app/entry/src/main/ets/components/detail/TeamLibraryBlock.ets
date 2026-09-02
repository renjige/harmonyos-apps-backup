import { Theme } from '../design-system/Theme'
import { PlayerLine, TeamItem } from '../../models/MatchModels'

@Component
export struct TeamLibraryBlock {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop team: TeamItem = new TeamItem()
  @Prop roster: PlayerLine[] = []
  @Prop rankNote: string = ''

  build() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        if (this.team.regionLabel().length > 0) {
          Text(this.team.regionLabel())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
        }
        if (this.team.styleTagLabel().length > 0) {
          Text(this.team.styleTagLabel())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textPrimary)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
        }
      }
      .width('100%')

      if (this.team.stadium.length > 0 || this.team.honors.length > 0) {
        Column({ space: 8 }) {
          Text('资料库')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.team.stadium.length > 0) {
            Text(`主场：${this.team.stadium}`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          if (this.team.honors.length > 0) {
            Text(`荣誉：${this.team.honors}`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          if (this.team.historyNote.length > 0) {
            Text(this.team.historyNote)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .border({ width: 1, color: Theme.colors().strokeHairline })
      }

      Column({ space: 8 }) {
        Text('状态分析')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(`近期战绩：${this.team.formStatus()}`)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        if (this.rankNote.length > 0) {
          Text(`积分榜：${this.rankNote}`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        if (this.team.gfgaText().length > 0) {
          Text(`得失球：${this.team.gfgaText()}`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        if (this.team.homeRecord.length > 0) {
          Text(`主场：${this.team.homeRecord}`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        if (this.team.awayRecord.length > 0) {
          Text(`客场：${this.team.awayRecord}`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        if (this.team.attackNote.length > 0) {
          Text(`进攻：${this.team.attackNote}`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        if (this.team.defenseNote.length > 0) {
          Text(`防守：${this.team.defenseNote}`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      if (this.roster.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('核心球员档案')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.roster, (row: PlayerLine) => {
            Row() {
              Text(row.name)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
              Text(row.position)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .width('100%')
            .padding({ top: 6, bottom: 6 })
          }, (row: PlayerLine) => `p-${row.name}-${row.position}`)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .border({ width: 1, color: Theme.colors().strokeHairline })
      }

      if (this.team.newsTitle.length > 0) {
        Column({ space: 8 }) {
          Text('球队资讯')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.team.newsTitle)
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.team.newsBody)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .border({ width: 1, color: Theme.colors().strokeHairline })
      }
    }
    .width('100%')
  }
}
