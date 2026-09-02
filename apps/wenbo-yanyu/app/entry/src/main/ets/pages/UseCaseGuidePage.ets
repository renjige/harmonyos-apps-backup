import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { UseCaseGuideItem } from '../models/LanguageCraftModels'
import { LanguageUseCaseService } from '../services/LanguageUseCaseService'
import { LanguageCraftNav } from '../services/LanguageCraftNav'

@Component
export struct UseCaseGuidePage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State categoryLabel: string = '全部'
  @State rows: UseCaseGuideItem[] = LanguageUseCaseService.all()

  private pickCategory(label: string): void {
    this.categoryLabel = label
    this.rows = LanguageUseCaseService.byCategory(label)
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.of(this.darkModeOn).textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { LanguageCraftNav.closeUseCaseGuide() })
        Column({ space: 2 }) {
          Text('使用指南')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).textPrimary)
          Text('15 条真实写作路径 · 点「一键体验」即可走通')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(LanguageUseCaseService.categories(), (label: string) => {
            Text(label)
              .fontSize(Theme.type.caption)
              .fontColor(this.categoryLabel === label ?
                Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.categoryLabel === label ?
                Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.pickCategory(label) })
          }, (label: string) => `uc_cat_${label}`)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Column({ space: Theme.space.s2 }) {
            Text('研语 = 表达润色 + 研究沉淀')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.of(this.darkModeOn).textPrimary)
              .width('100%')
            Text('覆盖职场邮件/纪要/汇报、学术讨论/论文提纲、调研笔记/阅读札记等；润色为本地规则引擎结构性改写，支持四风格对照、24 类成稿、智能摘要与表达诊断。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.of(this.darkModeOn).brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)

          ForEach(this.rows, (item: UseCaseGuideItem) => {
            Column({ space: Theme.space.s2 }) {
              Row() {
                Text(item.category)
                  .fontSize(Theme.type.overline)
                  .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .backgroundColor(Theme.of(this.darkModeOn).surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
              }
              .width('100%')
              Text(item.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.of(this.darkModeOn).textPrimary)
                .width('100%')
              Text(item.summary)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.of(this.darkModeOn).textSecondary)
                .width('100%')
              Text(`1. ${item.stepOne}`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.of(this.darkModeOn).textTertiary)
                .width('100%')
              Text(`2. ${item.stepTwo}`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.of(this.darkModeOn).textTertiary)
                .width('100%')
              Text(`3. ${item.stepThree}`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.of(this.darkModeOn).textTertiary)
                .width('100%')
              AppButton({
                label: '一键体验',
                onTap: (): void => { LanguageUseCaseService.launch(item) }
              })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
          }, (item: UseCaseGuideItem) => item.key)
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
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.of(this.darkModeOn).surfacePage)
  }
}
