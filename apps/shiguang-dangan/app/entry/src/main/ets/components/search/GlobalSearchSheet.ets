import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ArchiveStore } from '../../services/ArchiveStore'
import { LifeStore } from '../../services/LifeStore'
import { ArchiveDetailNav } from '../../services/ArchiveDetailNav'

class SearchHit {
  kind: string = ''
  title: string = ''
  subtitle: string = ''
  id: string = ''

  static make(kind: string, title: string, subtitle: string, id: string): SearchHit {
    const h = new SearchHit()
    h.kind = kind
    h.title = title
    h.subtitle = subtitle
    h.id = id
    return h
  }
}

@Component
export struct GlobalSearchSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('searchOpen') searchOpen: boolean = false
  onClose: () => void = () => {}
  @State query: string = ''
  @State hits: SearchHit[] = []

  private closeSheet(): void {
    AppStorage.setOrCreate('searchOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
    this.onClose()
  }

  private async runSearch(): Promise<void> {
    const q = this.query.trim().toLowerCase()
    if (q.length === 0) {
      this.hits = []
      return
    }
    const out: SearchHit[] = []
    const archives = await ArchiveStore.loadArchives()
    for (const a of archives) {
      const hay = `${a.title} ${a.summary}`.toLowerCase()
      if (hay.includes(q)) {
        out.push(SearchHit.make('档案', a.title, a.summary, a.id))
      }
    }
    const nodes = await ArchiveStore.loadNodes()
    for (const n of nodes) {
      const hay = `${n.title} ${n.whatHappened}`.toLowerCase()
      if (hay.includes(q)) {
        out.push(SearchHit.make('节点', n.title, n.dateKey, n.id))
      }
    }
    const plans = await LifeStore.loadPlans()
    for (const p of plans) {
      if (p.title.toLowerCase().includes(q)) {
        out.push(SearchHit.make('计划', p.title, p.startDate, p.id))
      }
    }
    const inspirations = await LifeStore.loadInspirations()
    for (const i of inspirations) {
      if (i.text.toLowerCase().includes(q)) {
        out.push(SearchHit.make('灵感', i.text.substring(0, 30), i.status, i.id))
      }
    }
    this.hits = out
  }

  private openHit(hit: SearchHit): void {
    this.closeSheet()
    if (hit.kind === '档案') {
      ArchiveDetailNav.openArchiveDetail(hit.id)
    } else if (hit.kind === '节点') {
      ArchiveDetailNav.openNodeDetail(hit.id)
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: Theme.space.s4 }) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.closeSheet() })
          TextInput({ text: this.query, placeholder: '搜索档案、节点、计划、灵感…' })
            .fontSize(Theme.type.body)
            .layoutWeight(1)
            .onChange((v: string): void => {
              this.query = v
              void this.runSearch()
            })
        }
        .width('100%')
        .padding({ top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s2 }) {
            ForEach(this.hits, (hit: SearchHit) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 2 }) {
                  Text(`[${hit.kind}] ${hit.title}`)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(1)
                  Text(hit.subtitle)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(1)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.openHit(hit) })
            }, (hit: SearchHit) => `${hit.kind}_${hit.id}`)
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      .backgroundColor(Theme.colors().surfacePage)
    }
    .width('100%')
    .height('100%')
    .zIndex(65)
  }
}
