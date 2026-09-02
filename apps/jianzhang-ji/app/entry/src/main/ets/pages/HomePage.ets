import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { BrochureListCard } from '../components/brochure/BrochureListCard'
import { EnrollmentHero } from '../components/brochure/EnrollmentHero'
import { SectionHeading } from '../components/brochure/SectionHeading'
import { ArticleListCard } from '../components/brochure/ArticleListCard'
import { ArticleItem, BrochureItem } from '../models/BrochureModels'
import { BrochureBizService } from '../services/BrochureBizService'
import { BrochureDetailNav } from '../services/BrochureDetailNav'
import { FavoriteService } from '../services/FavoriteService'
import { CompareStore } from '../services/CompareStore'

class FilterChip {
  key: string = 'all'
  label: string = '全部'

  static all(): FilterChip[] {
    const chips: FilterChip[] = []
    const keys = ['all', '本科', '硕士', '博士', '985', '211']
    const labels = ['全部', '本科', '硕士', '博士', '985', '211']
    let i = 0
    while (i < keys.length) {
      const c = new FilterChip()
      c.key = keys[i]
      c.label = labels[i]
      chips.push(c)
      i = i + 1
    }
    return chips
  }
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '简章集'
  @Prop tagline: string = ''
  @State searchText: string = ''
  @State activeChip: string = 'all'
  @State brochures: BrochureItem[] = []
  @State filtered: BrochureItem[] = []
  @State articles: ArticleItem[] = []
  @State loading: boolean = true
  @State errorText: string = ''
  @StorageLink('favoriteTick') favoriteTick: number = 0
  @StorageLink('compareTick') compareTick: number = 0
  private chips: FilterChip[] = FilterChip.all()

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.errorText = ''
    const q = this.searchText.trim()
    this.brochures = await BrochureBizService.loadBrochures('', '', '', q)
    if (this.brochures.length === 0 && q.length === 0) {
      this.errorText = '暂未加载到简章，请检查网络后重试'
    }
    this.articles = await BrochureBizService.loadArticles()
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    this.filtered = BrochureBizService.filterClient(this.brochures, this.activeChip)
  }

  private onChipTap(key: string): void {
    this.activeChip = key
    this.applyFilter()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        EnrollmentHero({
          appName: this.appName,
          tagline: this.tagline.length > 0 ? this.tagline : '高校招生简章智慧检索与对比',
          brochureCount: this.brochures.length,
          articleCount: this.articles.length
        })

        Row({ space: Theme.space.s3 }) {
          Column() {
            AppIcon({ name: 'alert', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          Column({ space: 4 }) {
            Text('填报提示')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text('建议按「冲稳保」梯度选校，关注选科要求与体检受限专业；分数线仅供参考，请以省级考试院及院校官网最新公布为准。')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(20)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .shadow({
          radius: 10,
          color: Theme.isDark() ? 'rgba(0,0,0,0.25)' : 'rgba(10,37,64,0.04)',
          offsetX: 0,
          offsetY: 2
        })

        Row({ space: Theme.space.s2 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          TextInput({ text: this.searchText, placeholder: '搜索院校、专业或省份' })
            .layoutWeight(1)
            .height(40)
            .fontSize(Theme.type.body)
            .onChange((v: string): void => {
              this.searchText = v
            })
            .onSubmit((): void => { void this.reload() })
        }
        .width('100%')
        .padding({ left: Theme.space.s3, right: Theme.space.s3, top: 10, bottom: 10 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .border({ width: 1, color: Theme.colors().strokeHairline })

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            ForEach(this.chips, (chip: FilterChip) => {
              Row({ space: 6 }) {
                if (this.activeChip === chip.key && chip.key === 'all') {
                  AppIcon({
                    name: 'biz',
                    iconSize: Theme.icon.sm,
                    color: Theme.colors().brandOnPrimary
                  })
                }
                Text(chip.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.activeChip === chip.key ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              }
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.activeChip === chip.key ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .border({
                width: 1,
                color: this.activeChip === chip.key ?
                  Theme.colors().brandPrimary : Theme.colors().strokeHairline
              })
              .onClick((): void => { this.onChipTap(chip.key) })
            }, (chip: FilterChip) => chip.key)
          }
          .padding({ right: Theme.space.pageX })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        SectionHeading({
          title: '招生简章',
          iconName: 'biz',
          trailing: `${this.filtered.length} 所`
        })

        if (this.loading) {
          AppLoading({ label: '加载简章…' })
        } else if (this.filtered.length === 0) {
          AppEmpty({
            title: '暂无匹配简章',
            description: this.errorText.length > 0 ? this.errorText : '试试调整筛选或搜索关键词',
            actionLabel: '重新加载',
            onAction: (): void => { void this.reload() }
          })
        } else {
          ForEach(this.filtered, (row: BrochureItem) => {
            BrochureListCard({
              item: row,
              favorited: FavoriteService.isFavorite(row.id),
              inCompare: CompareStore.contains(row.id),
              onTap: (): void => { BrochureDetailNav.openBrochure(row.id) }
            })
          }, (row: BrochureItem) => row.id)
        }

        SectionHeading({
          title: '招生资讯',
          iconName: 'book',
          trailing: `${this.articles.length} 篇`
        })

        if (this.articles.length === 0) {
          AppEmpty({ title: '暂无资讯', description: '政策解读将在此展示' })
        } else {
          ForEach(this.articles, (art: ArticleItem) => {
            ArticleListCard({
              item: art,
              onTap: (): void => { BrochureDetailNav.openArticle(art.id) }
            })
          }, (art: ArticleItem) => art.id)
        }

        Blank().height(Theme.space.s10)
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3,
        bottom: Theme.space.s4
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
