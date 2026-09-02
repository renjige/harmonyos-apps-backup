import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { TrailListCard } from '../components/mx/TrailListCard'
import { WikiListCard } from '../components/mx/WikiListCard'
import { TrailItem, WikiItem } from '../models/MxModels'
import { MxBizService } from '../services/MxBizService'
import { MxDetailNav } from '../services/MxDetailNav'

@Component
export struct SearchPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State query: string = ''
  @State trails: TrailItem[] = []
  @State wikis: WikiItem[] = []
  @State hitTrails: TrailItem[] = []
  @State hitWikis: WikiItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.trails = await MxBizService.loadTrails('', '')
    this.wikis = await MxBizService.loadArticles('')
    this.applyQuery()
    this.loading = false
  }

  private applyQuery(): void {
    this.hitTrails = MxBizService.search(this.trails, [], this.wikis, this.query)
    this.hitWikis = MxBizService.searchWiki(this.wikis, this.query)
  }

  private onQuery(v: string): void {
    this.query = v
    this.applyQuery()
  }

  build() {
    DetailShell({ title: '搜索', onClose: () => MxDetailNav.close() }) {
      Column({ space: Theme.space.s4 }) {
        TextInput({ text: this.query, placeholder: '路线、地区或百科条目' })
          .width('100%')
          .height(44)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .padding({ left: 12, right: 12 })
          .onChange((v: string) => this.onQuery(v))

        if (this.loading) {
          AppLoading({ label: '准备检索' })
        } else if (this.query.trim().length === 0) {
          AppEmpty({
            title: '输入关键词',
            description: '会同时给出路线与百科。'
          })
        } else if (this.hitTrails.length === 0 && this.hitWikis.length === 0) {
          AppEmpty({
            title: '没有对上的结果',
            description: '换一个山名、植物或岩层试试。'
          })
        } else {
          if (this.hitTrails.length > 0) {
            Text('路线')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.hitTrails, (t: TrailItem) => {
              TrailListCard({
                item: t,
                onTap: (): void => MxDetailNav.openTrail(t.id)
              })
            }, (t: TrailItem) => t.id)
          }
          if (this.hitWikis.length > 0) {
            Text('百科')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.hitWikis, (w: WikiItem) => {
              WikiListCard({
                item: w,
                onTap: (): void => MxDetailNav.openWiki(w.id)
              })
            }, (w: WikiItem) => w.id)
          }
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
