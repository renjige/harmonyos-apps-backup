import { Theme } from '../components/design-system/Theme'
import { AppTextInput } from '../components/design-system/AppTextInput'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { TaskListCard } from '../components/task/TaskListCard'
import { TagPresetItem, TaskItem } from '../models/TaskModels'
import { TaskBizService } from '../services/TaskBizService'
import { TaskDetailNav } from '../services/TaskDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct OrganizePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State filterTag: string = ''
  @State searchQuery: string = ''
  @State results: TaskItem[] = []
  @State tagPresets: TagPresetItem[] = []
  @State searched: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.loadTags()
  }

  private async loadTags(): Promise<void> {
    this.tagPresets = await TaskBizService.loadTagPresets()
  }

  private async runSearch(): Promise<void> {
    this.searched = true
    if (!AuthService.isLoggedIn()) {
      this.results = []
      return
    }
    const q = this.searchQuery.trim()
    if (q.length > 0) {
      this.results = await TaskBizService.search(q, this.currentUsername)
      return
    }
    let items = await TaskBizService.loadTasks(this.currentUsername)
    if (this.filterTag.length > 0) {
      const filtered: TaskItem[] = []
      for (const item of items) {
        let matched = false
        for (const t of item.tags) {
          if (t === this.filterTag) {
            matched = true
          }
        }
        if (matched) {
          filtered.push(item)
        }
      }
      items = filtered
    }
    this.results = items
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => this.onClose())
        Text('智慧整理')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 8 }) {
            Text('按标签筛选')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              if (this.tagPresets.length > 0) {
                ForEach(this.tagPresets, (tag: TagPresetItem) => {
                  Text(tag.title)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.filterTag === tag.title ?
                      Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(this.filterTag === tag.title ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                    .onClick((): void => {
                      this.filterTag = this.filterTag === tag.title ? '' : tag.title
                    })
                }, (tag: TagPresetItem) => tag.id)
              } else {
                Text('标签加载中…')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
              }
            }
            .width('100%')
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('关键词搜索')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            AppTextInput({
              text: this.searchQuery,
              placeholder: '标题或说明关键词…',
              onChange: (v: string) => { this.searchQuery = v }
            })
          }
          .width('100%')

          AppButton({
            label: '搜索事项',
            onTap: (): void => {
              if (!AuthService.isLoggedIn()) {
                this.onRequireAuth()
                return
              }
              void this.runSearch()
            }
          })

          if (this.searched) {
            if (this.results.length === 0) {
              AppEmpty({
                title: '暂无匹配结果',
                description: '试试调整标签或关键词'
              })
            } else {
              ForEach(this.results, (item: TaskItem) => {
                TaskListCard({
                  item: item,
                  onTap: (): void => { TaskDetailNav.openTask(item.id, item) }
                })
              }, (item: TaskItem) => item.id)
            }
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
