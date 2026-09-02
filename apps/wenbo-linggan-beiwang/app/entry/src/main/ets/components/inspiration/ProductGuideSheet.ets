import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'

class GuideStep {
  title: string = ''
  detail: string = ''
  icon: string = 'book'
}

/** 首启产品特色说明：强调「捕捉→对照→转化」，区别于简易备忘录 */
@Component
export struct ProductGuideSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}

  private steps(): GuideStep[] {
    const list: GuideStep[] = []
    const s0 = new GuideStep()
    s0.title = '灵感转化台'
    s0.detail = '转化台首屏「转化流水线」四列看板：待钉板 → 待拆计划 → 推进中 → 已完成，可视化推进而非记完即走。'
    s0.icon = 'chart'
    list.push(s0)
    const s1 = new GuideStep()
    s1.title = '钉板对照 + 对照三问'
    s1.detail = '灵感钉入画板文字卡片对照构图；精选内容用三问写备忘，不是抄原文。'
    s1.icon = 'photo'
    list.push(s1)
    const s2 = new GuideStep()
    s2.title = '创意计划 · 转化步骤'
    s2.detail = '从灵感生成带三条步骤的计划，勾选推进进度，不是简单待办列表。'
    s2.icon = 'calendar'
    list.push(s2)
    const s3 = new GuideStep()
    s3.title = '专题 · 成就 · 日周月回顾'
    s3.detail = '灵感专题收纳、打卡与成就墙、成长统计与模板回顾，形成完整创意闭环。'
    s3.icon = 'heart'
    list.push(s3)
    return list
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text('产品特色')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('创意转化工作台')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('转化工作台不是空白备忘录。核心是把灵感捕捉后，对照、拆解并推进成可执行计划。')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .lineHeight(24)

          ForEach(this.steps(), (step: GuideStep) => {
            Row({ space: Theme.space.s3 }) {
              Column() {
                AppIcon({
                  name: step.icon === 'photo' ? 'photo' :
                    step.icon === 'calendar' ? 'calendar' :
                      step.icon === 'heart' ? 'heart' : 'chart',
                  iconSize: Theme.icon.md,
                  color: Theme.colors().brandPrimary
                })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.lg)
              Column({ space: 4 }) {
                Text(step.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(step.detail)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                  .lineHeight(20)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
            .border({ width: 1, color: Theme.colors().strokeHairline })
          }, (step: GuideStep) => step.title)

          AppButton({
            label: '开始体验',
            onTap: (): void => { this.onClose() }
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
    .zIndex(30)
  }
}
