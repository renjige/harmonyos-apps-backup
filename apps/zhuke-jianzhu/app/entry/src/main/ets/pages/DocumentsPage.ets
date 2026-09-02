/** 资料 — 工程资料分类 · 文件管理 */
import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { ZhukeDocCategory } from '../components/zhuke/ZhukeDocCategory'
import { DocumentService, DocItem } from '../services/DocumentService'

class DocTypeRow {
  type: string = ''
  count: number = 0

  static make(type: string, count: number): DocTypeRow {
    const r = new DocTypeRow()
    r.type = type
    r.count = count
    return r
  }
}

@Component
export struct DocumentsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: DocItem[] = []
  @State categories: DocTypeRow[] = []
  @State filterType: string = 'all'
  @State loading: boolean = true

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await DocumentService.list()
    this.loading = false
    this.buildCategories()
  }

  private buildCategories(): void {
    const types: string[] = ['drawing', 'contract', 'report', 'approval', 'log']
    const cats: DocTypeRow[] = []
    for (const t of types) {
      let count = 0
      for (const d of this.items) {
        if (d.type === t) {
          count++
        }
      }
      cats.push(DocTypeRow.make(t, count))
    }
    this.categories = cats
  }

  private filteredItems(): DocItem[] {
    if (this.filterType === 'all') {
      return this.items
    }
    const out: DocItem[] = []
    for (const d of this.items) {
      if (d.type === this.filterType) {
        out.push(d)
      }
    }
    return out
  }

  private iconForType(type: string): 'biz' | 'chart' | 'check' | 'alert' {
    if (type === 'contract') {
      return 'biz'
    }
    if (type === 'report') {
      return 'check'
    }
    if (type === 'approval') {
      return 'alert'
    }
    return 'chart'
  }

  build() {
    Column() {
      Column({ space: Theme.space.s2 }) {
        Text('资料')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('工程文档 · 分类管理')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s4
      })

      if (this.loading) {
        AppLoading({ label: '加载资料目录' })
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Column({ space: Theme.space.s3 }) {
              Text('资料分类')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              Column({ space: Theme.space.s3 }) {
                ForEach(this.categories, (c: DocTypeRow) => {
                  ZhukeDocCategory({
                    type: c.type,
                    count: c.count,
                    icon: this.iconForType(c.type),
                    onTap: () => { this.filterType = c.type }
                  })
                }, (c: DocTypeRow) => c.type)
              }
            }

            Column({ space: Theme.space.s3 }) {
              Row() {
                Text(this.filterType === 'all' ? '全部文件' : DocumentService.typeLabel(this.filterType))
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Blank()
                if (this.filterType !== 'all') {
                  Text('查看全部')
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .onClick(() => { this.filterType = 'all' })
                }
              }
              .width('100%')

              if (this.filteredItems().length === 0) {
                AppEmpty({
                  title: '暂无文件',
                  description: '工程资料上传后将在此分类展示'
                })
              } else {
                Column({ space: Theme.space.s3 }) {
                  ForEach(this.filteredItems(), (d: DocItem) => {
                    Row({ space: Theme.space.s3 }) {
                      Column() {
                        AppIcon({ name: 'biz', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                      }
                      .width(44)
                      .height(44)
                      .justifyContent(FlexAlign.Center)
                      .backgroundColor(Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.md)

                      Column({ space: Theme.space.s1 }) {
                        Text(d.title)
                          .fontSize(Theme.type.subhead)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                        Text(`${d.projectName} · ${d.version}`)
                          .fontSize(Theme.type.footnote)
                          .fontColor(Theme.colors().textTertiary)
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      Text(DocumentService.statusLabel(d.status))
                        .fontSize(Theme.type.caption)
                        .fontColor(DocumentService.statusColor(d.status))
                    }
                    .width('100%')
                    .padding(Theme.space.cardPadding)
                    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.card)
                    .border({ width: 1, color: Theme.colors().strokeHairline })
                    .shadow(Theme.cardShadow())
                  }, (d: DocItem) => d.id)
                }
              }
            }
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
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
