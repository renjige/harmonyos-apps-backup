import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { TeaItem, TeaTypeDef, TastingRecord } from '../../models/TeaModels'
import { TeaMedia } from '../../services/TeaMedia'
import { TeaNav } from '../../services/TeaNav'
import { TeaStore } from '../../services/TeaStore'
import { TastingCard } from '../tea/TastingCard'

@Component
export struct TeaDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  /** 直接读路由，避免 BuilderParam 传入空 id */
  @StorageLink('teaDetailId') @Watch('onTeaIdChange') teaDetailId: string = ''
  @State tea: TeaItem = new TeaItem()
  @State sips: TastingRecord[] = []
  @State confirmDelete: boolean = false
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onTeaIdChange(): void {
    this.reload()
  }

  private reload(): void {
    if (this.teaDetailId.length === 0) {
      return
    }
    const found = TeaStore.findTea(this.teaDetailId)
    if (found !== null) {
      this.tea = found
    }
    this.sips = TeaStore.tastingsOfTea(this.teaDetailId)
  }

  private tagsText(): string {
    const names: string[] = []
    for (const id of this.tea.tagIds) {
      for (const tag of TeaStore.tags()) {
        if (tag.id === id) {
          names.push(tag.name)
        }
      }
    }
    return names.length > 0 ? names.join(' · ') : '暂无标签'
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(TeaMedia.hero())
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(88)
              .linearGradient({
                angle: 180,
                colors: [['rgba(28,46,38,0)', 0], ['rgba(28,46,38,0.82)', 1]]
              })
            Column({ space: 4 }) {
              Text(this.tea.name)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textOnInverse)
              Text(`${TeaTypeDef.nameOf(this.tea.typeKey)} · ${TeaItem.statusLabel(this.tea.stockStatus)}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
            }
            .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s3 })
          }
          .width('100%')
          .borderRadius(Theme.radius.lg)
          .clip(true)

          AppCard({ title: '档案摘要' }) {
            Column({ space: Theme.space.s2 }) {
              Text(`品牌 ${this.tea.brand.length > 0 ? this.tea.brand : '未填'} · 产地 ${this.tea.origin.length > 0 ? this.tea.origin : '未填'}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
              Text(`年份 ${this.tea.yearText.length > 0 ? this.tea.yearText : '未填'} · 收藏 ${this.tea.collectedAt.length > 0 ? this.tea.collectedAt : '未填'}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
              Text(this.tagsText())
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().brandPrimary)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }

          if (this.tea.story.length > 0 || this.tea.review.length > 0) {
            AppCard({ title: '故事与评价' }) {
              Column({ space: Theme.space.s2 }) {
                if (this.tea.story.length > 0) {
                  Text(this.tea.story)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .lineHeight(22)
                }
                if (this.tea.review.length > 0) {
                  Text(this.tea.review)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textSecondary)
                    .lineHeight(20)
                }
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
          }

          if (this.tea.aromaNote.length + this.tea.tasteNote.length + this.tea.liquorNote.length + this.tea.aftertasteNote.length > 0) {
            AppCard({ title: '品饮印象' }) {
              Column({ space: 6 }) {
                if (this.tea.aromaNote.length > 0) {
                  Text(`香气 ${this.tea.aromaNote}`).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textPrimary)
                }
                if (this.tea.tasteNote.length > 0) {
                  Text(`口感 ${this.tea.tasteNote}`).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textPrimary)
                }
                if (this.tea.liquorNote.length > 0) {
                  Text(`茶汤 ${this.tea.liquorNote}`).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textPrimary)
                }
                if (this.tea.aftertasteNote.length > 0) {
                  Text(`回甘 ${this.tea.aftertasteNote}`).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textPrimary)
                }
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
          }

          Text('关联品饮')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          if (this.sips.length === 0) {
            Text('还没有品饮记录，记一笔当下的感受。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.sips, (r: TastingRecord) => {
              TastingCard({ rec: r, onOpen: (): void => { TeaNav.openTasting(r.id) } })
            }, (r: TastingRecord) => r.id)
          }

          AppButton({
            label: '记一笔品饮',
            variant: 'primary',
            onTap: (): void => { TeaNav.openTastingEditor(this.tea.id, '') }
          })
          AppButton({
            label: '加入茶单',
            variant: 'secondary',
            onTap: (): void => { TeaNav.openSheet('listSheetOpen') }
          })
          AppButton({
            label: '加入主题册',
            variant: 'secondary',
            onTap: (): void => { TeaNav.openSheet('albumSheetOpen') }
          })
          AppButton({
            label: '编辑档案',
            variant: 'secondary',
            onTap: (): void => { TeaNav.openTeaEditor(this.tea.id) }
          })
          if (!this.confirmDelete) {
            AppButton({
              label: '删除这款茶',
              variant: 'ghost',
              onTap: (): void => { this.confirmDelete = true }
            })
          } else {
            AppButton({
              label: '确认删除档案与相关品饮',
              variant: 'danger',
              onTap: (): void => {
                void TeaStore.deleteTea(this.tea.id, true).then((): void => {
                  this.onChanged()
                  TeaNav.closeTea()
                })
              }
            })
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
  }
}
