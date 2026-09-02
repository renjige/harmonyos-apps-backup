import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { BrochureItem } from '../models/BrochureModels'
import { BrochureBizService } from '../services/BrochureBizService'
import { BrochureDetailNav } from '../services/BrochureDetailNav'
import { CompareStore } from '../services/CompareStore'

class CompareField {
  label: string = ''
  values: string[] = []

  static make(label: string, values: string[]): CompareField {
    const f = new CompareField()
    f.label = label
    f.values = values
    return f
  }
}

@Component
export struct ComparePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: BrochureItem[] = []
  @State fields: CompareField[] = []
  @State loading: boolean = true
  @StorageLink('compareTick') @Watch('onCompareTick') compareTick: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onCompareTick(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const ids = CompareStore.listIds()
    const all = await BrochureBizService.loadBrochures()
    const out: BrochureItem[] = []
    for (let id of ids) {
      const row = BrochureBizService.findBrochure(all, id)
      if (row !== undefined) {
        out.push(row)
      }
    }
    this.items = out
    this.fields = ComparePage.buildFields(out)
    this.loading = false
  }

  private static buildFields(items: BrochureItem[]): CompareField[] {
    const names: string[] = []
    const levels: string[] = []
    const types: string[] = []
    const provinces: string[] = []
    const totals: string[] = []
    const scores: string[] = []
    const majors: string[] = []
    const tuitions: string[] = []
    for (let row of items) {
      names.push(row.title)
      levels.push(row.level.length > 0 ? row.level : '—')
      types.push(row.type.length > 0 ? row.type : '—')
      provinces.push(row.province.length > 0 ? row.province : '—')
      totals.push(row.enrollmentTotal > 0 ? `${row.enrollmentTotal} 人` : '—')
      scores.push(row.scoreLine.length > 0 ? row.scoreLine : '—')
      majors.push(row.majorsPreview(4).length > 0 ? row.majorsPreview(4) : '—')
      tuitions.push(row.tuition.length > 0 ?
        (row.tuition.length > 36 ? `${row.tuition.substring(0, 36)}…` : row.tuition) : '见简章')
    }
    const out: CompareField[] = []
    out.push(CompareField.make('院校', names))
    out.push(CompareField.make('层次', levels))
    out.push(CompareField.make('类型', types))
    out.push(CompareField.make('省份', provinces))
    out.push(CompareField.make('招生计划', totals))
    out.push(CompareField.make('参考分数线', scores))
    out.push(CompareField.make('代表专业', majors))
    out.push(CompareField.make('学费参考', tuitions))
    return out
  }

  build() {
    Column() {
      AppHeader({
        title: '对比',
        subtitle: `最多 ${CompareStore.maxCount()} 所院校并列查看`
      })
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(36)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.pill)
        Text('横向对比招生计划、分数线与代表专业')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s2
      })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.loading) {
            Text('加载中…')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          } else if (this.items.length === 0) {
            AppEmpty({
              title: '对比清单为空',
              description: '在简章详情页点击「加入对比」，至少添加 2 所院校后可横向比较',
              actionLabel: '去首页选校',
              onAction: (): void => {
                AppStorage.setOrCreate('mainTab', 0)
              }
            })
          } else {
            Text(`当前 ${this.items.length} 所 · 点击院校名查看详情`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            Scroll() {
              Column({ space: Theme.space.s3 }) {
                Row({ space: Theme.space.s2 }) {
                  ForEach(this.items, (row: BrochureItem) => {
                    Column({ space: 6 }) {
                      Row({ space: Theme.space.s1 }) {
                        Column() {
                          AppIcon({ name: 'biz', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
                        }
                        .width(32)
                        .height(32)
                        .justifyContent(FlexAlign.Center)
                        .backgroundColor(Theme.colors().brandPrimaryContainer)
                        .borderRadius(Theme.radius.sm)
                        Text(row.title)
                          .fontSize(Theme.type.subhead)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                          .maxLines(2)
                          .width(100)
                          .onClick((): void => { BrochureDetailNav.openBrochure(row.id) })
                      }
                      .alignItems(VerticalAlign.Top)
                      AppButton({
                        label: '移除',
                        variant: 'secondary',
                        onTap: (): void => {
                          void CompareStore.remove(row.id).then((): void => {
                            void this.reload()
                          })
                        }
                      })
                    }
                    .padding(Theme.space.s3)
                    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.card)
                    .border({ width: 1, color: Theme.colors().strokeHairline })
                  }, (row: BrochureItem) => `h-${row.id}`)
                }

                ForEach(this.fields, (field: CompareField) => {
                  Column({ space: Theme.space.s2 }) {
                    Text(field.label)
                      .fontSize(Theme.type.caption)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                    Row({ space: Theme.space.s2 }) {
                      ForEach(field.values, (val: string, idx: number) => {
                        Text(val)
                          .fontSize(Theme.type.body)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                          .width(120)
                          .maxLines(4)
                      }, (val: string, idx: number) => `${field.label}-${idx}`)
                    }
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.card)
                  .border({ width: 1, color: Theme.colors().strokeHairline })
                }, (field: CompareField) => field.label)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            AppButton({
              label: '清空对比清单',
              variant: 'secondary',
              onTap: (): void => {
                void CompareStore.clear().then((): void => {
                  void this.reload()
                })
              }
            })
          }
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
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
