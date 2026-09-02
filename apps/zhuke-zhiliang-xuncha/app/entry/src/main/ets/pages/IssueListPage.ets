import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { IssueCard } from '../components/quality/IssueCard'
import { ChoiceChip } from '../components/quality/ChoiceChip'
import { IssueRecord, QualityCatalog } from '../models/QualityModels'
import { QualityService } from '../services/QualityService'
import { QualityNav } from '../services/QualityNav'

@Component
export struct IssueListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop refreshToken: number = 0
  @Prop dataVersion: string = '0'
  @StorageLink('issueFilter') filter: string = '全部'
  @State keyword: string = ''
  @State filterOptions: string[] = []

  aboutToAppear(): void {
    this.filterOptions = QualityCatalog.issueFilters()
  }

  private rows(token: number, version: string): IssueRecord[] {
    const _keep = token
    const _version = version
    return QualityService.filterIssues(this.filter, this.keyword)
  }

  private pickFilter(value: string): void {
    this.filter = value
    QualityNav.setIssueFilter(value)
  }

  build() {
    Column() {
      Text('质量问题')
        .fontSize(Theme.type.title1)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      Row({ space: 8 }) {
        AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
        TextInput({ text: this.keyword, placeholder: '搜索问题' })
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .onChange((v: string) => { this.keyword = v })
      }
      .width('100%')
      .height(44)
      .padding({ left: 12, right: 12 })
      .margin({ left: 16, right: 16, bottom: 10 })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(14)

      Scroll() {
        Row() {
          ForEach(this.filterOptions, (f: string) => {
            ChoiceChip({
              label: f,
              active: this.filter === f,
              onPick: () => this.pickFilter(f)
            })
          }, (f: string) => `${f}-${this.filter}`)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: 16, right: 16, bottom: 10 })

      if (this.rows(this.refreshToken, this.dataVersion).length === 0) {
        AppEmpty({
          title: this.keyword.length > 0 ? '无搜索结果' : '暂无质量问题',
          description: this.keyword.length > 0 ? '试试其他关键词，或切换筛选状态。' : '巡查中标记异常后，可在此跟进整改。',
          actionLabel: '新增问题',
          onAction: () => QualityNav.open('newIssue')
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.rows(this.refreshToken, this.dataVersion), (row: IssueRecord) => {
              IssueCard({ item: row, onOpen: (id: string) => QualityNav.open('issue', id) })
            }, (row: IssueRecord) => `${row.id}_${this.refreshToken}`)
          }
          .padding({ left: 16, right: 16, bottom: 32 })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
