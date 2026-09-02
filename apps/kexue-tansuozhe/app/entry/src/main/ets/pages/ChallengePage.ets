import { Theme } from '../components/design-system/Theme'
import { AppCard } from '../components/design-system/AppCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { ElementService } from '../services/ElementService'
import { ElementNav } from '../services/ElementNav'
import { ChallengeBank } from '../data/ChallengeBank'

class ChallengeSection {
  type: string = ''
  title: string = ''
  summary: string = ''
  count: number = 0

  static all(): ChallengeSection[] {
    const types: string[] = ['identify', 'property', 'family', 'life', 'relation']
    const list: ChallengeSection[] = []
    for (const t of types) {
      const s = new ChallengeSection()
      s.type = t
      s.title = ElementService.challengeTypeLabel(t)
      s.summary = ElementService.challengeTypeSummary(t)
      s.count = ChallengeBank.byType(t).length
      list.push(s)
    }
    return list
  }
}

@Component
export struct ChallengePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('challengeDone') challengeDone: number = 0
  @StorageLink('challengeCorrect') challengeCorrect: number = 0
  private sections: ChallengeSection[] = ChallengeSection.all()

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('探索挑战')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        AppCard({
          title: '挑战统计',
          variant: 'stat',
          pressable: true,
          onTap: (): void => { ElementNav.openQuiz('identify') }
        }) {
          Row({ space: Theme.space.s6 }) {
            Column({ space: 4 }) {
              Text(`${this.challengeDone}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
              Text('已完成题数')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            Column({ space: 4 }) {
              Text(`${this.challengeCorrect}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#E8B96A')
              Text('累计答对')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
          }
          .width('100%')
        }

        Text('选择挑战类型 · 每次 5 题')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')

        ForEach(this.sections, (sec: ChallengeSection) => {
          Row({ space: Theme.space.s3 }) {
            Column({ space: 4 }) {
              Text(sec.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(sec.summary)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Text(`题库 ${sec.count} 题`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandAccent)
                .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .onClick((): void => { ElementNav.openQuiz(sec.type) })
        }, (sec: ChallengeSection) => sec.type)
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s2,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
