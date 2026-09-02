import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { InspirationItem } from '../../models/InspirationModels'
import { InspirationBizService } from '../../services/InspirationBizService'
import { InspirationMedia } from '../../services/InspirationMedia'
import { InspirationDetailNav } from '../../services/InspirationDetailNav'
import { AuthService } from '../../services/AuthService'
import { BoardPinService } from '../../services/BoardPinService'
import { GrowthService } from '../../services/GrowthService'

@Component
export struct BoardDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onCreateBoard: () => void = () => {}
  @State item: InspirationItem | undefined = undefined
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private cardTexts(): string[] {
    if (this.item === undefined) {
      return []
    }
    const json = this.item.cardsJson.length > 0 ? this.item.cardsJson : this.item.body
    return BoardPinService.extractCardTexts(json)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await InspirationBizService.findMoodBoard(this.itemId)
    this.loading = false
    if (this.item !== undefined && AuthService.isLoggedIn()) {
      void GrowthService.recordBrowse(this.currentUsername, 'board', this.item.id, this.item.title)
    }
  }

  private handleCreateMine(): void {
    if (!AuthService.requireAuth('create_board')) {
      this.onRequireAuth()
      return
    }
    InspirationDetailNav.close()
    this.onCreateBoard()
  }

  build() {
    Stack() {
      if (this.loading) {
        this.BlockedPane('加载画板…', '正在打开创意画板')
      } else if (this.item === undefined) {
        this.BlockedPane('画板不存在', '可能已被删除或网络异常')
      } else {
        DetailShell({
          title: '创意画板',
          onClose: () => InspirationDetailNav.close(),
          body: () => { this.DetailBody() }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BlockedPane(title: string, description: string) {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { InspirationDetailNav.close() })
        Blank()
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
      Column() {
        AppEmpty({
          title: title,
          description: description,
          actionLabel: '关闭',
          onAction: (): void => { InspirationDetailNav.close() }
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .onClick((): void => { InspirationDetailNav.close() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(InspirationMedia.coverMedia(this.item.coverKey))
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
              Text('精选画板')
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
        }

        AppCard({ title: '画板简介', variant: 'plain' }) {
          Text(this.item.description.length > 0 ? this.item.description : this.item.summary)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .lineHeight(24)
        }

        if (this.cardTexts().length > 0) {
          AppCard({ title: '已钉入的灵感卡片', variant: 'plain' }) {
            Column({ space: 8 }) {
              ForEach(this.cardTexts(), (line: string, index: number) => {
                Text(line)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                  .lineHeight(22)
              }, (line: string, index: number) => `${index}_${line.substring(0, 24)}`)
            }
            .width('100%')
          }
        } else {
          AppCard({ title: '卡片内容', variant: 'plain' }) {
            Text('还没有文字卡片。在灵感详情点「钉到画板」，或记录时打开「保存后钉到画板」。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .lineHeight(22)
          }
        }

        AppButton({
          label: '创建我的画板',
          onTap: (): void => { this.handleCreateMine() }
        })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
    }
  }
}
