import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppIcon } from '../design-system/AppIcon'
import { CatalogItem, KnowledgeCardItem } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'
import { StudyMedia } from '../../services/StudyMedia'

@Component
export struct CategoryDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop categoryTitle: string = ''
  @Prop categoryBody: string = ''
  @Prop categorySummary: string = ''
  @Prop categoryCover: string = 'texture_paper'
  @State cardCount: number = 0
  @State sampleCards: KnowledgeCardItem[] = []
  onClose: () => void = () => {}
  onNewCard: (category: string) => void = (_c: string) => {}
  onOpenCard: (id: string) => void = (_id: string) => {}
  onOpenReview: () => void = () => {}
  onOpenFocus: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const cards = await StudyStore.loadCards()
    const matched: KnowledgeCardItem[] = []
    for (const c of cards) {
      if (c.category === this.categoryTitle) {
        matched.push(c)
      }
    }
    this.cardCount = matched.length
    const sample: KnowledgeCardItem[] = []
    for (let i = 0; i < matched.length && i < 3; i++) {
      sample.push(matched[i])
    }
    this.sampleCards = sample
  }

  build() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
        }
        .width(48).height(48).justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text('学科分类')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(48)
      }
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(StudyMedia.resource(this.categoryCover))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column() {
              Blank()
              Text(this.categoryTitle)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(26,42,74,0.88)', 1]]
                })
            }
            .width('100%')
            .height(180)
          }
          .width('100%')
          .height(180)
          .borderRadius(Theme.radius.md)
          .clip(true)

          AppCard({ title: '分类说明' }) {
            Text(this.categorySummary.length > 0 ? this.categorySummary : this.categoryBody)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }

          Text(`本分类已有 ${this.cardCount} 张知识卡片`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.bodyMuted())
            .width('100%')

          if (this.sampleCards.length > 0) {
            ForEach(this.sampleCards, (c: KnowledgeCardItem) => {
              Row({ space: 10 }) {
                Text(c.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(12)
              .onClick((): void => { this.onOpenCard(c.id) })
            }, (c: KnowledgeCardItem) => c.id)
          }

          AppButton({
            label: `在「${this.categoryTitle}」新建卡片`,
            onTap: (): void => { this.onNewCard(this.categoryTitle) }
          })
          AppButton({
            label: '复习本分类卡片',
            variant: 'secondary',
            onTap: (): void => { this.onOpenReview() }
          })
          AppButton({
            label: '开始专注学习',
            variant: 'ghost',
            onTap: (): void => { this.onOpenFocus() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
