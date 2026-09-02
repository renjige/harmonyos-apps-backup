import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CaptureListCard } from '../components/capture/CaptureListCard'
import { CaptureItem } from '../models/ZhiweiModels'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct AllCapturesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('zwRev') @Watch('onRev') storeRev: number = 0
  @State items: CaptureItem[] = []
  @State filterId: string = ''
  @State statusId: string = ''
  @State tagId: string = ''
  @State timeDays: number = 0
  @State keyword: string = ''
  private catIds: string[] = CategoryEmojiUtil.allIds()
  private tagIds: string[] = CategoryEmojiUtil.learnTagIds()

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.items = ZhiweiStore.searchCapturesWithTime(this.keyword, this.filterId, this.statusId, this.tagId, this.timeDays)
  }

  private summaryOf(item: CaptureItem): string {
    if (item.body.length <= 48) {
      return item.body
    }
    return `${item.body.substring(0, 48)}…`
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colorOf(this.themeEpoch).textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => ZhiweiNav.closeAllCaptures())
        Text('全部微知识')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          TextInput({ text: this.keyword, placeholder: '搜索标题、正文或标签' })
            .width('100%')
            .height(44)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .placeholderColor(Theme.colors().textTertiary)
            .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => {
              this.keyword = v
              this.reload()
            })
          Flex({ wrap: FlexWrap.Wrap }) {
            this.StatusChip('', '全部进度')
            this.StatusChip('inbox', '待消化')
            this.StatusChip('follow', '跟进中')
            this.StatusChip('done', '已消化')
          }
          .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            this.TimeChip(0, '全部时间')
            this.TimeChip(1, '今天')
            this.TimeChip(7, '近7日')
            this.TimeChip(30, '近30日')
          }
          .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            this.FilterChip('', '全部分类')
            ForEach(this.catIds, (id: string) => {
              this.FilterChip(id, CategoryEmojiUtil.chipLabel(id))
            }, (id: string) => `c_${id}`)
          }
          .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            this.TagChip('', '全部标签')
            ForEach(this.tagIds, (id: string) => {
              this.TagChip(id, CategoryEmojiUtil.learnLabel(id))
            }, (id: string) => `t_${id}`)
          }
          .width('100%')
          if (this.items.length === 0) {
            AppEmpty({
              title: '没有匹配的微知识',
              description: '调整筛选条件，或新建一条记录。',
              actionLabel: '记微知识',
              onAction: (): void => {
                ZhiweiNav.closeAllCaptures()
                ZhiweiNav.openCompose('', false)
              }
            })
          } else {
            Text(`共 ${this.items.length} 条`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            ForEach(this.items, (item: CaptureItem) => {
              CaptureListCard({
                itemId: item.id,
                title: item.title,
                summary: this.summaryOf(item),
                category: item.category,
                priority: item.priority,
                status: item.status,
                timeLabel: ZhiweiStore.displayTime(item.updatedAt),
                onTap: (): void => ZhiweiNav.openCapture(item.id)
              })
            }, (item: CaptureItem) => item.id)
          }
          Blank().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
  }

  @Builder
  StatusChip(id: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.statusId === id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.statusId === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.statusId = id
        this.reload()
      })
  }

  @Builder
  FilterChip(id: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.filterId === id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.filterId === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.filterId = this.filterId === id ? '' : id
        this.reload()
      })
  }

  @Builder
  TagChip(id: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.tagId === id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.tagId === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.tagId = this.tagId === id ? '' : id
        this.reload()
      })
  }

  @Builder
  TimeChip(days: number, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.timeDays === days ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.timeDays === days ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.timeDays = days
        this.reload()
      })
  }
}
