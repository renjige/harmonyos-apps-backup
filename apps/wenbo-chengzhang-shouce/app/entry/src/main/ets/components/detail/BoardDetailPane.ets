import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { GrowthRecordItem } from '../../models/GrowthModels'
import { GrowthBizService } from '../../services/GrowthBizService'
import { GrowthMedia } from '../../services/GrowthMedia'
import { GrowthDetailNav } from '../../services/GrowthDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct BoardDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onCreateBoard: () => void = () => {}
  @State item: GrowthRecordItem | undefined = undefined
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private cardsSummary(): string {
    if (this.item === undefined) {
      return ''
    }
    const json = this.item.cardsJson.length > 0 ? this.item.cardsJson : this.item.body
    if (json.length === 0 || json === '[]') {
      return '暂无补充内容'
    }
    return json
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await GrowthBizService.findMoodBoard(this.itemId)
    this.loading = false
  }

  private handleCreateMine(): void {
    if (!AuthService.requireAuth('create_goal')) {
      this.onRequireAuth()
      return
    }
    GrowthDetailNav.close()
    this.onCreateBoard()
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载里程碑…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '里程碑不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '成长里程碑',
          onClose: (): void => { GrowthDetailNav.close() },
          body: (): void => { this.DetailBody() }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(GrowthMedia.coverMedia(this.item.coverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(27,42,65,0)', 0], ['rgba(27,42,65,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            if (this.item.kind === 'showcase') {
              Text('精选里程碑')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandAccent)
            }
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.tags.length > 0) {
          Row({ space: 8 }) {
            ForEach(this.item.tags, (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().success)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().successContainer)
                .borderRadius(Theme.radius.pill)
            }, (tag: string) => tag)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppCard({ title: '里程碑简介', variant: 'plain' }) {
            Text(this.item.description.length > 0 ? this.item.description : this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.cardsSummary().length > 0 && this.cardsSummary() !== '暂无补充内容') {
          Column() {
            AppCard({ title: '补充说明', variant: 'plain' }) {
              Text(this.cardsSummary())
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
                .lineHeight(22)
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppButton({
            label: '添加我的里程碑',
            onTap: (): void => { this.handleCreateMine() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
