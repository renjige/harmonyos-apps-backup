import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { ContentCard } from '../ContentCard'
import { ArticleItem } from '../../models/PavilionModels'
import { PavilionBizService } from '../../services/PavilionBizService'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'
import { PavilionStore } from '../../services/PavilionStore'

@Component
export struct HistoryPane {
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State shown: ArticleItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = await PavilionBizService.loadArticles()
    const ids = PavilionStore.historyIds()
    const out: ArticleItem[] = []
    for (const id of ids) {
      if (id.indexOf('daily:') === 0) {
        continue
      }
      for (const a of all) {
        if (a.id === id) {
          out.push(a)
        }
      }
    }
    this.shown = out
  }

  build() {
    DetailShell({
      title: '阅读记录',
      onClose: (): void => { PavilionDetailNav.close() }
    }) {
      if (this.shown.length === 0) {
        AppEmpty({ title: '还没有阅读记录', description: '打开任意一篇趣知后会出现在这里。' })
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
  }
}
