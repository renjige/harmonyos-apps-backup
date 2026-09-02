import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { DetailShell } from './DetailShell'
import { ContentCard } from '../ContentCard'
import { ArticleItem } from '../../models/PavilionModels'
import { PavilionBizService } from '../../services/PavilionBizService'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'
import { ExploreStore } from '../../services/ExploreStore'

class TagChip {
  id: string = 'all'
  label: string = '全部'
}

@Component
export struct SearchPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State keyword: string = ''
  @State shown: ArticleItem[] = []
  @State all: ArticleItem[] = []
  @State tag: string = 'all'
  @State cat: string = 'all'
  private tags: TagChip[] = []
  private cats: TagChip[] = SearchPane.buildCats()

  aboutToAppear(): void {
    this.tags = SearchPane.buildTags()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private static buildCats(): TagChip[] {
    const ids: string[] = ['all', 'fun', 'life', 'history', 'nature', 'art', 'science']
    const labels: string[] = ['全部', '趣味知识', '生活技巧', '历史文化', '自然探索', '艺术欣赏', '科普百科']
    const list: TagChip[] = []
    for (let i = 0; i < ids.length; i++) {
      const c = new TagChip()
      c.id = ids[i]
      c.label = labels[i]
      list.push(c)
    }
    return list
  }

  private static buildTags(): TagChip[] {
    const list: TagChip[] = []
    const all = new TagChip()
    all.id = 'all'
    all.label = '全部标签'
    list.push(all)
    const custom = ExploreStore.customTags()
    for (const t of custom) {
      const c = new TagChip()
      c.id = t
      c.label = t
      list.push(c)
    }
    return list
  }

  private async reload(): Promise<void> {
    this.all = await PavilionBizService.loadArticles()
    this.apply()
  }

  private apply(): void {
    let list = PavilionBizService.filterByCategory(this.all, this.cat)
    list = PavilionBizService.filterByTag(list, this.tag)
    this.shown = PavilionBizService.search(list, this.keyword)
  }

  build() {
    DetailShell({
      title: '搜索趣知',
      onClose: (): void => { PavilionDetailNav.close() }
    }) {
      Column({ space: Theme.space.s3 }) {
        Row({ space: 8 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.sm, color: Theme.textSub(this.themeEpoch, this.darkModeOn) })
          TextInput({ text: this.keyword, placeholder: '标题、正文或标签关键词' })
            .layoutWeight(1)
            .height(40)
            .fontSize(16)
            .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
            .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
            .backgroundColor(Color.Transparent)
            .onChange((v: string): void => {
              this.keyword = v
              this.apply()
            })
        }
        .width('100%')
        .padding(12)
        .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
        .borderRadius(Theme.radius.pill)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.cats, (c: TagChip) => {
              Text(c.label)
                .fontSize(12)
                .fontColor(this.cat === c.id ? Theme.colors().brandOnPrimary : Theme.brandInk(this.themeEpoch, this.darkModeOn))
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(this.cat === c.id ? Theme.brandInk(this.themeEpoch, this.darkModeOn) : Theme.brandBox(this.themeEpoch, this.darkModeOn))
                .borderRadius(8)
                .onClick((): void => {
                  this.cat = c.id
                  this.apply()
                })
            }, (c: TagChip) => `c_${c.id}`)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .margin({ left: Theme.space.pageX })

        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.tags, (c: TagChip) => {
              Text(c.label)
                .fontSize(12)
                .fontColor(this.tag === c.id ? Theme.colors().brandOnPrimary : Theme.brandInk(this.themeEpoch, this.darkModeOn))
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(this.tag === c.id ? Theme.brandInk(this.themeEpoch, this.darkModeOn) : Theme.brandBox(this.themeEpoch, this.darkModeOn))
                .borderRadius(8)
                .onClick((): void => {
                  this.tag = c.id
                  this.apply()
                })
            }, (c: TagChip) => `t_${c.id}`)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .margin({ left: Theme.space.pageX })

        if (this.shown.length === 0) {
          AppEmpty({ title: '没有匹配的趣知', description: '换个词、分类或标签再试试。' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.shown, (row: ArticleItem) => {
                ContentCard({
                  articleId: row.id,
                  title: row.title,
                  summary: row.summary,
                  coverKey: row.coverKey,
                  category: row.category,
                  kind: row.kind,
                  onOpen: (): void => { PavilionDetailNav.openArticle(row.id) }
                })
              }, (row: ArticleItem) => row.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
  }
}
